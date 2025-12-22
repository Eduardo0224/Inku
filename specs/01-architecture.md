# Architecture Specification

## Clean Architecture (4 Layers)

```
┌─────────────────────────────────────────┐
│              Views (SwiftUI)            │  ← UI only, no logic
├─────────────────────────────────────────┤
│        ViewModels (@Observable)         │  ← Presentation logic, state
├─────────────────────────────────────────┤
│      Interactors (Protocol-based)       │  ← Business logic, data access
├─────────────────────────────────────────┤
│              Models (Structs)           │  ← Pure data, no dependencies
└─────────────────────────────────────────┘
```

## Layer Responsibilities

### 1. Model Layer
- Pure Swift structs
- `Identifiable`, `Codable`, `Hashable`, `Sendable` conformance as needed
- No imports beyond Foundation
- No dependencies on other layers

```swift
struct Movie: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    let title: String
    let overview: String
    let releaseDate: Date
    let posterURL: URL?
}
```

### 2. Interactor Layer (Business Logic)
- **Always protocol-first**: Define protocol, then implementations
- Handles data access (network, persistence, cache)
- Two implementations minimum: Production + Spy
- Dependency injection ready

```swift
// Protocol (in Protocols/ subfolder)
protocol MovieInteractorProtocol: Sendable {
    func fetchMovies() async throws -> [Movie]
    func fetchMovie(id: UUID) async throws -> Movie
    func saveToFavorites(_ movie: Movie) async throws
}

// Production implementation
final class MovieInteractor: MovieInteractorProtocol {
    
    // MARK: - Private Properties

    private let networkService: NetworkServiceProtocol
    private let cacheService: CacheServiceProtocol

    // MARK: - Initializers

    init(
        networkService: NetworkServiceProtocol = NetworkService(),
        cacheService: CacheServiceProtocol = CacheService()
    ) {
        self.networkService = networkService
        self.cacheService = cacheService
    }

    // MARK: - Functions
    
    func fetchMovies() async throws -> [Movie] {
        if let cached: [Movie] = try? await cacheService.get(key: "movies") {
            return cached
        }
        let movies: [Movie] = try await networkService.get(endpoint: "/movies")
        try? await cacheService.set(key: "movies", value: movies)
        return movies
    }
    
    func fetchMovie(id: UUID) async throws -> Movie {
        try await networkService.get(endpoint: "/movies/\(id)")
    }
    
    func saveToFavorites(_ movie: Movie) async throws {
        try await networkService.post(endpoint: "/favorites", body: movie)
    }
}

// Spy implementation (for testing)
final class SpyMovieInteractor: MovieInteractorProtocol, @unchecked Sendable {
    
    // MARK: - Properties (Spy Tracking)
    
    private(set) var fetchMoviesWasCalled = false
    private(set) var fetchMovieWasCalled = false
    private(set) var saveToFavoritesWasCalled = false
    
    private(set) var lastFetchedMovieId: UUID?
    private(set) var lastSavedMovie: Movie?
    
    // MARK: - Properties (Stub Data)
    
    var moviesToReturn: [Movie] = []
    var movieToReturn: Movie?
    var shouldThrowError = false
    var errorToThrow: Error = InteractorError.generic
    
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
            throw InteractorError.notFound
        }
        return movie
    }
    
    func saveToFavorites(_ movie: Movie) async throws {
        saveToFavoritesWasCalled = true
        lastSavedMovie = movie
        if shouldThrowError { throw errorToThrow }
    }
    
    // MARK: - Functions (Test Helpers)
    
    func reset() {
        fetchMoviesWasCalled = false
        fetchMovieWasCalled = false
        saveToFavoritesWasCalled = false
        lastFetchedMovieId = nil
        lastSavedMovie = nil
        moviesToReturn = []
        movieToReturn = nil
        shouldThrowError = false
    }
}

enum InteractorError: Error {
    case generic
    case notFound
}
```

### 3. ViewModel Layer (Presentation Logic)
- Uses `@Observable` macro (Observation framework)
- Transforms data for presentation
- Receives Interactor via initializer (DI)
- Handles errors with `handleError(_:)` pattern
- Mark non-observed properties with `@ObservationIgnored`

```swift
import Observation

@Observable
@MainActor
final class MovieListViewModel {
    
    // MARK: - Private Properties
    
    @ObservationIgnored
    private let interactor: MovieInteractorProtocol
    
    // MARK: - Properties
    
    var movies: [Movie] = []
    var isLoading = false
    var errorMessage: String?
    var searchText = ""
    
    var filteredMovies: [Movie] {
        guard !searchText.isEmpty else { return movies }
        return movies.filter {
            $0.title.localizedCaseInsensitiveContains(searchText)
        }
    }

    // MARK: - Initializers

    init(interactor: MovieInteractorProtocol = MovieInteractor()) {
        self.interactor = interactor
    }

    // MARK: - Functions
    
    func loadMovies() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            movies = try await interactor.fetchMovies()
        } catch {
            handleError(error)
        }
    }
    
    // MARK: - Private Functions
    
    private func handleError(_ error: Error) {
        if let customError = error as? CustomError {
            errorMessage = customError.userMessage
        } else {
            errorMessage = error.localizedDescription
        }
    }
}
```

### 4. View Layer
- SwiftUI only
- Uses `@State` to own ViewModel
- Highly componentized (see `02-swiftui-patterns.md`)
- Minimal logic—delegate to ViewModel

## Feature-based Folder Structure

```
Features/
└── MovieDetail/
    ├── Models/
    │   └── MovieDetailModel.swift
    ├── Interactor/
    │   ├── Protocols/
    │   │   └── MovieDetailInteractorProtocol.swift
    │   ├── MovieDetailInteractor.swift
    │   └── SpyMovieDetailInteractor.swift
    ├── ViewModel/
    │   └── MovieDetailViewModel.swift
    └── Views/
        ├── MovieDetailView.swift
        └── Components/
            ├── MoviePosterView.swift
            ├── MovieInfoSection.swift
            └── MovieActionsBar.swift
```

## Dependency Injection Pattern

```swift
struct MovieDetailView: View {
    
    // MARK: - States

    @State private var viewModel: MovieDetailViewModel

    // MARK: - Body

    var body: some View {
        // ...
    }

    // MARK: - Initializers

    init(
        movieId: UUID,
        interactor: MovieDetailInteractorProtocol = MovieDetailInteractor()
    ) {
        self.viewModel = MovieDetailViewModel(
            movieId: movieId,
            interactor: interactor
        )
    }
}
```

## Shared Core Module

For code shared across features:

```
Core/
├── Models/
│   └── User.swift                 ← Shared models
├── Services/
│   ├── Protocols/
│   │   ├── NetworkServiceProtocol.swift
│   │   └── CacheServiceProtocol.swift
│   ├── NetworkService.swift
│   └── CacheService.swift
├── Extensions/
│   ├── String+Extensions.swift
│   └── Date+Extensions.swift
└── Components/
    ├── LoadingView.swift          ← Reusable UI components
    ├── ErrorView.swift
    └── AsyncImageView.swift
```
