# Testing Specification

## Framework: Swift Testing

**ALWAYS use Swift Testing. NEVER use XCTest.**

```swift
import Testing
```

## Testing Strategy

| Layer | Test Type | Priority |
|-------|-----------|----------|
| Models | Unit tests | High |
| ViewModels | Unit tests | High |
| Interactors | Unit tests with spies | Medium |
| Views | SwiftUI Previews | High |

## Test File Organization (Feature-based)

Each feature has a main suite file and separate files for each sub-suite:

```
Tests/
└── Features/
    ├── MovieList/
    │   ├── MovieListTests.swift              ← Main @Suite
    │   ├── MovieListTests+ViewModel.swift    ← ViewModel sub-suite
    │   └── MovieListTests+Interactor.swift   ← Interactor sub-suite
    ├── MovieDetail/
    │   ├── MovieDetailTests.swift
    │   ├── MovieDetailTests+ViewModel.swift
    │   └── MovieDetailTests+Interactor.swift
    └── Shared/
        └── Spies/
            ├── SpyMovieInteractor.swift
            └── SpyNetworkService.swift
```

## Spy Pattern (Not Mock)

Spies record interactions for verification. They track:
- Which methods were called (boolean flags)
- With what arguments
- What was returned

```swift
final class SpyMovieInteractor: MovieInteractorProtocol, @unchecked Sendable {
    
    // MARK: - Properties (Spy Tracking)
    
    private(set) var fetchMoviesWasCalled = false
    private(set) var fetchMovieWasCalled = false
    private(set) var saveMovieWasCalled = false
    private(set) var deleteMovieWasCalled = false
    
    private(set) var lastFetchedMovieId: UUID?
    private(set) var lastSavedMovie: Movie?
    private(set) var lastDeletedMovieId: UUID?
    
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
    
    // MARK: - Functions (Test Helpers)
    
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

## ViewModel Tests with Swift Testing

### Pattern 1: Creating SUT in Each Test (Basic)

Use when tests need different configurations:

```swift
import Testing
@testable import MyApp

@MainActor
struct MovieListViewModelTests {

    // MARK: - Properties

    let spyInteractor = SpyMovieInteractor()

    // MARK: - Load Movies Tests

    @Test("Load movies successfully updates movies array")
    func loadMoviesSuccess() async {
        // Given
        let expectedMovies = Movie.samples
        spyInteractor.moviesToReturn = expectedMovies
        let viewModel = MovieListViewModel(interactor: spyInteractor)

        // When
        await viewModel.loadMovies()

        // Then
        #expect(viewModel.movies == expectedMovies)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.isLoading == false)
        #expect(spyInteractor.fetchMoviesWasCalled == true)
    }

    @Test("Load movies failure sets error message")
    func loadMoviesFailure() async {
        // Given
        spyInteractor.shouldThrowError = true
        spyInteractor.errorToThrow = NetworkError.serverError(500)
        let viewModel = MovieListViewModel(interactor: spyInteractor)

        // When
        await viewModel.loadMovies()

        // Then
        #expect(viewModel.movies.isEmpty)
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.isLoading == false)
        #expect(spyInteractor.fetchMoviesWasCalled == true)
    }
}
```

### Pattern 2: Creating SUT in init() (Recommended)

**Recommended** when most tests use the same SUT configuration:

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

    // MARK: - Load Movies Tests

    @Test("Load movies successfully updates movies array")
    func loadMoviesSuccess() async {
        // Given
        let expectedMovies = Movie.samples
        spyInteractor.moviesToReturn = expectedMovies

        // When
        await sut.loadMovies()

        // Then
        #expect(sut.movies == expectedMovies)
        #expect(sut.errorMessage == nil)
        #expect(sut.isLoading == false)
        #expect(spyInteractor.fetchMoviesWasCalled == true)
    }

    @Test("Load movies failure sets error message")
    func loadMoviesFailure() async {
        // Given
        spyInteractor.shouldThrowError = true
        spyInteractor.errorToThrow = NetworkError.serverError(500)

        // When
        await sut.loadMovies()

        // Then
        #expect(sut.movies.isEmpty)
        #expect(sut.errorMessage != nil)
        #expect(sut.isLoading == false)
        #expect(spyInteractor.fetchMoviesWasCalled == true)
    }
}
```

**Benefits of Pattern 2**:
- ✅ Less repetition (DRY principle)
- ✅ Clearer test intent (no setup noise)
- ✅ Named `sut` (Subject Under Test) for clarity
- ✅ Consistent test structure

**MARK Structure**:
1. `// MARK: - Subject Under Test` → SUT instance
2. `// MARK: - Spies` → Spy dependencies
3. `// MARK: - Initializers` → Setup
4. `// MARK: - Tests` → Test methods
5. `// MARK: - Test Data` → Static sample data
6. `// MARK: - Arguments` → Argument structs

## Using @Test with Arguments (Structured Pattern)

### CustomTestStringConvertible for Readable Test Names

When using argument structs with multiple parameters, conform to `CustomTestStringConvertible` to provide meaningful test descriptions in Xcode's test navigator:

```swift
struct FilterMoviesArgument: CustomTestStringConvertible {
    let searchText: String
    let expectedCount: Int
    
    var testDescription: String {
        "search '\(searchText)' → expects \(expectedCount) results"
    }
}
```

This displays as:
- `filterMovies(argument:) search 'avengers' → expects 2 results`
- `filterMovies(argument:) search '' → expects 5 results`

Instead of the default unreadable output.

### Define Argument Structs in Private Extension

```swift
import Testing
@testable import MyApp

@MainActor
struct MovieListViewModelTests {
    
    // MARK: - Subject Under Test
    
    let spyInteractor = SpyMovieInteractor()
    
    // MARK: - Tests
    
    @Test(
        "Filtering movies by search text",
        arguments: [
            .init(searchText: "avengers", expectedCount: 2),
            .init(searchText: "spider", expectedCount: 1),
            .init(searchText: "batman", expectedCount: 0),
            .init(searchText: "", expectedCount: 5)
        ] as [FilterMoviesArgument]
    )
    func filterMovies(argument: FilterMoviesArgument) async {
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
        "Handle different error types correctly",
        arguments: [
            .init(error: NetworkError.unauthorized, expectedContains: "login"),
            .init(error: NetworkError.notFound, expectedContains: "not found"),
            .init(error: NetworkError.serverError(500), expectedContains: "wrong")
        ] as [HandleErrorArgument]
    )
    func handleErrorTypes(argument: HandleErrorArgument) async {
        // Given
        spyInteractor.shouldThrowError = true
        spyInteractor.errorToThrow = argument.error
        let viewModel = MovieListViewModel(interactor: spyInteractor)
        
        // When
        await viewModel.loadMovies()
        
        // Then
        #expect(viewModel.errorMessage?.localizedCaseInsensitiveContains(argument.expectedContains) == true)
    }
    
    // MARK: - Delete Tests
    
    @Test(
        "Delete movie scenarios",
        arguments: [
            .init(movieExists: true, shouldSucceed: true),
            .init(movieExists: false, shouldSucceed: false)
        ] as [DeleteMovieArgument]
    )
    func deleteMovie(argument: DeleteMovieArgument) async {
        // Given
        let movieId = UUID()
        let movie = Movie(id: movieId, title: "Test", overview: "", releaseDate: Date(), posterURL: nil)
        
        if argument.movieExists {
            spyInteractor.moviesToReturn = [movie]
        }
        let viewModel = MovieListViewModel(interactor: spyInteractor)
        await viewModel.loadMovies()
        
        // When
        if argument.movieExists {
            await viewModel.deleteMovie(movie)
        }
        
        // Then
        if argument.shouldSucceed {
            #expect(viewModel.movies.isEmpty)
            #expect(spyInteractor.deleteMovieWasCalled == true)
            #expect(spyInteractor.lastDeletedMovieId == movieId)
        }
    }
}

// MARK: - Test Data

private extension MovieListViewModelTests {
    
    static let sampleMovies: [Movie] = [
        .init(id: UUID(), title: "The Avengers", overview: "", releaseDate: Date(), posterURL: nil),
        .init(id: UUID(), title: "Avengers: Endgame", overview: "", releaseDate: Date(), posterURL: nil),
        .init(id: UUID(), title: "Spider-Man", overview: "", releaseDate: Date(), posterURL: nil),
        .init(id: UUID(), title: "Iron Man", overview: "", releaseDate: Date(), posterURL: nil),
        .init(id: UUID(), title: "Thor", overview: "", releaseDate: Date(), posterURL: nil)
    ]
}

// MARK: - Arguments

private extension MovieListViewModelTests {
    
    struct FilterMoviesArgument: CustomTestStringConvertible {
        let searchText: String
        let expectedCount: Int
        
        var testDescription: String {
            "search '\(searchText)' → expects \(expectedCount) results"
        }
        
        init(searchText: String, expectedCount: Int) {
            self.searchText = searchText
            self.expectedCount = expectedCount
        }
    }
    
    struct HandleErrorArgument: CustomTestStringConvertible {
        let error: NetworkError
        let expectedContains: String
        
        var testDescription: String {
            "\(error) → expects message containing '\(expectedContains)'"
        }
        
        init(error: NetworkError, expectedContains: String) {
            self.error = error
            self.expectedContains = expectedContains
        }
    }
    
    struct DeleteMovieArgument: CustomTestStringConvertible {
        let movieExists: Bool
        let shouldSucceed: Bool
        
        var testDescription: String {
            "movie exists: \(movieExists) → should succeed: \(shouldSucceed)"
        }
        
        init(movieExists: Bool, shouldSucceed: Bool) {
            self.movieExists = movieExists
            self.shouldSucceed = shouldSucceed
        }
    }
}
```

## Test Suites with @Suite (Separate Files)

Organize sub-suites in separate files using extensions:

### File Structure

```
Tests/
└── Features/
    └── MovieDetail/
        ├── MovieDetailTests.swift           ← Main suite definition
        ├── MovieDetailTests+ViewModel.swift ← ViewModel sub-suite
        └── MovieDetailTests+Interactor.swift ← Interactor sub-suite
```

### MovieDetailTests.swift (Main Suite)

```swift
import Testing
@testable import MyApp

@Suite("Movie Detail Feature")
struct MovieDetailTests { }
```

### MovieDetailTests+ViewModel.swift

```swift
import Testing
@testable import MyApp

extension MovieDetailTests {
    
    @Suite("ViewModel Tests")
    @MainActor
    struct ViewModelTests {
        
        // MARK: - Subject Under Test
        
        let spyInteractor = SpyMovieDetailInteractor()
        
        // MARK: - Tests
        
        @Test("Load movie successfully")
        func loadMovieSuccess() async {
            // Given
            spyInteractor.movieToReturn = Self.sampleMovie
            let viewModel = MovieDetailViewModel(
                movieId: Self.sampleMovie.id,
                interactor: spyInteractor
            )
            
            // When
            await viewModel.loadMovie()
            
            // Then
            #expect(viewModel.movie == Self.sampleMovie)
            #expect(spyInteractor.fetchMovieWasCalled == true)
        }
        
        @Test(
            "Toggle favorite state",
            arguments: [
                .init(initialState: false, expectedState: true),
                .init(initialState: true, expectedState: false)
            ] as [ToggleFavoriteArgument]
        )
        func toggleFavorite(argument: ToggleFavoriteArgument) async {
            // Given
            spyInteractor.movieToReturn = Self.sampleMovie
            let viewModel = MovieDetailViewModel(movieId: UUID(), interactor: spyInteractor)
            await viewModel.loadMovie()
            viewModel.isFavorite = argument.initialState
            
            // When
            viewModel.isFavorite.toggle()
            
            // Then
            #expect(viewModel.isFavorite == argument.expectedState)
        }
    }
}

// MARK: - Test Data

private extension MovieDetailTests.ViewModelTests {
    
    static let sampleMovie = Movie(
        id: UUID(),
        title: "Sample Movie",
        overview: "A great movie",
        releaseDate: Date(),
        posterURL: nil
    )
}

// MARK: - Arguments

private extension MovieDetailTests.ViewModelTests {
    
    struct ToggleFavoriteArgument: CustomTestStringConvertible {
        let initialState: Bool
        let expectedState: Bool
        
        var testDescription: String {
            "initial: \(initialState) → expected: \(expectedState)"
        }
        
        init(initialState: Bool, expectedState: Bool) {
            self.initialState = initialState
            self.expectedState = expectedState
        }
    }
}
```

### MovieDetailTests+Interactor.swift

```swift
import Testing
@testable import MyApp

extension MovieDetailTests {
    
    @Suite("Interactor Tests")
    @MainActor
    struct InteractorTests {
        
        // MARK: - Subject Under Test
        
        let spyNetworkService = SpyNetworkService()
        
        // MARK: - Tests
        
        @Test("Fetch movie from network")
        func fetchMovieFromNetwork() async throws {
            // Given
            let interactor = MovieDetailInteractor(networkService: spyNetworkService)
            spyNetworkService.dataToReturn = Self.sampleMovieData
            
            // When
            let movie = try await interactor.fetchMovie(id: Self.sampleMovieId)
            
            // Then
            #expect(movie.id == Self.sampleMovieId)
            #expect(spyNetworkService.getWasCalled == true)
        }
    }
}

// MARK: - Test Data

private extension MovieDetailTests.InteractorTests {
    
    static let sampleMovieId = UUID()
    
    static let sampleMovieData = Movie(
        id: sampleMovieId,
        title: "Network Movie",
        overview: "Fetched from API",
        releaseDate: Date(),
        posterURL: nil
    )
}
```

## Using #expect Macro

```swift
// Basic assertions
#expect(viewModel.movies.count == 3)
#expect(viewModel.isLoading == false)
#expect(viewModel.errorMessage == nil)

// Optional checking
#expect(viewModel.selectedMovie != nil)
#expect(viewModel.selectedMovie?.title == "Test Movie")

// Collection assertions
#expect(viewModel.movies.isEmpty)
#expect(viewModel.movies.contains(where: { $0.id == movieId }))

// String assertions
#expect(viewModel.errorMessage?.contains("error") == true)

// Spy verifications
#expect(spyInteractor.fetchMoviesWasCalled == true)
#expect(spyInteractor.lastSavedMovie?.id == expectedId)

// Throws assertion
await #expect(throws: NetworkError.notFound) {
    try await interactor.fetchMovie(id: UUID())
}

// No throw assertion
await #expect(throws: Never.self) {
    try await interactor.saveMovie(.sample)
}
```

## Test Tags

```swift
extension Tag {
    @Tag static var viewModel: Self
    @Tag static var interactor: Self
    @Tag static var integration: Self
    @Tag static var slow: Self
}

@Test("Load movies", .tags(.viewModel))
func loadMovies() async { }

@Test("Network integration", .tags(.integration, .slow))
func networkIntegration() async { }
```

## Sample Data Pattern

Define test data as `static let` in private extensions within each test file:

```swift
// In MovieListTests+ViewModel.swift

// MARK: - Test Data

private extension MovieListTests.ViewModelTests {
    
    static let sampleMovies: [Movie] = [
        .init(id: UUID(), title: "The Avengers", overview: "", releaseDate: Date(), posterURL: nil),
        .init(id: UUID(), title: "Spider-Man", overview: "", releaseDate: Date(), posterURL: nil),
        .init(id: UUID(), title: "Iron Man", overview: "", releaseDate: Date(), posterURL: nil)
    ]
    
    static let sampleMovie = Movie(
        id: UUID(),
        title: "Sample Movie",
        overview: "A sample description.",
        releaseDate: Date(),
        posterURL: nil
    )
}

// Usage in tests
@Test("Load movies")
func loadMovies() async {
    // Given
    spyInteractor.moviesToReturn = Self.sampleMovies
    // ...
}
```

For shared sample data used across multiple test files, use Model extensions:

```swift
// In Tests/Shared/Movie+Samples.swift

extension Movie {
    static let sample = Movie(
        id: UUID(),
        title: "Shared Sample",
        overview: "Used across tests",
        releaseDate: Date(),
        posterURL: nil
    )
}
```

## Testing Best Practices

1. **One assertion focus**: Each @Test should verify one behavior
2. **Use Spies**: Track calls with `wasCalled` booleans and captured arguments
3. **Separate files per sub-suite**: Use extensions (`+ViewModel.swift`, `+Interactor.swift`)
4. **Static test data**: Define `static let` in private extensions for reusable data
5. **Structured arguments**: Use `CustomTestStringConvertible` for readable test names
6. **MARK structure**: Subject Under Test → Tests → Test Data → Arguments
7. **AAA pattern**: Arrange (Given), Act (When), Assert (Then)
8. **Explicit init**: Always provide explicit init in Argument structs
9. **Self.property**: Reference static data with `Self.sampleMovies`
10. **Feature-based organization**: Mirror source code folder structure
