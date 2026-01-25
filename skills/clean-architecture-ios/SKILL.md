# Clean Architecture for iOS

## Description

Clean Architecture pattern for iOS apps using SwiftUI, with 4 distinct layers: Models, Interactors, ViewModels, and Views. This pattern ensures separation of concerns, testability, and maintainability through protocol-first design and dependency injection.

## When to Use

- Building iOS apps with complex business logic
- Projects requiring high test coverage
- Teams working on different features simultaneously
- Apps that need to scale beyond 5-10 screens
- When UI framework might change (e.g., UIKit → SwiftUI)

## Architecture Layers

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

## Rule 1: Model Layer - Pure Data

**Models are pure Swift structs with no dependencies.**

### Characteristics
- Conform to `Identifiable`, `Codable`, `Hashable`, `Sendable` as needed
- No imports beyond Foundation
- No business logic
- No dependencies on other layers

### ✅ Correct

```swift
import Foundation

struct Movie: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    let title: String
    let overview: String
    let releaseDate: Date
    let posterURL: URL?
    let rating: Double?

    // Computed properties for presentation are OK
    var formattedRating: String {
        guard let rating = rating else { return "N/A" }
        return rating.formatted(.number.precision(.fractionLength(1)))
    }
}
```

### ❌ Incorrect

```swift
// ❌ Has business logic
struct Movie {
    let title: String

    func save() {  // ❌ Business logic belongs in Interactor
        // saving logic
    }
}

// ❌ Imports UIKit/SwiftUI
import SwiftUI

struct Movie {
    var color: Color  // ❌ UI-specific type in Model
}
```

## Rule 2: Interactor Layer - Business Logic

**Interactors handle all business logic and data access. Always protocol-first with multiple implementations.**

### Implementations Required

| Implementation | Purpose | Location |
|----------------|---------|----------|
| **Production** | Real app logic | `Features/{Feature}/Interactor/` |
| **Mock** | Previews & production testing | `Features/{Feature}/Interactor/` |
| **Spy** | Unit testing with tracking | `{App}Tests/Shared/Spies/` |

### Protocol Definition

```swift
// In Features/MovieList/Interactor/Protocols/MovieListInteractorProtocol.swift

protocol MovieListInteractorProtocol: Sendable {
    func fetchMovies(page: Int, per: Int) async throws -> [Movie]
    func fetchMovie(id: UUID) async throws -> Movie
    func saveToFavorites(_ movie: Movie) async throws
    func deleteFromFavorites(id: UUID) async throws
}
```

### Production Implementation

```swift
// In Features/MovieList/Interactor/MovieListInteractor.swift

final class MovieListInteractor: MovieListInteractorProtocol {

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

### Mock Implementation (for Previews)

```swift
// In Features/MovieList/Interactor/MockMovieListInteractor.swift

final class MockMovieListInteractor: MovieListInteractorProtocol {

    // MARK: - Properties

    var moviesToReturn: [Movie] = []
    var movieToReturn: Movie?
    var shouldThrowError = false

    // MARK: - Functions

    func fetchMovies(page: Int, per: Int) async throws -> [Movie] {
        if shouldThrowError {
            throw NetworkError.serverError(500)
        }
        return moviesToReturn
    }

    func fetchMovie(id: UUID) async throws -> Movie {
        if shouldThrowError {
            throw NetworkError.notFound
        }
        guard let movie = movieToReturn ?? moviesToReturn.first(where: { $0.id == id }) else {
            throw NetworkError.notFound
        }
        return movie
    }

    func saveToFavorites(_ movie: Movie) async throws {
        if shouldThrowError {
            throw NetworkError.serverError(500)
        }
        // No-op for mock
    }

    func deleteFromFavorites(id: UUID) async throws {
        if shouldThrowError {
            throw NetworkError.serverError(500)
        }
        // No-op for mock
    }
}
```

### Spy Implementation (for Unit Tests)

**Location**: `{App}Tests/Shared/Spies/SpyMovieListInteractor.swift`

```swift
import Testing
@testable import MyApp

final class SpyMovieListInteractor: MovieListInteractorProtocol, @unchecked Sendable {

    // MARK: - Spy Tracking (wasCalled properties)

    private(set) var fetchMoviesWasCalled = false
    private(set) var fetchMovieWasCalled = false
    private(set) var saveToFavoritesWasCalled = false
    private(set) var deleteFromFavoritesWasCalled = false

    private(set) var lastFetchedMovieId: UUID?
    private(set) var lastSavedMovie: Movie?
    private(set) var lastDeletedMovieId: UUID?
    private(set) var lastFetchMoviesPage: Int?
    private(set) var lastFetchMoviesPer: Int?

    // MARK: - Stub Data

    var moviesToReturn: [Movie] = []
    var movieToReturn: Movie?
    var shouldThrowError = false
    var errorToThrow: Error = NetworkError.serverError(500)

    // MARK: - Functions

    func fetchMovies(page: Int, per: Int) async throws -> [Movie] {
        fetchMoviesWasCalled = true
        lastFetchMoviesPage = page
        lastFetchMoviesPer = per

        if shouldThrowError {
            throw errorToThrow
        }
        return moviesToReturn
    }

    func fetchMovie(id: UUID) async throws -> Movie {
        fetchMovieWasCalled = true
        lastFetchedMovieId = id

        if shouldThrowError {
            throw errorToThrow
        }
        guard let movie = movieToReturn ?? moviesToReturn.first(where: { $0.id == id }) else {
            throw NetworkError.notFound
        }
        return movie
    }

    func saveToFavorites(_ movie: Movie) async throws {
        saveToFavoritesWasCalled = true
        lastSavedMovie = movie

        if shouldThrowError {
            throw errorToThrow
        }
        moviesToReturn.append(movie)
    }

    func deleteFromFavorites(id: UUID) async throws {
        deleteFromFavoritesWasCalled = true
        lastDeletedMovieId = id

        if shouldThrowError {
            throw errorToThrow
        }
        moviesToReturn.removeAll { $0.id == id }
    }

    // MARK: - Test Helpers

    func reset() {
        fetchMoviesWasCalled = false
        fetchMovieWasCalled = false
        saveToFavoritesWasCalled = false
        deleteFromFavoritesWasCalled = false
        lastFetchedMovieId = nil
        lastSavedMovie = nil
        lastDeletedMovieId = nil
        lastFetchMoviesPage = nil
        lastFetchMoviesPer = nil
        moviesToReturn = []
        movieToReturn = nil
        shouldThrowError = false
    }
}
```

### Key Differences: Mock vs Spy

| Aspect | Mock | Spy |
|--------|------|-----|
| **Location** | `Features/{Feature}/Interactor/` | `{App}Tests/Shared/Spies/` |
| **Purpose** | Previews, manual testing | Unit tests with assertions |
| **Tracking** | No tracking | Has `wasCalled` booleans |
| **Import** | No test imports | `import Testing`, `@testable` |
| **Methods** | Minimal implementation | Full tracking + stub data |

## Rule 3: ViewModel Layer - Presentation Logic

**ViewModels transform data for presentation and handle user interactions. Use `@Observable` macro.**

### Characteristics
- Marked with `@Observable` and `@MainActor`
- Receives Interactor via initializer (DI)
- Non-observed properties use `@ObservationIgnored`
- Handles errors with user-friendly messages

### ✅ Correct

```swift
import Observation

@Observable
@MainActor
final class MovieListViewModel {

    // MARK: - Private Properties

    @ObservationIgnored
    private let interactor: MovieListInteractorProtocol

    @ObservationIgnored
    private var currentPage = 1

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

    init(interactor: MovieListInteractorProtocol = MovieListInteractor()) {
        self.interactor = interactor
    }

    // MARK: - Functions

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

    // MARK: - Private Functions

    private func handleError(_ error: Error) {
        if let networkError = error as? NetworkError {
            errorMessage = networkError.userMessage
        } else {
            errorMessage = error.localizedDescription
        }
    }
}
```

## Rule 4: View Layer - UI Only

**Views display data and delegate actions to ViewModels. Zero business logic.**

### Characteristics
- Uses `@State` to own ViewModel
- Passes Interactor to ViewModel via initializer (DI)
- Delegates all actions to ViewModel
- Minimal logic (only UI-related decisions)

### ✅ Correct

```swift
struct MovieListView: View {

    // MARK: - States

    @State private var viewModel: MovieListViewModel

    // MARK: - Body

    var body: some View {
        NavigationStack {
            contentView
                .navigationTitle("Movies")
                .searchable(text: $viewModel.searchText)
        }
        .task {
            await viewModel.loadMovies()
        }
        .refreshable {
            await viewModel.loadMovies()
        }
    }

    // MARK: - Initializers

    init(interactor: MovieListInteractorProtocol = MovieListInteractor()) {
        self.viewModel = MovieListViewModel(interactor: interactor)
    }

    // MARK: - Private Views

    @ViewBuilder
    private var contentView: some View {
        if viewModel.isLoading && viewModel.movies.isEmpty {
            ProgressView()
        } else if let error = viewModel.errorMessage {
            ErrorView(message: error) {
                Task { await viewModel.loadMovies() }
            }
        } else {
            moviesList
        }
    }

    @ViewBuilder
    private var moviesList: some View {
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
```

## Rule 5: Dependency Injection Pattern

**Always inject dependencies through initializers with default values.**

### View → ViewModel → Interactor Flow

```swift
// 1. View owns ViewModel
struct MovieListView: View {
    @State private var viewModel: MovieListViewModel

    init(interactor: MovieListInteractorProtocol = MovieListInteractor()) {
        self.viewModel = MovieListViewModel(interactor: interactor)
    }
}

// 2. ViewModel receives Interactor
@Observable
@MainActor
final class MovieListViewModel {
    @ObservationIgnored
    private let interactor: MovieListInteractorProtocol

    init(interactor: MovieListInteractorProtocol = MovieListInteractor()) {
        self.interactor = interactor
    }
}

// 3. Interactor receives Services
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
}
```

### Testing with DI

```swift
// In unit tests
@Test("Load movies successfully")
@MainActor
func loadMoviesSuccess() async {
    // Given
    let spyInteractor = SpyMovieListInteractor()
    spyInteractor.moviesToReturn = [Movie.sample]
    let viewModel = MovieListViewModel(interactor: spyInteractor)

    // When
    await viewModel.loadMovies()

    // Then
    #expect(spy Interactor.fetchMoviesWasCalled == true)
    #expect(viewModel.movies.count == 1)
}

// In SwiftUI previews
#Preview("Movie List") {
    let mockInteractor = MockMovieListInteractor()
    mockInteractor.moviesToReturn = Movie.samples

    return NavigationStack {
        MovieListView(interactor: mockInteractor)
    }
}
```

## Rule 6: Feature-based Organization

**Organize code by feature, not by layer.**

### ✅ Correct (Feature-based)

```
Features/
└── MovieList/
    ├── Models/
    │   └── MovieListFilter.swift
    ├── Interactor/
    │   ├── Protocols/
    │   │   └── MovieListInteractorProtocol.swift
    │   ├── MovieListInteractor.swift
    │   └── MockMovieListInteractor.swift
    ├── ViewModel/
    │   └── MovieListViewModel.swift
    └── Views/
        ├── MovieListView.swift
        └── Components/
            ├── MovieRowView.swift
            └── FilterSheetView.swift
```

### ❌ Incorrect (Layer-based)

```
Models/
  └── Movie.swift
ViewModels/
  └── MovieListViewModel.swift
Views/
  └── MovieListView.swift
Interactors/
  └── MovieListInteractor.swift
```

**Why feature-based is better:**
- Scales better (easy to find "what does MovieList do?")
- Self-contained features
- Supports team collaboration (different features, different developers)
- Easier to remove or refactor entire features

## Checklist

When implementing a new feature with Clean Architecture:

- [ ] Define Models as pure structs (`Identifiable`, `Codable`, `Sendable`)
- [ ] Create Interactor protocol with all methods
- [ ] Implement Production Interactor with real logic
- [ ] Implement Mock Interactor for previews
- [ ] Implement Spy Interactor in test target (if writing tests)
- [ ] Create ViewModel with `@Observable` and `@MainActor`
- [ ] ViewModel receives Interactor via initializer
- [ ] Mark non-observed ViewModel properties with `@ObservationIgnored`
- [ ] View owns ViewModel with `@State`
- [ ] View passes Interactor to ViewModel in `init`
- [ ] All async operations use `async/await`
- [ ] All dependencies injected through initializers with defaults
- [ ] Feature organized in feature-based folder structure
- [ ] No business logic in Views (delegate to ViewModel)
- [ ] No UI code in Models or Interactors

## Common Mistakes

### ❌ Mistake 1: Business Logic in Views

```swift
// ❌ BAD: View has business logic
struct MovieListView: View {
    @State private var movies: [Movie] = []

    var body: some View {
        List(movies) { movie in
            Text(movie.title)
        }
        .task {
            // ❌ Network call directly in View
            movies = try! await NetworkService().get(endpoint: "/movies")
        }
    }
}
```

**Fix**: Move to ViewModel via Interactor

### ❌ Mistake 2: Wrong Implementation Names

```swift
// ❌ BAD: Called "Spy" but in production code
final class SpyMovieInteractor: MovieInteractorProtocol {
    // Used for previews
}
```

**Fix**: Use `MockMovieInteractor` for previews, `SpyMovieInteractor` only in tests

### ❌ Mistake 3: Missing Protocol

```swift
// ❌ BAD: Concrete class without protocol
final class MovieInteractor {
    func fetchMovies() async throws -> [Movie] { }
}
```

**Fix**: Always create protocol first

### ❌ Mistake 4: Hardcoded Dependencies

```swift
// ❌ BAD: Hardcoded NetworkService
final class MovieInteractor {
    private let networkService = NetworkService()  // ❌ Can't inject
}
```

**Fix**: Inject via initializer with protocol

## Examples

See the Clean Architecture implementation in:
- MangaList feature (complete example)
- Search feature (search-specific patterns)
- Collection feature (SwiftData integration)

## Related Skills

- `skills/swiftui-observable/SKILL.md` - ViewModel patterns with `@Observable`
- `skills/swift-testing-patterns/SKILL.md` - Testing with Spy pattern
