# Swift Testing — Full Code Examples

> **Note**: Replace `@testable import MyApp` with your app's module name (check `CLAUDE.md`). Spy location and naming conventions are also project-specific.

## Spy Implementation

Location: `[App]Tests/Shared/Spies/SpyMovieInteractor.swift`

```swift
import Testing
@testable import MyApp

@MainActor
final class SpyMovieInteractor: MovieInteractorProtocol {

    // MARK: - Spy Tracking

    private(set) var fetchMoviesWasCalled = false
    private(set) var fetchMovieWasCalled = false
    private(set) var saveMovieWasCalled = false
    private(set) var deleteMovieWasCalled = false

    private(set) var lastFetchedMovieId: UUID?
    private(set) var lastSavedMovie: Movie?
    private(set) var lastDeletedMovieId: UUID?

    // MARK: - Stub Data

    var moviesToReturn: [Movie] = []
    var movieToReturn: Movie?
    var shouldThrowError = false
    var errorToThrow: Error = NSError(domain: "test", code: 500)

    // MARK: - Functions

    func fetchMovies() async throws -> [Movie] {
        fetchMoviesWasCalled = true
        if shouldThrowError { throw errorToThrow }
        return moviesToReturn
    }

    func fetchMovie(id: UUID) async throws -> Movie {
        fetchMovieWasCalled = true
        lastFetchedMovieId = id
        if shouldThrowError { throw errorToThrow }
        guard let movie = movieToReturn ?? moviesToReturn.first(where: { $0.id == id }) else {
            throw NSError(domain: "test", code: 404)
        }
        return movie
    }

    func saveMovie(_ movie: Movie) async throws {
        saveMovieWasCalled = true
        lastSavedMovie = movie
        if shouldThrowError { throw errorToThrow }
        moviesToReturn.append(movie)
    }

    func deleteMovie(id: UUID) async throws {
        deleteMovieWasCalled = true
        lastDeletedMovieId = id
        if shouldThrowError { throw errorToThrow }
        moviesToReturn.removeAll { $0.id == id }
    }

    // MARK: - Test Helpers

    func reset() {
        fetchMoviesWasCalled = false
        fetchMovieWasCalled = false
        saveMovieWasCalled = false
        deleteMovieWasCalled = false
        lastFetchedMovieId = nil
        lastSavedMovie = nil
        lastDeletedMovieId = nil
        moviesToReturn = []
        movieToReturn = nil
        shouldThrowError = false
    }
}
```

## ViewModel Tests with SUT

```swift
import Testing
@testable import MyApp

@MainActor
struct MovieListViewModelTests {

    // MARK: - Subject Under Test

    let sut: MovieListViewModel

    // MARK: - Spies

    let spyInteractor: SpyMovieInteractor

    // MARK: - Initializers

    init() {
        spyInteractor = SpyMovieInteractor()
        sut = MovieListViewModel(interactor: spyInteractor)
    }

    // MARK: - Tests

    @Test("Load movies successfully updates array and clears error")
    func loadMoviesSuccess() async {
        // Given
        let expected = Movie.samples
        spyInteractor.moviesToReturn = expected

        // When
        await sut.loadMovies()

        // Then
        #expect(sut.movies == expected)
        #expect(sut.errorMessage == nil)
        #expect(sut.isLoading == false)
        #expect(spyInteractor.fetchMoviesWasCalled == true)
    }

    @Test("Load movies failure sets error message")
    func loadMoviesFailure() async {
        // Given
        spyInteractor.shouldThrowError = true
        spyInteractor.errorToThrow = NSError(domain: "test", code: 500)

        // When
        await sut.loadMovies()

        // Then
        #expect(sut.movies.isEmpty)
        #expect(sut.errorMessage != nil)
        #expect(sut.isLoading == false)
        #expect(spyInteractor.fetchMoviesWasCalled == true)
    }
}

// MARK: - Test Data

private extension MovieListViewModelTests {
    static let sampleMovies: [Movie] = [
        .init(id: UUID(), title: "First", overview: "", releaseDate: Date(), posterURL: nil),
        .init(id: UUID(), title: "Second", overview: "", releaseDate: Date(), posterURL: nil),
        .init(id: UUID(), title: "Third", overview: "", releaseDate: Date(), posterURL: nil)
    ]
}
```

## Parameterized Tests

```swift
@MainActor
struct MovieListViewModelTests {

    let spyInteractor = SpyMovieInteractor()

    // MARK: - Tests

    @Test(
        "Filter movies by search text",
        arguments: [
            .init(searchText: "avengers", expectedCount: 2),
            .init(searchText: "spider", expectedCount: 1),
            .init(searchText: "batman", expectedCount: 0),
            .init(searchText: "", expectedCount: 5)
        ] as [FilterArgument]
    )
    func filterMovies(argument: FilterArgument) async {
        // Given
        spyInteractor.moviesToReturn = Self.sampleMovies
        let viewModel = MovieListViewModel(interactor: spyInteractor)
        await viewModel.loadMovies()

        // When
        viewModel.searchText = argument.searchText

        // Then
        #expect(viewModel.filteredMovies.count == argument.expectedCount)
    }

    @Test(
        "Handle error types",
        arguments: [
            .init(error: NSError(domain: "auth", code: 401), expectedContains: "login"),
            .init(error: NSError(domain: "api", code: 404), expectedContains: "not found"),
            .init(error: NSError(domain: "server", code: 500), expectedContains: "wrong")
        ] as [ErrorArgument]
    )
    func handleErrors(argument: ErrorArgument) async {
        // Given
        spyInteractor.shouldThrowError = true
        spyInteractor.errorToThrow = argument.error
        let viewModel = MovieListViewModel(interactor: spyInteractor)

        // When
        await viewModel.loadMovies()

        // Then
        #expect(viewModel.errorMessage?.localizedCaseInsensitiveContains(argument.expectedContains) == true)
    }
}

// MARK: - Arguments

private extension MovieListViewModelTests {

    struct FilterArgument: CustomTestStringConvertible {
        let searchText: String
        let expectedCount: Int

        var testDescription: String {
            "search '\(searchText)' → expects \(expectedCount)"
        }

        init(searchText: String, expectedCount: Int) {
            self.searchText = searchText
            self.expectedCount = expectedCount
        }
    }

    struct ErrorArgument: CustomTestStringConvertible {
        let error: Error
        let expectedContains: String

        var testDescription: String {
            "\(error) → contains '\(expectedContains)'"
        }

        init(error: Error, expectedContains: String) {
            self.error = error
            self.expectedContains = expectedContains
        }
    }
}
```

## Suite Organization

### Main Suite (`FeatureTests.swift`)

```swift
import Testing
@testable import MyApp

@Suite("Movie Detail Feature")
struct MovieDetailTests { }
```

### ViewModel Sub-Suite (`FeatureTests+ViewModel.swift`)

```swift
import Testing
@testable import MyApp

extension MovieDetailTests {

    @Suite("ViewModel Tests")
    @MainActor
    struct ViewModelTests {

        let spyInteractor = SpyMovieDetailInteractor()

        @Test("Load movie successfully")
        func loadMovieSuccess() async {
            spyInteractor.movieToReturn = Self.sampleMovie
            let viewModel = MovieDetailViewModel(movieId: Self.sampleMovie.id, interactor: spyInteractor)

            await viewModel.loadMovie()

            #expect(viewModel.movie == Self.sampleMovie)
            #expect(spyInteractor.fetchMovieWasCalled == true)
        }
    }
}

private extension MovieDetailTests.ViewModelTests {
    static let sampleMovie = Movie(id: UUID(), title: "Sample", overview: "...", releaseDate: Date(), posterURL: nil)
}
```

### Interactor Sub-Suite (`FeatureTests+Interactor.swift`)

```swift
import Testing
@testable import MyApp

extension MovieDetailTests {

    @Suite("Interactor Tests")
    @MainActor
    struct InteractorTests {

        let spyNetwork = SpyNetworkService()

        @Test("Fetch movie from network")
        func fetchMovieFromNetwork() async throws {
            let interactor = MovieDetailInteractor(networkService: spyNetwork)
            spyNetwork.dataToReturn = Self.sampleMovieData

            let movie = try await interactor.fetchMovie(id: Self.sampleMovieId)

            #expect(movie.id == Self.sampleMovieId)
            #expect(spyNetwork.getWasCalled == true)
        }
    }
}

private extension MovieDetailTests.InteractorTests {
    static let sampleMovieId = UUID()
    static let sampleMovieData = Movie(id: sampleMovieId, title: "From Network", overview: "", releaseDate: Date(), posterURL: nil)
}
```
