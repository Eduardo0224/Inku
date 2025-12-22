# Code Style Specification

## MARK Comments Structure

**All Swift files MUST follow this order:**

```swift
import SwiftUI

struct MovieDetailView: View {
    
    // MARK: - Private Properties
    // Only for: private let, private var WITHOUT property wrappers

    private let movieId: UUID
    
    // MARK: - States
    // For: @State, @Bindable, @AppStorage, @SceneStorage
    
    @State private var viewModel: MovieDetailViewModel
    @State private var showingShareSheet = false
    @AppStorage("lastViewedMovieId") private var lastViewedId: String?
    
    // MARK: - Bindings
    // For: @Binding only
    
    @Binding var selectedMovie: Movie?
    
    // MARK: - Environment
    // For: @Environment
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    // MARK: - Properties
    // For: let, var (public/internal, no wrappers)

    var onDismiss: (() -> Void)?
    
    // MARK: - Body

    var body: some View {
        // Implementation
    }

    // MARK: - Initializers

    init(movieId: UUID, interactor: MovieDetailInteractorProtocol = MovieDetailInteractor()) {
        self.movieId = movieId
        self.viewModel = MovieDetailViewModel(movieId: movieId, interactor: interactor)
    }

    // MARK: - Private Views
    // For: @ViewBuilder private var
    
    @ViewBuilder
    private var loadingView: some View {
        ProgressView()
    }
    
    // MARK: - Private Functions
    
    private func handleError(_ error: Error) {
        // Error handling
    }
    
    // MARK: - Functions
    
    func refreshData() {
        // Public function
    }
}

// MARK: - Extensions

extension MovieDetailView {
    // Extensions if needed
}

// MARK: - Previews

#Preview("Movie Detail") {
    MovieDetailView(movieId: UUID())
}
```

## MARK Order Quick Reference

| Order | MARK | Contents |
|-------|------|----------|
| 1 | Private Properties | `private let/var` **without** property wrappers |
| 2 | States | `@State`, `@Bindable`, `@AppStorage`, `@SceneStorage` |
| 3 | Bindings | `@Binding` only |
| 4 | Environment | `@Environment` |
| 5 | Properties | `let`, `var` (public/internal, no wrappers) |
| 6 | Body | `var body: some View` |
| 7 | Initializers | `init()` methods |
| 8 | Private Views | `@ViewBuilder private var` |
| 9 | Private Functions | `private func` |
| 10 | Functions | `func` (public/internal) |
| 11 | Extensions | `extension TypeName` |
| 12 | Previews | `#Preview` |

## ViewModel MARK Structure

```swift
import Observation

@Observable
@MainActor
final class MovieDetailViewModel {
    
    // MARK: - Private Properties
    // Non-observed dependencies and internal state
    
    @ObservationIgnored
    private let interactor: MovieDetailInteractorProtocol
    
    @ObservationIgnored
    private let movieId: UUID
    
    // MARK: - Properties
    // Observable properties (no wrapper needed with @Observable)
    
    var movie: Movie?
    var isLoading = false
    var errorMessage: String?
    
    var formattedReleaseDate: String {
        // Computed property
    }

    // MARK: - Initializers

    init(movieId: UUID, interactor: MovieDetailInteractorProtocol) {
        self.movieId = movieId
        self.interactor = interactor
    }

    // MARK: - Functions
    
    func loadMovie() async {
        // ...
    }
    
    // MARK: - Private Functions
    
    private func handleError(_ error: Error) {
        // ...
    }
}
```

## Naming Conventions

| Element | Convention | Example |
|---------|------------|---------|
| Files | PascalCase | `MovieDetailView.swift` |
| Types | PascalCase | `MovieInteractor` |
| Protocols | PascalCase + Protocol | `MovieInteractorProtocol` |
| Variables/Functions | camelCase | `fetchMovies()` |
| Constants | camelCase | `let maxRetries = 3` |
| Enum cases | camelCase | `case loading, success, error` |
| Feature folders | PascalCase | `MovieDetail/` |

## File Organization per Feature

```
MovieDetail/
├── Models/
│   └── MovieDetailModel.swift
├── Interactor/
│   ├── Protocols/
│   │   └── MovieDetailInteractorProtocol.swift
│   ├── MovieDetailInteractor.swift
│   └── MockMovieDetailInteractor.swift
├── ViewModel/
│   └── MovieDetailViewModel.swift
└── Views/
    ├── MovieDetailView.swift
    └── Components/
        ├── MoviePosterView.swift
        ├── MovieInfoSection.swift
        └── MovieActionsBar.swift
```

## Preview Organization

### Component Previews (rows, cells, small views)

```swift
// MARK: - Previews

#Preview(
    "Movie Row",
    traits: .sizeThatFitsLayout
) {
    MovieRowView(movie: .sample)
        .padding()
}
```

### Screen Previews (full screens)

```swift
// MARK: - Previews

#Preview("Default") {
    NavigationStack {
        MovieDetailView(movieId: .sample)
    }
}

#Preview("Dark Mode") {
    NavigationStack {
        MovieDetailView(movieId: .sample)
    }
    .preferredColorScheme(.dark)
}
```

### Previews with @Previewable

```swift
// MARK: - Previews

#Preview("Interactive Toggle") {
    @Previewable @State var isEnabled = false
    
    SettingsToggle(
        title: "Notifications",
        isEnabled: $isEnabled
    )
    .padding()
}
```

## Sample Data Pattern

```swift
// In Models/Movie.swift or separate PreviewData.swift

extension Movie {
    static let sample = Movie(
        id: UUID(),
        title: "Sample Movie",
        overview: "A sample movie description.",
        releaseDate: Date(),
        posterURL: URL(string: "https://example.com/poster.jpg")
    )
    
    static let samples: [Movie] = [
        sample,
        Movie(id: UUID(), title: "Second Movie", overview: "Another description.", releaseDate: Date(), posterURL: nil)
    ]
}

extension UUID {
    static let sample = UUID()
}
```

## Comments Rules

1. **Language**: English only
2. **Self-documenting code**: Prefer clear names over comments
3. **When to comment**:
   - Complex algorithms
   - Non-obvious business logic
   - API quirks or workarounds
   - TODO/FIXME items

```swift
// ✅ Good: Explains WHY
// Using folding to handle Spanish accents (café → cafe)
let normalized = text.foldingDiacritics

// ❌ Bad: Explains WHAT (obvious from code)
// Increment counter by one
counter += 1
```

## Code Formatting

### Spacing

```swift
// ✅ Good: Blank line after MARK
// MARK: - Properties

let movie: Movie

// ✅ Good: Blank line between logical sections
func loadData() async {
    isLoading = true
    
    do {
        data = try await interactor.fetch()
    } catch {
        handleError(error)
    }
    
    isLoading = false
}
```

### Line Length

- Soft limit: 100 characters
- Hard limit: 120 characters
- Break long lines at logical points

```swift
// ✅ Good: Readable line breaks
init(
    movieId: UUID,
    interactor: MovieDetailInteractorProtocol = MovieDetailInteractor()
) {
    self.viewModel = MovieDetailViewModel(
        movieId: movieId,
        interactor: interactor
    )
}
```

### Trailing Closures

```swift
// ✅ Single trailing closure
Button("Save") {
    viewModel.save()
}

// ✅ Multiple closures - use labels
Button {
    viewModel.save()
} label: {
    Label("Save", systemImage: "square.and.arrow.down")
}
```

## Modern Formatting APIs

**Always use modern `.formatted()` APIs instead of legacy formatters.**

This is a fundamental rule for modern Swift development. The new formatting APIs are:
- More concise and readable
- Type-safe
- Localization-aware by default
- Part of Swift's declarative API design

### ❌ DON'T USE (Legacy APIs)

```swift
// ❌ String(format:) for numbers
let score = 8.41
let formatted = String(format: "%.2f", score)

// ❌ DateFormatter for dates
let dateFormatter = DateFormatter()
dateFormatter.dateStyle = .medium
let formatted = dateFormatter.string(from: date)

// ❌ NumberFormatter for numbers
let numberFormatter = NumberFormatter()
numberFormatter.numberStyle = .currency
let formatted = numberFormatter.string(from: NSNumber(value: price))
```

### ✅ USE (Modern APIs)

```swift
// ✅ Numbers with precision
let score = 8.41
let formatted = score.formatted(.number.precision(.fractionLength(2)))
// Result: "8.41"

// ✅ Currency
let price = 1299.99
let formatted = price.formatted(.currency(code: "USD"))
// Result: "$1,299.99"

// ✅ Dates
let date = Date()

// Predefined styles
let formatted = date.formatted(date: .numeric, time: .omitted)
// Result: "12/22/2025"

// Custom format
let customDate = date.formatted(.dateTime.day().month().year())
// Result: "Dec 22, 2025"

let fullDate = date.formatted(date: .long, time: .shortened)
// Result: "December 22, 2025 at 3:30 PM"

// ✅ Lists
let items = ["Manga", "Anime", "Novel"]
let formatted = items.formatted(.list(type: .and))
// Result: "Manga, Anime, and Novel"

// ✅ Percentages
let progress = 0.847
let formatted = progress.formatted(.percent.precision(.fractionLength(1)))
// Result: "84.7%"
```

### Common Use Cases

```swift
// Score display (2 decimal places)
var formattedScore: String {
    guard let score = score else { return "N/A" }
    return score.formatted(.number.precision(.fractionLength(2)))
}

// Price display
var formattedPrice: String {
    price.formatted(.currency(code: "USD"))
}

// Date range
var dateRange: String {
    guard let start = startDate, let end = endDate else { return "" }
    return "\(start.formatted(date: .abbreviated, time: .omitted)) - \(end.formatted(date: .abbreviated, time: .omitted))"
}

// Publication status
var statusDisplay: String {
    if let start = startDate {
        if let end = endDate {
            return "Published \(start.formatted(date: .numeric, time: .omitted)) - \(end.formatted(date: .numeric, time: .omitted))"
        }
        return "Publishing since \(start.formatted(date: .long, time: .omitted))"
    }
    return "TBA"
}
```

### Why This Rule Matters

1. **Automatic Localization**: `.formatted()` respects user locale settings automatically
2. **Type Safety**: Compile-time checking prevents formatting errors
3. **Consistency**: Unified API across number, date, and list formatting
4. **Modern Swift**: Aligns with current Swift best practices
5. **Less Code**: More concise than configuring formatter objects

## No Deprecated APIs

**CRITICAL RULE: Never use deprecated APIs. Always use the modern replacement.**

Deprecated APIs may be removed in future Swift/iOS versions and are marked as deprecated because better alternatives exist. This is one of the most important rules in the codebase.

### Common Deprecated APIs to Avoid

```swift
// ❌ DEPRECATED: appendingPathComponent(_:)
let url = baseURL.appendingPathComponent("path")

// ✅ MODERN: appending(path:directoryHint:)
let url = baseURL.appending(path: "path", directoryHint: .notDirectory)

// ❌ DEPRECATED: appendingPathComponent(_:isDirectory:)
let url = baseURL.appendingPathComponent("directory", isDirectory: true)

// ✅ MODERN: appending(path:directoryHint:)
let url = baseURL.appending(path: "directory", directoryHint: .isDirectory)
```

### Checking for Deprecated APIs

1. **Xcode Warnings**: Pay attention to deprecation warnings
2. **Build Warnings**: Treat deprecation warnings as errors (configure in build settings)
3. **Code Review**: Always check API documentation when uncertain
4. **Use Latest APIs**: When multiple options exist, prefer the newest

### Why This Rule Matters

1. **Future-Proofing**: Deprecated APIs will eventually be removed
2. **Performance**: Modern APIs are often optimized and more efficient
3. **Type Safety**: Newer APIs typically have better type safety
4. **Best Practices**: Staying current with API evolution ensures code quality
5. **Maintainability**: Reduces technical debt and future refactoring needs

## API Endpoints Organization

**Use case-less enums as namespaces to organize API endpoints and constants.**

Case-less enums (enums without cases) serve as namespaces in Swift, similar to namespaces in other languages. This pattern is used extensively in iOS frameworks (e.g., `UIFont.TextStyle`, `Calendar.Component`).

### Pattern: Case-less Enum as Namespace

```swift
// ✅ GOOD: Organized endpoints using case-less enum
enum API {
    enum Endpoints {
        // MARK: - Manga List

        static let listMangas = "/list/mangas"
        static let listGenres = "/list/genres"
        static let listDemographics = "/list/demographics"
        static let listThemes = "/list/themes"

        // MARK: - Manga Filtering

        static func listMangaByGenre(_ genre: String) -> String {
            "/list/mangaByGenre/\(genre)"
        }

        static func listMangaByDemographic(_ demographic: String) -> String {
            "/list/mangaByDemographic/\(demographic)"
        }

        static func listMangaByTheme(_ theme: String) -> String {
            "/list/mangaByTheme/\(theme)"
        }

        // MARK: - Search

        static func searchManga(id: Int) -> String {
            "/search/manga/\(id)"
        }

        static func searchMangaContains(_ text: String) -> String {
            "/search/mangasContains/\(text)"
        }
    }

    enum Constants {
        static let defaultPageSize = 20
        static let maxPageSize = 100
    }
}

// Usage in Interactor
func fetchMangas(page: Int, per: Int) async throws -> MangaListResponse {
    try await networkService.get(endpoint: API.Endpoints.listMangas, queryItems: queryItems)
}

func fetchMangasByGenre(_ genre: String, page: Int, per: Int) async throws -> MangaListResponse {
    try await networkService.get(endpoint: API.Endpoints.listMangaByGenre(genre), queryItems: queryItems)
}
```

```swift
// ❌ BAD: Hardcoded strings scattered throughout code
func fetchMangas() async throws -> MangaListResponse {
    try await networkService.get(endpoint: "/list/mangas")
}

func fetchMangasByGenre(_ genre: String) async throws -> MangaListResponse {
    try await networkService.get(endpoint: "/list/mangaByGenre/\(genre)")
}
```

### Benefits

1. **Centralization**: All endpoints in one place, easy to find and update
2. **Type Safety**: Compile-time checking for endpoint strings
3. **Autocomplete**: Better IDE support with structured namespaces
4. **Consistency**: Follows iOS framework patterns (e.g., `UIFont.TextStyle.body`)
5. **Maintainability**: Changes to endpoint structure happen in one location
6. **Documentation**: Natural place to document API structure

### Other Uses for Case-less Enums

```swift
// UI Constants
enum InkuSpacing {
    static let spacing4: CGFloat = 4
    static let spacing8: CGFloat = 8
    static let spacing16: CGFloat = 16
    static let spacing24: CGFloat = 24
}

// Configuration
enum AppConfig {
    static let apiBaseURL = "https://api.example.com"
    static let timeout: TimeInterval = 30
    static let maxRetries = 3
}

// Analytics Events
enum AnalyticsEvents {
    static let mangaViewed = "manga_viewed"
    static let mangaAddedToCollection = "manga_added_to_collection"

    static func searchPerformed(query: String) -> String {
        "search_performed_\(query.count)_chars"
    }
}
```
