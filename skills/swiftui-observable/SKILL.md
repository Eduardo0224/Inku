# SwiftUI with Observable Framework

## Description

Modern SwiftUI patterns using the Observation framework (`@Observable` macro) introduced in iOS 17. This skill covers ViewModels, property wrappers, MARK comment organization, async/await patterns, and pagination.

## When to Use

- Building iOS 17+ apps with SwiftUI
- Creating reactive ViewModels without `ObservableObject`
- Implementing Clean Architecture with MVVM pattern
- Apps requiring async/await networking
- Implementing infinite scroll pagination

## Rule 1: Use @Observable for ViewModels

**ALWAYS use `@Observable` macro. NEVER use `ObservableObject` with `@Published`.**

### Property Wrappers Decision Tree

```
What type of data is it?
│
├─ ViewModel (@Observable class) in View
│   └─ @State private var viewModel
│
├─ ViewModel passed from parent
│   └─ @Bindable var viewModel (if you need $binding)
│   └─ let viewModel (if read-only)
│
├─ Simple local value (Bool, String, Int)
│   └─ @State private var
│
├─ Two-way sync with parent
│   └─ @Binding var
│
├─ Property in @Observable that should NOT be observed
│   └─ @ObservationIgnored
│
└─ Environment value
    └─ @Environment(\.dismiss) / @Environment(Model.self)
```

### Quick Reference Table

| Wrapper | Context | Use Case |
|---------|---------|----------|
| `@State` | View owns @Observable | ViewModel creation |
| `@Bindable` | View receives @Observable | Need $binding to properties |
| `@Binding` | Primitive sync | Two-way Bool, String, etc. |
| `@Environment` | System/shared | dismiss, colorScheme, shared models |
| `@ObservationIgnored` | Inside @Observable | Non-reactive properties |

### ✅ Correct ViewModel

```swift
import Observation

@Observable
@MainActor
final class MovieDetailViewModel {

    // MARK: - Private Properties

    @ObservationIgnored
    private let interactor: MovieDetailInteractorProtocol

    @ObservationIgnored
    private let movieId: UUID

    // MARK: - Properties

    var movie: Movie?
    var isLoading = false
    var errorMessage: String?
    var isFavorite = false

    // MARK: - Initializers

    init(movieId: UUID, interactor: MovieDetailInteractorProtocol) {
        self.movieId = movieId
        self.interactor = interactor
    }

    // MARK: - Functions

    func loadMovie() async {
        isLoading = true
        defer { isLoading = false }

        do {
            movie = try await interactor.fetchMovie(id: movieId)
        } catch {
            handleError(error)
        }
    }

    // MARK: - Private Functions

    private func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
    }
}
```

### ❌ Incorrect (Old Pattern)

```swift
// ❌ DON'T USE ObservableObject
import Combine

class MovieDetailViewModel: ObservableObject {
    @Published var movie: Movie?  // ❌ Use @Observable instead
    @Published var isLoading = false
}
```

## Rule 2: View with @State Ownership

**Views own ViewModels using `@State` and inject Interactors via initializer.**

### ✅ Correct

```swift
struct MovieDetailView: View {

    // MARK: - States

    @State private var viewModel: MovieDetailViewModel

    // MARK: - Body

    var body: some View {
        ScrollView {
            if let movie = viewModel.movie {
                MovieContentView(movie: movie, viewModel: viewModel)
            }
        }
        .overlay { loadingOverlay }
        .task { await viewModel.loadMovie() }
    }

    // MARK: - Initializers

    init(movieId: UUID, interactor: MovieDetailInteractorProtocol = MovieDetailInteractor()) {
        self.viewModel = MovieDetailViewModel(movieId: movieId, interactor: interactor)
    }

    // MARK: - Private Views

    @ViewBuilder
    private var loadingOverlay: some View {
        if viewModel.isLoading {
            ProgressView()
        }
    }
}
```

### Using @Bindable for Child Views

```swift
struct MovieContentView: View {

    // MARK: - Properties

    let movie: Movie
    @Bindable var viewModel: MovieDetailViewModel

    // MARK: - Body

    var body: some View {
        VStack {
            Text(movie.title)

            // Can create bindings with $
            Toggle("Favorite", isOn: $viewModel.isFavorite)
        }
    }
}
```

## Rule 3: MARK Comment Structure

**ALL Swift files MUST follow this exact order:**

### MARK Order Reference

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

### Complete Example

```swift
import SwiftUI

struct MovieDetailView: View {

    // MARK: - Private Properties

    private let movieId: UUID

    // MARK: - States

    @State private var viewModel: MovieDetailViewModel
    @State private var showingShareSheet = false

    // MARK: - Bindings

    @Binding var selectedMovie: Movie?

    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    // MARK: - Properties

    var onDismiss: (() -> Void)?

    // MARK: - Body

    var body: some View {
        // Implementation
    }

    // MARK: - Initializers

    init(movieId: UUID, selectedMovie: Binding<Movie?>) {
        self.movieId = movieId
        self._selectedMovie = selectedMovie
        self.viewModel = MovieDetailViewModel(movieId: movieId)
    }

    // MARK: - Private Views

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
    MovieDetailView(movieId: UUID(), selectedMovie: .constant(nil))
}
```

### ViewModel MARK Structure

```swift
import Observation

@Observable
@MainActor
final class MovieDetailViewModel {

    // MARK: - Private Properties

    @ObservationIgnored
    private let interactor: MovieDetailInteractorProtocol

    @ObservationIgnored
    private let movieId: UUID

    // MARK: - Properties

    var movie: Movie?
    var isLoading = false
    var errorMessage: String?

    var formattedReleaseDate: String {
        // Computed property
        movie?.releaseDate.formatted(date: .long, time: .omitted) ?? "N/A"
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

## Rule 4: Async/Await Patterns

**Use `async/await` for all asynchronous operations. Never use completion handlers.**

### ViewModel with Async Operations

```swift
@Observable
@MainActor
final class MovieListViewModel {

    // MARK: - Private Properties

    @ObservationIgnored
    private let interactor: MovieListInteractorProtocol

    // MARK: - Properties

    var movies: [Movie] = []
    var isLoading = false
    var errorMessage: String?

    // MARK: - Initializers

    init(interactor: MovieListInteractorProtocol) {
        self.interactor = interactor
    }

    // MARK: - Functions

    func loadMovies() async {
        isLoading = true
        defer { isLoading = false }

        do {
            movies = try await interactor.fetchMovies()
            errorMessage = nil
        } catch {
            handleError(error)
        }
    }

    func deleteMovie(_ movie: Movie) async {
        do {
            try await interactor.deleteMovie(id: movie.id)
            movies.removeAll { $0.id == movie.id }
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

### View Integration with .task

```swift
struct MovieListView: View {

    // MARK: - States

    @State private var viewModel: MovieListViewModel

    // MARK: - Body

    var body: some View {
        NavigationStack {
            contentView
                .navigationTitle("Movies")
        }
        .task {
            await viewModel.loadMovies()  // ← Automatic cancellation
        }
        .refreshable {
            await viewModel.loadMovies()  // ← Pull to refresh
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
        } else {
            List(viewModel.movies) { movie in
                MovieRowView(movie: movie)
            }
        }
    }
}
```

## Rule 5: Pagination Pattern

**For infinite scrolling, track pagination state in ViewModel.**

### Pagination ViewModel

```swift
@Observable
@MainActor
final class MangaListViewModel {

    // MARK: - Private Properties

    @ObservationIgnored
    private let interactor: MangaListInteractorProtocol

    @ObservationIgnored
    private var currentPage = 1

    @ObservationIgnored
    private let itemsPerPage = 20

    // MARK: - Properties

    var mangas: [Manga] = []
    var isLoading = false
    var isLoadingMore = false  // Separate from initial loading
    var hasMorePages = true

    // MARK: - Initializers

    init(interactor: MangaListInteractorProtocol = MangaListInteractor()) {
        self.interactor = interactor
    }

    // MARK: - Functions

    func loadMangas() async {
        guard !isLoading else { return }

        isLoading = true
        currentPage = 1
        mangas = []
        defer { isLoading = false }

        do {
            let response = try await interactor.fetchMangas(page: currentPage, per: itemsPerPage)
            mangas = response.items
            hasMorePages = response.metadata.hasMorePages
        } catch {
            handleError(error)
        }
    }

    func loadMoreMangas() async {
        // Guard against multiple simultaneous loads
        guard !isLoadingMore, !isLoading, hasMorePages else { return }

        isLoadingMore = true
        defer { isLoadingMore = false }

        let nextPage = currentPage + 1

        do {
            let response = try await interactor.fetchMangas(page: nextPage, per: itemsPerPage)
            mangas.append(contentsOf: response.items)
            currentPage = nextPage
            hasMorePages = response.metadata.hasMorePages
        } catch {
            handleError(error)
        }
    }

    // MARK: - Private Functions

    private func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
    }
}
```

### Pagination in Views

```swift
struct MangaListView: View {

    // MARK: - States

    @State private var viewModel: MangaListViewModel

    // MARK: - Body

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.mangas) { manga in
                    MangaRowView(manga: manga)
                        .onAppear {
                            // Trigger load more when last item appears
                            if manga == viewModel.mangas.last {
                                Task {
                                    await viewModel.loadMoreMangas()
                                }
                            }
                        }
                }

                if viewModel.isLoadingMore {
                    ProgressView()
                        .padding()
                }
            }
            .padding()
        }
        .task { await viewModel.loadMangas() }
    }

    // MARK: - Initializers

    init(interactor: MangaListInteractorProtocol = MangaListInteractor()) {
        self.viewModel = MangaListViewModel(interactor: interactor)
    }
}
```

**Key Points**:
- Use `@ObservationIgnored` for pagination state (currentPage)
- Separate `isLoading` (initial) from `isLoadingMore` (pagination)
- Guard against multiple simultaneous loads
- Check last item with `manga == viewModel.mangas.last`
- Show loading indicator only during pagination

## Rule 6: Error Handling

**ViewModels handle errors and provide user-friendly messages.**

### Error Handling Pattern

```swift
@Observable
@MainActor
final class MangaListViewModel {

    var errorMessage: String?

    func loadMangas() async {
        do {
            let response = try await interactor.fetchMangas(page: 1, per: 20)
            mangas = response.items
        } catch {
            handleError(error)
        }
    }

    // MARK: - Private Functions

    private func handleError(_ error: Error) {
        // Log detailed error for debugging
        print("[MangaListViewModel] Error: \(error)")

        // Generic message to user (security)
        if let networkError = error as? NetworkError {
            errorMessage = L10n.Error.generic
        } else if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet:
                errorMessage = L10n.Error.network
            case .timedOut:
                errorMessage = L10n.Error.timeout
            case .cancelled:
                return  // Don't show error for cancelled requests
            default:
                errorMessage = L10n.Error.generic
            }
        } else {
            errorMessage = L10n.Error.generic
        }
    }
}
```

### Displaying Errors in Views

```swift
struct MangaListView: View {

    // MARK: - States

    @State private var viewModel: MangaListViewModel

    // MARK: - Body

    var body: some View {
        contentView
            .alert(
                L10n.Error.title,
                isPresented: Binding(
                    get: { viewModel.errorMessage != nil },
                    set: { if !$0 { viewModel.errorMessage = nil } }
                )
            ) {
                Button(L10n.Common.ok, role: .cancel) {
                    viewModel.errorMessage = nil
                }
                Button(L10n.Common.retry) {
                    Task { await viewModel.loadMangas() }
                }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
    }

    // MARK: - Private Views

    @ViewBuilder
    private var contentView: some View {
        // content
    }
}
```

## Rule 7: Modern Formatting APIs

**ALWAYS use `.formatted()` APIs. NEVER use legacy formatters.**

### ❌ DON'T USE (Legacy)

```swift
// ❌ String(format:)
let score = 8.41
let formatted = String(format: "%.2f", score)

// ❌ DateFormatter
let dateFormatter = DateFormatter()
dateFormatter.dateStyle = .medium
let formatted = dateFormatter.string(from: date)
```

### ✅ USE (Modern)

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
let formatted = date.formatted(date: .numeric, time: .omitted)
// Result: "12/22/2025"

// ✅ Custom date format
let customDate = date.formatted(.dateTime.day().month().year())
// Result: "Dec 22, 2025"

// ✅ Percentages
let progress = 0.847
let formatted = progress.formatted(.percent.precision(.fractionLength(1)))
// Result: "84.7%"
```

## Rule 8: API Endpoints Organization

**Use case-less enums as namespaces for API endpoints.**

### ✅ Correct Pattern

```swift
enum API {
    enum Endpoints {
        // MARK: - Manga List

        static let listMangas = "/list/mangas"
        static let listGenres = "/list/genres"

        // MARK: - Manga Filtering

        static func listMangaByGenre(_ genre: String) -> String {
            "/list/mangaByGenre/\(genre)"
        }

        // MARK: - Search

        static func searchManga(id: Int) -> String {
            "/search/manga/\(id)"
        }
    }

    enum Constants {
        static let defaultPageSize = 20
        static let maxPageSize = 100
    }
}

// Usage
func fetchMangas(page: Int, per: Int) async throws -> MangaListResponse {
    try await networkService.get(endpoint: API.Endpoints.listMangas, queryItems: queryItems)
}
```

### ❌ Incorrect (Hardcoded Strings)

```swift
// ❌ BAD
func fetchMangas() async throws -> MangaListResponse {
    try await networkService.get(endpoint: "/list/mangas")  // ❌ Hardcoded
}
```

## Checklist

When creating a new SwiftUI feature:

- [ ] ViewModel uses `@Observable` and `@MainActor`
- [ ] Non-observed properties use `@ObservationIgnored`
- [ ] View owns ViewModel with `@State private var`
- [ ] Dependencies injected via initializer with defaults
- [ ] All async operations use `async/await`
- [ ] MARK comments follow the exact order
- [ ] Pagination uses separate `isLoading` and `isLoadingMore`
- [ ] Error handling provides user-friendly messages
- [ ] Modern `.formatted()` APIs for all formatting
- [ ] API endpoints organized in case-less enum
- [ ] No `ObservableObject` or `@Published`
- [ ] `.task` used for automatic cancellation
- [ ] Computed properties for derived data

## Common Mistakes

### ❌ Mistake 1: Using ObservableObject

```swift
// ❌ BAD
class ViewModel: ObservableObject {
    @Published var items: [Item] = []
}
```

**Fix**: Use `@Observable` macro

### ❌ Mistake 2: Missing @ObservationIgnored

```swift
// ❌ BAD: Interactor will be observed (unnecessary)
@Observable
class ViewModel {
    private let interactor: InteractorProtocol
}
```

**Fix**: Add `@ObservationIgnored`

### ❌ Mistake 3: Wrong MARK Order

```swift
// ❌ BAD: Body before Properties
struct MyView: View {
    var body: some View { }

    let title: String  // ❌ Properties should be before Body
}
```

**Fix**: Follow MARK order exactly

### ❌ Mistake 4: Legacy Formatters

```swift
// ❌ BAD
let formatter = DateFormatter()
formatter.dateStyle = .medium
```

**Fix**: Use `.formatted()` APIs

## Examples

See complete implementations in:
- MangaListViewModel (pagination pattern)
- SearchViewModel (debouncing)
- CollectionViewModel (environment injection)

## Related Skills

- `skills/clean-architecture-ios/SKILL.md` - Architecture patterns
- `skills/swift-testing-patterns/SKILL.md` - Testing ViewModels
- `skills/swiftui-components/SKILL.md` - Component patterns
