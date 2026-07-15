# Clean Architecture — Full Code Examples

> **Note**: These examples use `Movie` as the domain model and `L10n` as the localization enum. Adapt model names and the localization enum to your project (check `CLAUDE.md`).

## Model

```swift
import Foundation

struct Movie: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    let title: String
    let overview: String
    let releaseDate: Date
    let posterURL: URL?
    let rating: Double?

    var formattedRating: String {
        guard let rating else { return "N/A" }
        return rating.formatted(.number.precision(.fractionLength(1)))
    }
}
```

## Interactor Protocol

```swift
protocol MovieListInteractorProtocol: Sendable {
    func fetchMovies(page: Int, per: Int) async throws -> [Movie]
    func fetchMovie(id: UUID) async throws -> Movie
    func saveToFavorites(_ movie: Movie) async throws
    func deleteFromFavorites(id: UUID) async throws
}
```

## Production Interactor

```swift
final class MovieListInteractor: MovieListInteractorProtocol {

    private let networkService: NetworkServiceProtocol
    private let cacheService: CacheServiceProtocol

    init(
        networkService: NetworkServiceProtocol = NetworkService(),
        cacheService: CacheServiceProtocol = CacheService()
    ) {
        self.networkService = networkService
        self.cacheService = cacheService
    }

    func fetchMovies(page: Int, per: Int) async throws -> [Movie] {
        let cacheKey = "movies_\(page)_\(per)"

        if let cached: [Movie] = try? await cacheService.get(key: cacheKey) {
            return cached
        }

        let movies: [Movie] = try await networkService.get(
            endpoint: "/movies",
            queryItems: [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "per", value: "\(per)")
            ]
        )

        try? await cacheService.set(key: cacheKey, value: movies)
        return movies
    }

    func fetchMovie(id: UUID) async throws -> Movie {
        try await networkService.get(endpoint: "/movies/\(id)")
    }

    func saveToFavorites(_ movie: Movie) async throws {
        try await networkService.post(endpoint: "/favorites", body: movie)
    }

    func deleteFromFavorites(id: UUID) async throws {
        try await networkService.delete(endpoint: "/favorites/\(id)")
    }
}
```

## Mock Interactor (Previews)

```swift
final class MockMovieListInteractor: MovieListInteractorProtocol {

    var moviesToReturn: [Movie] = []
    var movieToReturn: Movie?
    var shouldThrowError = false

    func fetchMovies(page: Int, per: Int) async throws -> [Movie] {
        if shouldThrowError { throw NetworkError.serverError(500) }
        return moviesToReturn
    }

    func fetchMovie(id: UUID) async throws -> Movie {
        if shouldThrowError { throw NetworkError.notFound }
        guard let movie = movieToReturn ?? moviesToReturn.first(where: { $0.id == id }) else {
            throw NetworkError.notFound
        }
        return movie
    }

    func saveToFavorites(_ movie: Movie) async throws {
        if shouldThrowError { throw NetworkError.serverError(500) }
    }

    func deleteFromFavorites(id: UUID) async throws {
        if shouldThrowError { throw NetworkError.serverError(500) }
    }
}
```

## Spy Interactor (Unit Tests)

Location: `[App]Tests/Shared/Spies/SpyMovieListInteractor.swift`

```swift
import Testing
@testable import MyApp

@MainActor
final class SpyMovieListInteractor: MovieListInteractorProtocol {

    // MARK: - Spy Tracking

    private(set) var fetchMoviesWasCalled = false
    private(set) var fetchMovieWasCalled = false
    private(set) var saveToFavoritesWasCalled = false
    private(set) var deleteFromFavoritesWasCalled = false

    private(set) var lastFetchedMovieId: UUID?
    private(set) var lastSavedMovie: Movie?
    private(set) var lastFetchMoviesPage: Int?

    // MARK: - Stub Data

    var moviesToReturn: [Movie] = []
    var movieToReturn: Movie?
    var shouldThrowError = false
    var errorToThrow: Error = NetworkError.serverError(500)

    // MARK: - Functions

    func fetchMovies(page: Int, per: Int) async throws -> [Movie] {
        fetchMoviesWasCalled = true
        lastFetchMoviesPage = page
        if shouldThrowError { throw errorToThrow }
        return moviesToReturn
    }

    func fetchMovie(id: UUID) async throws -> Movie {
        fetchMovieWasCalled = true
        lastFetchedMovieId = id
        if shouldThrowError { throw errorToThrow }
        guard let movie = movieToReturn ?? moviesToReturn.first(where: { $0.id == id }) else {
            throw NetworkError.notFound
        }
        return movie
    }

    func saveToFavorites(_ movie: Movie) async throws {
        saveToFavoritesWasCalled = true
        lastSavedMovie = movie
        if shouldThrowError { throw errorToThrow }
        moviesToReturn.append(movie)
    }

    func deleteFromFavorites(id: UUID) async throws {
        deleteFromFavoritesWasCalled = true
        if shouldThrowError { throw errorToThrow }
        moviesToReturn.removeAll { $0.id == id }
    }

    func reset() {
        fetchMoviesWasCalled = false
        fetchMovieWasCalled = false
        saveToFavoritesWasCalled = false
        deleteFromFavoritesWasCalled = false
        lastFetchedMovieId = nil
        lastSavedMovie = nil
        lastFetchMoviesPage = nil
        moviesToReturn = []
        movieToReturn = nil
        shouldThrowError = false
    }
}
```

## ViewModel

```swift
import Observation

@Observable
@MainActor
final class MovieListViewModel {

    @ObservationIgnored
    private let interactor: MovieListInteractorProtocol

    @ObservationIgnored
    private var currentPage = 1

    var movies: [Movie] = []
    var isLoading = false
    var errorMessage: String?
    var searchText = ""

    var filteredMovies: [Movie] {
        guard !searchText.isEmpty else { return movies }
        return movies.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }

    init(interactor: MovieListInteractorProtocol = MovieListInteractor()) {
        self.interactor = interactor
    }

    func loadMovies() async {
        isLoading = true
        defer { isLoading = false }

        do {
            movies = try await interactor.fetchMovies(page: currentPage, per: 20)
            errorMessage = nil
        } catch {
            handleError(error)
        }
    }

    func deleteMovie(_ movie: Movie) async {
        do {
            try await interactor.deleteFromFavorites(id: movie.id)
            movies.removeAll { $0.id == movie.id }
        } catch {
            handleError(error)
        }
    }

    private func handleError(_ error: Error) {
        if let networkError = error as? NetworkError {
            errorMessage = networkError.userMessage
        } else {
            errorMessage = error.localizedDescription
        }
    }
}
```

## View

```swift
// MARK: - Private Views — adapt localization enum to your project (see CLAUDE.md)

struct MovieListView: View {

    @State private var viewModel: MovieListViewModel

    var body: some View {
        NavigationStack {
            contentView
                .navigationTitle("Movies")
                .searchable(text: $viewModel.searchText)
        }
        .task { await viewModel.loadMovies() }
        .refreshable { await viewModel.loadMovies() }
    }

    init(interactor: MovieListInteractorProtocol = MovieListInteractor()) {
        self.viewModel = MovieListViewModel(interactor: interactor)
    }

    @ViewBuilder
    private var contentView: some View {
        if viewModel.isLoading && viewModel.movies.isEmpty {
            ProgressView()
        } else if let error = viewModel.errorMessage {
            ErrorView(message: error) {
                Task { await viewModel.loadMovies() }
            }
        } else {
            List(viewModel.filteredMovies) { movie in
                NavigationLink(value: movie) {
                    MovieRowView(movie: movie)
                }
            }
            .navigationDestination(for: Movie.self) { movie in
                MovieDetailView(movieId: movie.id)
            }
        }
    }
}
```

## Preview with Mock

```swift
#Preview("Movie List") {
    let mockInteractor = MockMovieListInteractor()
    mockInteractor.moviesToReturn = Movie.samples

    return NavigationStack {
        MovieListView(interactor: mockInteractor)
    }
}

#Preview("Empty State") {
    let mockInteractor = MockMovieListInteractor()
    mockInteractor.moviesToReturn = []

    return NavigationStack {
        MovieListView(interactor: mockInteractor)
    }
}

#Preview("Error State") {
    let mockInteractor = MockMovieListInteractor()
    mockInteractor.shouldThrowError = true

    return NavigationStack {
        MovieListView(interactor: mockInteractor)
    }
}
```

## Test with Spy

```swift
import Testing
@testable import MyApp

@MainActor
struct MovieListViewModelTests {

    let sut: MovieListViewModel
    let spyInteractor: SpyMovieListInteractor

    init() {
        spyInteractor = SpyMovieListInteractor()
        sut = MovieListViewModel(interactor: spyInteractor)
    }

    @Test("Load movies updates array and clears error")
    func loadMoviesSuccess() async {
        spyInteractor.moviesToReturn = Movie.samples

        await sut.loadMovies()

        #expect(sut.movies == Movie.samples)
        #expect(sut.errorMessage == nil)
        #expect(sut.isLoading == false)
        #expect(spyInteractor.fetchMoviesWasCalled == true)
    }

    @Test("Load movies failure sets error message")
    func loadMoviesFailure() async {
        spyInteractor.shouldThrowError = true

        await sut.loadMovies()

        #expect(sut.movies.isEmpty)
        #expect(sut.errorMessage != nil)
        #expect(spyInteractor.fetchMoviesWasCalled == true)
    }
}
```
