# SwiftUI Patterns Specification

## Observation Framework (iOS 17+)

**ALWAYS use Observation framework. NEVER use ObservableObject/Published.**

### Property Wrappers Decision Tree

```
¿Qué tipo de dato es?
│
├─ ViewModel (@Observable class) en View
│   └─ @State private var viewModel
│
├─ ViewModel pasado desde padre
│   └─ @Bindable var viewModel (si necesitas $binding)
│   └─ let viewModel (si solo lectura)
│
├─ Valor local simple (Bool, String, Int)
│   └─ @State private var
│
├─ Sincronización bidireccional con padre
│   └─ @Binding var
│
├─ Propiedad en @Observable que NO debe observarse
│   └─ @ObservationIgnored
│
└─ Valor del Environment
    └─ @Environment(\.dismiss) / @Environment(Model.self)
```

### Quick Reference

| Wrapper | Context | Use Case |
|---------|---------|----------|
| `@State` | View owns @Observable | ViewModel creation |
| `@Bindable` | View receives @Observable | Need $binding to properties |
| `@Binding` | Primitive sync | Two-way Bool, String, etc. |
| `@Environment` | System/shared | dismiss, colorScheme, shared models |
| `@ObservationIgnored` | Inside @Observable | Non-reactive properties |

### ViewModel with @Observable

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

### View with @State for ViewModel

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

## ViewModel Type: Protocol vs Concrete Class

**Rule**: Use concrete class types for ViewModels unless there's a specific need for abstraction.

### When to Use Concrete Class (Recommended)

For ViewModels that are:
- ✅ Specific to a single View
- ✅ Not shared across multiple views
- ✅ Simple dependency injection via Interactor

```swift
struct MangaListView: View {
    // ✅ Use concrete type
    @State private var viewModel: MangaListViewModel

    init(interactor: MangaListInteractorProtocol = MangaListInteractor()) {
        self.viewModel = MangaListViewModel(interactor: interactor)
    }
}
```

**Why concrete class?**
- Clearer code (no protocol needed)
- View owns and creates the ViewModel
- Testing via Interactor injection (not ViewModel mocking)
- Simpler dependency graph

### When to Use Protocol

Only use protocol when:
- ⚠️ ViewModel is shared across multiple views
- ⚠️ Need to inject entire ViewModel (not recommended)
- ⚠️ Complex testing scenarios requiring ViewModel mocks

```swift
// ⚠️ Only if truly needed
protocol MangaListViewModelProtocol: Observable {
    var mangas: [Manga] { get }
    func loadMangas() async
}

struct MangaListView: View {
    @State private var viewModel: MangaListViewModelProtocol

    init(viewModel: MangaListViewModelProtocol) {
        self._viewModel = .init(initialValue: viewModel)
    }
}
```

**Important**: When using protocols, DO NOT include `AnyObject` constraint:

```swift
// ❌ WRONG
protocol MangaListViewModelProtocol: AnyObject, Observable { }

// ✅ CORRECT
protocol MangaListViewModelProtocol: Observable { }
```

The `Observable` protocol already requires reference semantics, so `AnyObject` is redundant and causes conflicts with `@Observable` macro.

## Error Handling Pattern

ViewModels should handle errors with security and user experience in mind:

1. **Log detailed errors** for debugging
2. **Show generic messages** to users (security)
3. **Provide specific messages** only for user-actionable errors (connectivity)

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
        // Log detailed error for debugging (use OSLog in production)
        print("[MangaListViewModel] Error: \(error)")

        // Generic message to user (security)
        if let networkError = error as? NetworkError {
            // Don't expose internal error details
            errorMessage = L10n.Error.generic
        } else if let urlError = error as? URLError {
            // Specific messages only for connectivity issues
            switch urlError.code {
            case .notConnectedToInternet:
                errorMessage = L10n.Error.network
            case .timedOut:
                errorMessage = L10n.Error.timeout
            case .cancelled:
                // Don't show error for cancelled requests
                return
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
    @State private var viewModel: MangaListViewModel

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
}
```

## Pagination Pattern

For infinite scrolling and paginated content:

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
}
```

### Pagination in Views

```swift
struct MangaListView: View {
    @State private var viewModel: MangaListViewModel

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
}
```

**Key Points**:
- Use `@ObservationIgnored` for pagination state (currentPage)
- Separate `isLoading` (initial) from `isLoadingMore` (pagination)
- Guard against multiple simultaneous loads
- Check last item with `manga == viewModel.mangas.last`
- Show loading indicator only during pagination

## View Componentization

### Rule: One component = One file

```
Views/
├── MovieDetailView.swift          ← Main container
└── Components/
    ├── MoviePosterView.swift      ← Poster image
    ├── MovieInfoSection.swift     ← Info section
    └── MovieActionsBar.swift      ← Action buttons
```

### Main View Pattern

```swift
struct MovieListView: View {
    
    // MARK: - States

    @State private var viewModel: MovieListViewModel
    @State private var showingFilters = false

    // MARK: - Body

    var body: some View {
        NavigationStack {
            contentView
                .navigationTitle(String(localized: "movies_title"))
                .searchable(text: $viewModel.searchText)
                .toolbar { toolbarContent }
        }
        .task { await viewModel.loadMovies() }
        .refreshable { await viewModel.loadMovies() }
        .sheet(isPresented: $showingFilters) {
            FiltersView()
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
            LoadingView()
        } else if let error = viewModel.errorMessage {
            ErrorView(message: error, retryAction: { Task { await viewModel.loadMovies() } })
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
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                showingFilters = true
            } label: {
                Image(systemName: "line.3.horizontal.decrease.circle")
            }
        }
    }
}
```

### Stateless Component Pattern

```swift
struct MovieRowView: View {
    
    // MARK: - Properties
    
    let movie: Movie
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: 12) {
            MoviePosterView(url: movie.posterURL, size: .small)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(movie.title)
                    .font(.headline)
                
                Text(movie.overview)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }
}
```

## @ViewBuilder Usage

`@ViewBuilder` is a parameter attribute that constructs views from closures. It can be used in:

1. **Closure parameters** (primary use)
2. **Computed properties** that return `some View`
3. **Functions** that return `some View`

### In Computed Properties

```swift
@ViewBuilder
private var statusView: some View {
    switch viewModel.state {
    case .loading:
        ProgressView()
    case .loaded(let data):
        ContentView(data: data)
    case .error(let message):
        ErrorView(message: message)
    }
}
```

### For Optional Content

```swift
@ViewBuilder
private var subtitleView: some View {
    if let subtitle = movie.tagline, !subtitle.isEmpty {
        Text(subtitle)
            .font(.subheadline)
            .foregroundStyle(.secondary)
    }
}
```

### In Custom Container Views

```swift
struct CardContainer<Content: View>: View {
    
    // MARK: - Properties
    
    @ViewBuilder var content: Content
    
    // MARK: - Body
    
    var body: some View {
        content
            .padding()
            .background(Color.surfaceSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// Usage
CardContainer {
    VStack {
        Text("Title")
        Text("Subtitle")
    }
}
```

## Custom View Modifiers

Use for reusable styling that applies multiple modifiers:

```swift
struct CardStyleModifier: ViewModifier {
    
    // MARK: - Properties
    
    var cornerRadius: CGFloat = 12
    var shadowRadius: CGFloat = 4
    
    // MARK: - Body
    
    func body(content: Content) -> some View {
        content
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(radius: shadowRadius)
    }
}

extension View {
    func cardStyle(cornerRadius: CGFloat = 12, shadowRadius: CGFloat = 4) -> some View {
        modifier(CardStyleModifier(cornerRadius: cornerRadius, shadowRadius: shadowRadius))
    }
}

// Usage
MovieInfoSection(movie: movie)
    .cardStyle()
```

## Preview Best Practices

### Using .traits

```swift
// MARK: - Previews

#Preview(
    "Movie Row",
    traits: .sizeThatFitsLayout
) {
    MovieRowView(movie: .sample)
        .padding()
}

#Preview(
    "Movie Row - Long Title",
    traits: .sizeThatFitsLayout
) {
    MovieRowView(movie: .sampleLongTitle)
        .padding()
}

#Preview(
    "Movie Row - Dark",
    traits: .sizeThatFitsLayout
) {
    MovieRowView(movie: .sample)
        .padding()
        .preferredColorScheme(.dark)
}
```

### Using @Previewable for State

```swift
#Preview("Toggle Favorite") {
    @Previewable @State var isFavorite = false
    
    FavoriteButton(isFavorite: $isFavorite)
        .padding()
}

#Preview("Search Field") {
    @Previewable @State var searchText = ""
    
    SearchField(text: $searchText)
        .padding()
}
```

### Container Previews with Spy Data

```swift
#Preview("Movie List - With Data") {
    let spyInteractor = SpyMovieListInteractor()
    spyInteractor.moviesToReturn = Movie.samples
    
    return NavigationStack {
        MovieListView(interactor: spyInteractor)
    }
}

#Preview("Movie List - Empty") {
    let spyInteractor = SpyMovieListInteractor()
    spyInteractor.moviesToReturn = []
    
    return NavigationStack {
        MovieListView(interactor: spyInteractor)
    }
}

#Preview("Movie List - Error") {
    let spyInteractor = SpyMovieListInteractor()
    spyInteractor.shouldThrowError = true
    
    return NavigationStack {
        MovieListView(interactor: spyInteractor)
    }
}
```

### Fixed Size Previews

```swift
#Preview(
    "Poster Small",
    traits: .fixedLayout(width: 100, height: 150)
) {
    MoviePosterView(url: .sample, size: .small)
}

#Preview(
    "Poster Large", 
    traits: .fixedLayout(width: 300, height: 450)
) {
    MoviePosterView(url: .sample, size: .large)
}
```

## Sample Data Extensions

```swift
extension Movie {
    static let sample = Movie(
        id: UUID(),
        title: "Sample Movie",
        overview: "A sample movie for previews.",
        releaseDate: Date(),
        posterURL: URL(string: "https://example.com/poster.jpg")
    )
    
    static let sampleLongTitle = Movie(
        id: UUID(),
        title: "The Incredibly Long Movie Title That Goes On Forever",
        overview: "Testing long titles.",
        releaseDate: Date(),
        posterURL: nil
    )
    
    static let samples: [Movie] = [
        sample,
        Movie(id: UUID(), title: "Another Movie", overview: "Description", releaseDate: Date(), posterURL: nil),
        Movie(id: UUID(), title: "Third Movie", overview: "More text", releaseDate: Date(), posterURL: nil)
    ]
}
```
