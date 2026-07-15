# SwiftUI + Observable — Full Code Examples

> **Note**: These examples use `L10n` as the localization enum and `Movie` as the domain model. Adapt to your project's conventions (check `CLAUDE.md`).

## ViewModel with Pagination

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

    @ObservationIgnored
    private let itemsPerPage = 20

    // MARK: - Properties

    var movies: [Movie] = []
    var isLoading = false
    var isLoadingMore = false
    var hasMorePages = true
    var errorMessage: String?

    // MARK: - Initializers

    init(interactor: MovieListInteractorProtocol = MovieListInteractor()) {
        self.interactor = interactor
    }

    // MARK: - Functions

    func loadMovies() async {
        guard !isLoading else { return }

        isLoading = true
        currentPage = 1
        movies = []
        defer { isLoading = false }

        do {
            let response = try await interactor.fetchMovies(page: currentPage, per: itemsPerPage)
            movies = response.items
            hasMorePages = response.metadata.hasMorePages
            errorMessage = nil
        } catch {
            handleError(error)
        }
    }

    func loadMoreMovies() async {
        guard !isLoadingMore, !isLoading, hasMorePages else { return }

        isLoadingMore = true
        defer { isLoadingMore = false }

        let nextPage = currentPage + 1

        do {
            let response = try await interactor.fetchMovies(page: nextPage, per: itemsPerPage)
            movies.append(contentsOf: response.items)
            currentPage = nextPage
            hasMorePages = response.metadata.hasMorePages
        } catch {
            handleError(error)
        }
    }

    // MARK: - Private Functions

    private func handleError(_ error: Error) {
        print("[MovieListViewModel] Error: \(error)")

        if let networkError = error as? NetworkError {
            // Adapt to your project's localization enum (see CLAUDE.md)
            errorMessage = networkError.userMessage
        } else if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet: errorMessage = "No internet connection"
            case .timedOut: errorMessage = "Request timed out"
            case .cancelled: return
            default: errorMessage = "Something went wrong"
            }
        } else {
            errorMessage = "Something went wrong"
        }
    }
}
```

## View with All States

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
        .task { await viewModel.loadMovies() }
        .refreshable { await viewModel.loadMovies() }
        .alert(
            "Error",
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) { viewModel.errorMessage = nil }
            Button("Retry") { Task { await viewModel.loadMovies() } }
        } message: {
            if let message = viewModel.errorMessage { Text(message) }
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
        } else if viewModel.movies.isEmpty {
            EmptyView(icon: "film", title: "No movies found")
        } else {
            movieList
        }
    }

    private var movieList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.movies) { movie in
                    MovieRowView(movie: movie)
                        .onAppear {
                            if movie == viewModel.movies.last {
                                Task { await viewModel.loadMoreMovies() }
                            }
                        }
                }

                if viewModel.isLoadingMore {
                    ProgressView().padding()
                }
            }
            .padding()
        }
    }
}
```

## API Endpoints Enum

```swift
enum API {
    enum Endpoints {
        // MARK: - Movie List

        static let listMovies = "/movies"
        static let listGenres = "/genres"

        // MARK: - Filtering

        static func listMoviesByGenre(_ genre: String) -> String {
            "/movies/genre/\(genre)"
        }

        // MARK: - Search

        static func searchMovie(id: Int) -> String {
            "/movies/\(id)"
        }
    }

    enum Constants {
        static let defaultPageSize = 20
        static let maxPageSize = 100
    }
}
```

## Task Management in @MainActor ViewModel

### Stored Task — MUST use `[weak self]`

Self owns the task → retain cycle without `[weak self]`:
`self → loadTask (Task struct) → closure → self`

```swift
@MainActor
final class FeatureViewModel {

    @ObservationIgnored
    private var loadTask: Task<Void, Never>?

    @ObservationIgnored
    private var saveTask: Task<Void, Error>?

    var data: [Item] = []
    var hasLoadedData = false

    /// Non-throwing stored task — uses [weak self] + guard !Task.isCancelled.
    @discardableResult
    func loadInitialDataIfNeeded() -> Task<Void, Never> {
        loadTask?.cancel()

        let task = Task { [weak self] in  // ← [weak self] REQUIRED: self stores the task
            guard let self, !Task.isCancelled else { return }

            async let items: Void = self.fetchItems()
            async let metadata: Void = self.fetchMetadata()
            _ = await (items, metadata)

            guard !Task.isCancelled else { return }

            self.hasLoadedData = true
        }

        loadTask = task
        return task
    }

    /// Throwing stored task — uses [weak self] + try Task.checkCancellation().
    func saveData(_ item: Item) async throws {
        saveTask?.cancel()

        let task = Task { [weak self] in  // ← [weak self] REQUIRED
            guard let self else { return }
            try Task.checkCancellation()
            let result = try await self.apiService.save(item)
            try Task.checkCancellation()
            self.data.append(result)
        }

        saveTask = task
        return try await task.value
    }
}
```

### Fire-and-Forget Task — `[weak self]` optional

No cycle exists (task not stored on self). Strong capture keeps self alive until completion — acceptable for short work.

```swift
@MainActor
final class ViewModel {
    func loadOnAppear() {
        Task {  // ← strong capture OK: fire-and-forget, no cycle
            let data = await fetch()
            self.data = data  // self released when task completes
        }
    }

    func loadLongRunning() {
        Task { [weak self] in  // ← [weak self] recommended: avoid keeping self alive too long
            guard let self else { return }
            let data = await self.longFetch()
            self.data = data
        }
    }
}
```

**Decision tree:**
- `self` stores the task as property → `[weak self]` **required** (retain cycle)
- Fire-and-forget, short-lived → strong capture **OK** (no cycle)
- Fire-and-forget, long-running → `[weak self]` **recommended** (lifetime preference)
- `.task {}` modifier (SwiftUI) → no `[weak self]` needed (auto-cancelled)
