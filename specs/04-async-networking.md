# Async & Networking Specification

## Structured Concurrency Rules

1. **Always use `async/await`** for asynchronous operations
2. **Never use completion handlers** in new code
3. **Use `Task`** for bridging sync to async contexts
4. **Use `@MainActor`** for ViewModels and UI updates
5. **Mark Interactor protocols as `Sendable`**

## ViewModel Pattern with @Observable

```swift
import Observation

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

## View Integration

```swift
struct MovieListView: View {
    
    // MARK: - States

    @State private var viewModel: MovieListViewModel

    // MARK: - Body

    var body: some View {
        NavigationStack {
            contentView
                .navigationTitle(String(localized: "movies_title"))
        }
        .task {
            await viewModel.loadMovies()  // ← Automatic cancellation
        }
        .refreshable {
            await viewModel.loadMovies()  // ← Pull to refresh
        }
        .alert(
            String(localized: "error_title"),
            isPresented: showingError,
            actions: { Button(String(localized: "ok_button")) { viewModel.errorMessage = nil } },
            message: { Text(viewModel.errorMessage ?? "") }
        )
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
    
    private var showingError: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )
    }
}
```

## Network Service Protocol

```swift
protocol NetworkServiceProtocol: Sendable {
    func get<T: Decodable & Sendable>(endpoint: String) async throws -> T
    func post<T: Encodable & Sendable, R: Decodable & Sendable>(endpoint: String, body: T) async throws -> R
    func put<T: Encodable & Sendable, R: Decodable & Sendable>(endpoint: String, body: T) async throws -> R
    func delete(endpoint: String) async throws
}
```

## Network Service Implementation

```swift
final class NetworkService: NetworkServiceProtocol, Sendable {
    
    // MARK: - Private Properties

    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    // MARK: - Initializers

    init(
        baseURL: URL = URL(string: "https://api.example.com")!,
        session: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.session = session

        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder.dateDecodingStrategy = .iso8601

        self.encoder = JSONEncoder()
        self.encoder.keyEncodingStrategy = .convertToSnakeCase
        self.encoder.dateEncodingStrategy = .iso8601
    }
    
    // MARK: - Functions
    
    func get<T: Decodable & Sendable>(endpoint: String) async throws -> T {
        let url = baseURL.appendingPathComponent(endpoint)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        return try await perform(request)
    }
    
    func post<T: Encodable & Sendable, R: Decodable & Sendable>(endpoint: String, body: T) async throws -> R {
        let url = baseURL.appendingPathComponent(endpoint)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(body)
        
        return try await perform(request)
    }
    
    func put<T: Encodable & Sendable, R: Decodable & Sendable>(endpoint: String, body: T) async throws -> R {
        let url = baseURL.appendingPathComponent(endpoint)
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(body)
        
        return try await perform(request)
    }
    
    func delete(endpoint: String) async throws {
        let url = baseURL.appendingPathComponent(endpoint)
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let (_, response) = try await session.data(for: request)
        try validateResponse(response)
    }
    
    // MARK: - Private Functions
    
    private func perform<T: Decodable>(_ request: URLRequest) async throws -> T {
        let (data, response) = try await session.data(for: request)
        try validateResponse(response)
        return try decoder.decode(T.self, from: data)
    }
    
    private func validateResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            return
        case 401:
            throw NetworkError.unauthorized
        case 404:
            throw NetworkError.notFound
        case 422:
            throw NetworkError.validationError
        case 500...599:
            throw NetworkError.serverError(httpResponse.statusCode)
        default:
            throw NetworkError.unknown(httpResponse.statusCode)
        }
    }
}
```

## Custom Error Types

```swift
enum NetworkError: LocalizedError, CustomError {
    case invalidResponse
    case unauthorized
    case notFound
    case validationError
    case serverError(Int)
    case unknown(Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid server response"
        case .unauthorized:
            return "Authentication required"
        case .notFound:
            return "Resource not found"
        case .validationError:
            return "Validation failed"
        case .serverError(let code):
            return "Server error (\(code))"
        case .unknown(let code):
            return "Unexpected error (\(code))"
        }
    }
    
    var userMessage: String {
        switch self {
        case .unauthorized:
            return String(localized: "error_login_required")
        case .notFound:
            return String(localized: "error_not_found")
        case .serverError, .invalidResponse, .unknown, .validationError:
            return String(localized: "error_generic")
        }
    }
}

protocol CustomError: LocalizedError {
    var userMessage: String { get }
}
```

## Interactor Error Pattern

```swift
enum MovieInteractorError: LocalizedError, CustomError {
    case fetchFailed
    case saveFailed
    case deleteFailed
    case notFound
    
    var errorDescription: String? {
        switch self {
        case .fetchFailed: return "Failed to fetch movies"
        case .saveFailed: return "Failed to save movie"
        case .deleteFailed: return "Failed to delete movie"
        case .notFound: return "Movie not found"
        }
    }
    
    var userMessage: String {
        switch self {
        case .fetchFailed:
            return String(localized: "error_fetch_movies")
        case .saveFailed:
            return String(localized: "error_save_movie")
        case .deleteFailed:
            return String(localized: "error_delete_movie")
        case .notFound:
            return String(localized: "error_movie_not_found")
        }
    }
}
```

## Error Handling in ViewModel

```swift
private func handleError(_ error: Error) {
    if let customError = error as? CustomError {
        errorMessage = customError.userMessage
    } else if let urlError = error as? URLError {
        switch urlError.code {
        case .notConnectedToInternet:
            errorMessage = String(localized: "error_no_internet")
        case .timedOut:
            errorMessage = String(localized: "error_timeout")
        case .cancelled:
            return  // Don't show error for cancelled requests
        default:
            errorMessage = String(localized: "error_network")
        }
    } else {
        errorMessage = error.localizedDescription
    }
}
```

## Cancellation Pattern

```swift
// ✅ .task handles cancellation automatically
.task {
    await viewModel.loadMovies()
}

// ✅ Check for cancellation in long operations
func processItems(_ items: [Item]) async throws {
    for item in items {
        try Task.checkCancellation()
        await process(item)
    }
}

// ✅ Manual task management when needed
@Observable
@MainActor
final class SearchViewModel {
    
    @ObservationIgnored
    private var searchTask: Task<Void, Never>?
    
    var searchText = "" {
        didSet { performSearch() }
    }
    
    private func performSearch() {
        searchTask?.cancel()
        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(300))  // Debounce
            guard !Task.isCancelled else { return }
            await executeSearch()
        }
    }
}
```

## Parallel Requests

```swift
func loadDashboard() async {
    isLoading = true
    defer { isLoading = false }
    
    async let moviesResult = interactor.fetchMovies()
    async let genresResult = interactor.fetchGenres()
    async let featuredResult = interactor.fetchFeatured()
    
    do {
        let (movies, genres, featured) = try await (moviesResult, genresResult, featuredResult)
        self.movies = movies
        self.genres = genres
        self.featured = featured
    } catch {
        handleError(error)
    }
}
```
