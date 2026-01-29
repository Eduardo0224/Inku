# Swift Testing Patterns

## Description

Modern testing patterns using the Swift Testing framework (not XCTest). Includes Spy pattern for Interactors, parameterized testing with `@Test(arguments:)`, and test organization with `@Suite`.

## When to Use

- Testing iOS apps built with iOS 18+
- Unit testing ViewModels and Interactors
- Implementing Clean Architecture with testable components
- Creating parameterized tests with multiple scenarios
- Organizing tests by feature

## Rule 1: Use Swift Testing Framework

**ALWAYS use Swift Testing. NEVER use XCTest.**

### ✅ Correct

```swift
import Testing
@testable import MyApp

@Test("Load movies successfully")
func loadMoviesSuccess() async {
    // Test implementation
}
```

### ❌ Incorrect

```swift
import XCTest  // ❌ Don't use XCTest

class MovieTests: XCTestCase {  // ❌ Don't use XCTestCase
    func testLoadMovies() {  // ❌ Don't use test prefix
    }
}
```

## Rule 2: Spy Pattern for Interactors

**Create Spy implementations in test target to track method calls.**

### Implementation Locations

| Implementation | Location | Purpose |
|----------------|----------|---------|
| **Production** | `Features/{Feature}/Interactor/` | Real logic |
| **Mock** | `Features/{Feature}/Interactor/` | Previews |
| **Spy** | `{App}Tests/Shared/Spies/` | Unit tests |

### Spy Implementation Pattern

```swift
// In {App}Tests/Shared/Spies/SpyMovieInteractor.swift

import Testing
@testable import MyApp

final class SpyMovieInteractor: MovieInteractorProtocol, @unchecked Sendable {

    // MARK: - Spy Tracking (wasCalled properties)

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
    var errorToThrow: Error = NetworkError.serverError(500)

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
            throw NetworkError.notFound
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

### Key Spy Characteristics

- **`wasCalled` booleans**: Track if methods were invoked
- **`last*` properties**: Capture arguments passed to methods
- **Stub data**: `moviesToReturn`, `shouldThrowError` for controlling behavior
- **`reset()` method**: Clean state between tests
- **`@unchecked Sendable`**: Required for test concurrency

## Rule 3: ViewModel Tests with Subject Under Test

**Create SUT (Subject Under Test) in init for DRY tests.**

### ✅ Recommended Pattern (SUT in init)

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

**Benefits**:
- ✅ Less repetition (DRY principle)
- ✅ Clearer test intent (no setup noise)
- ✅ Named `sut` (Subject Under Test) for clarity
- ✅ Consistent test structure

## Rule 4: Parameterized Tests with Arguments

**Use `@Test(arguments:)` with custom structs for multiple scenarios.**

### Custom Argument Structs with CustomTestStringConvertible

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
}
```

**Key Points**:
- Argument structs in `private extension`
- Conform to `CustomTestStringConvertible` for readable test names
- Always provide explicit `init`
- Cast arguments array with `as [ArgumentType]`

## Rule 5: Test Suites with Separate Files

**Organize sub-suites in separate files using extensions.**

### File Structure

```
Tests/
└── Features/
    └── MovieDetail/
        ├── MovieDetailTests.swift           ← Main suite definition
        ├── MovieDetailTests+ViewModel.swift ← ViewModel sub-suite
        └── MovieDetailTests+Interactor.swift ← Interactor sub-suite
```

### Main Suite (MovieDetailTests.swift)

```swift
import Testing
@testable import MyApp

@Suite("Movie Detail Feature")
struct MovieDetailTests { }
```

### ViewModel Sub-Suite (MovieDetailTests+ViewModel.swift)

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

### Interactor Sub-Suite (MovieDetailTests+Interactor.swift)

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

## Rule 6: Use #expect Macro

**Use `#expect` for assertions, not `XCTAssert`.**

### Common Assertions

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

## Rule 7: Test Organization

**Follow consistent MARK structure in test files.**

### MARK Order for Tests

1. `// MARK: - Subject Under Test`
2. `// MARK: - Spies`
3. `// MARK: - Initializers` (if SUT in init)
4. `// MARK: - Tests`
5. `// MARK: - Test Data` (in private extension)
6. `// MARK: - Arguments` (in private extension)

### Complete Example

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

    @Test("Load movies")
    func loadMovies() async {
        // Test implementation
    }
}

// MARK: - Test Data

private extension MovieListViewModelTests {
    static let sampleMovies: [Movie] = []
}

// MARK: - Arguments

private extension MovieListViewModelTests {
    struct FilterArgument: CustomTestStringConvertible {
        let searchText: String
        let expectedCount: Int

        var testDescription: String {
            "search '\(searchText)' → \(expectedCount) results"
        }

        init(searchText: String, expectedCount: Int) {
            self.searchText = searchText
            self.expectedCount = expectedCount
        }
    }
}
```

## Rule 8: Sample Data Pattern

**Define test data as static in private extensions.**

### In Test Files

```swift
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

### Shared Sample Data

For data shared across multiple test files:

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

    static let samples: [Movie] = [
        sample,
        Movie(id: UUID(), title: "Second", overview: "", releaseDate: Date(), posterURL: nil)
    ]
}
```

## Rule 9: Test Tags

**Use tags to organize and filter tests.**

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

**Run specific tags:**
```bash
# Run only ViewModel tests
xcodebuild test -only-testing:MyAppTests/.tags.viewModel

# Run all except slow tests
xcodebuild test -skip-testing:MyAppTests/.tags.slow
```

## Checklist

When writing tests:

- [ ] Use `import Testing` (not XCTest)
- [ ] Create Spy in test target with `wasCalled` properties
- [ ] Tests are `@MainActor` if testing ViewModels
- [ ] Use SUT pattern in `init()` for DRY
- [ ] Argument structs conform to `CustomTestStringConvertible`
- [ ] Argument structs have explicit `init`
- [ ] Test organization: main suite + sub-suites in separate files
- [ ] MARK structure: SUT → Spies → Initializers → Tests → Test Data → Arguments
- [ ] Use `#expect` for assertions
- [ ] Static test data in private extensions
- [ ] Test names are descriptive (not just "test1", "test2")
- [ ] AAA pattern: Arrange (Given), Act (When), Assert (Then)

## Common Mistakes

### ❌ Mistake 1: Using XCTest

```swift
// ❌ BAD
import XCTest

class MovieTests: XCTestCase {
    func testLoadMovies() {
        XCTAssertTrue(true)
    }
}
```

**Fix**: Use Swift Testing

### ❌ Mistake 2: Missing CustomTestStringConvertible

```swift
// ❌ BAD: Unreadable test names
struct FilterArgument {
    let searchText: String
    let expectedCount: Int
}
```

**Fix**: Conform to `CustomTestStringConvertible`

### ❌ Mistake 3: Not Using SUT Pattern

```swift
// ❌ BAD: Repetition in every test
@Test("Test 1")
func test1() {
    let spy = SpyInteractor()
    let viewModel = ViewModel(interactor: spy)
    // ...
}

@Test("Test 2")
func test2() {
    let spy = SpyInteractor()  // ❌ Repeated
    let viewModel = ViewModel(interactor: spy)  // ❌ Repeated
    // ...
}
```

**Fix**: Create SUT in `init()`

### ❌ Mistake 4: Missing @MainActor

```swift
// ❌ BAD: Testing ViewModel without @MainActor
struct ViewModelTests {
    @Test
    func loadData() async {  // ❌ Will fail - ViewModel is @MainActor
        let viewModel = ViewModel()
    }
}
```

**Fix**: Add `@MainActor` to test struct

## Examples

See complete test implementations in:
- `InkuTests/Features/MangaList/MangaListTests+ViewModel.swift`
- `InkuTests/Features/Search/SearchTests+ViewModel.swift`
- `InkuTests/Features/Collection/CollectionTests+Interactor.swift`

## Related Skills

- `skills/clean-architecture-ios/SKILL.md` - Spy vs Mock distinction
- `skills/swiftui-observable/SKILL.md` - Testing ViewModels
