# Swift Concurrency — Full Code Examples

> **Note**: These examples assume Strict Concurrency Checking = Complete. Check your project's concurrency settings in `CLAUDE.md`.

## Sendable Model

```swift
import Foundation

// ✅ Good — automatic Sendable via Codable + Hashable (value type)
struct Item: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    let name: String
    let createdAt: Date
}

// ✅ Good — enum with Sendable associated values
enum LoadingState: Sendable {
    case idle
    case loading
    case loaded([Item])    // [Item] is Sendable because Item is Sendable
    case error(String)     // String is Sendable
}
```

## @MainActor ViewModel

```swift
import Observation

@Observable
@MainActor
final class ItemListViewModel {

    // MARK: - Private Properties

    @ObservationIgnored
    private let interactor: ItemListInteractorProtocol

    @ObservationIgnored
    private var loadTask: Task<Void, Never>?

    // MARK: - Properties

    var items: [Item] = []
    var isLoading = false
    var errorMessage: String?

    // MARK: - Initializers

    init(interactor: ItemListInteractorProtocol = ItemListInteractor()) {
        self.interactor = interactor
    }
}
```

## Actor Inheritance — What NOT to Do

```swift
@MainActor
final class MyViewModel {

    var data: [Item] = []

    // ❌ WRONG — redundant @MainActor. Task already inherits the actor.
    func badPattern() {
        Task { @MainActor in
            let result = await fetch()
            self.data = result
        }
    }

    // ✅ CORRECT — Task inherits @MainActor from the enclosing class
    func goodPattern() {
        Task {
            let result = await fetch()
            self.data = result
        }
    }
}
```

## Stored Task — MUST use [weak self]

```swift
@MainActor
final class FeatureViewModel {

    @ObservationIgnored
    private var loadTask: Task<Void, Never>?

    @ObservationIgnored
    private var saveTask: Task<Void, Error>?

    var data: [Item] = []
    var hasLoadedData = false

    /// Non-throwing stored task
    @discardableResult
    func loadInitialDataIfNeeded() -> Task<Void, Never> {
        loadTask?.cancel()

        let task = Task { [weak self] in  // ← [weak self] REQUIRED
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

    /// Throwing stored task
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

## Fire-and-Forget Task — [weak self] Optional

```swift
@MainActor
final class ViewModel {
    var data: [Item] = []

    // Short-lived: strong capture OK
    func loadOnAppear() {
        Task {  // ← strong capture OK: no cycle, task completes quickly
            let data = await fetch()
            self.data = data
        }
    }

    // Long-running: [weak self] recommended
    func loadLongRunning() {
        Task { [weak self] in  // ← avoids keeping self alive for long duration
            guard let self else { return }
            let data = await self.longFetch()
            self.data = data
        }
    }
}
```

## System Callback → @MainActor Hop (Idiomatic)

When a **system callback** runs on a background queue (e.g. `WCSession`,
`URLSession`, `HKHealthStore`), the Task does **not** inherit `@MainActor`
from the enclosing class. You MUST annotate `Task { @MainActor in }` and
use `[weak self]` on the **outer** closure — then `guard let self` in the
inner Task to create a strong local binding.

```swift
@MainActor
final class WatchSessionManager {

    var isSyncing = false

    // ✅ CORRECT — @MainActor hop IS needed (callback is on bg queue)
    func requestFullSync() {
        WCSession.default.sendMessage(
            ["action": "requestFullSync"],
            replyHandler: { [weak self] _ in            // ← weak on outer
                Task { @MainActor in                     // ← @MainActor REQUIRED
                    guard let self else { return }       // ← strong local binding
                    self.isSyncing = false               // ← direct access, no chaining
                }
            },
            errorHandler: { [weak self] error in         // ← same pattern
                Task { @MainActor in
                    guard let self else { return }
                    self.isSyncing = false
                }
            }
        )
    }
}
```

### Why This Pattern

| Layer | Capture | Reason |
|-------|---------|--------|
| System callback (`replyHandler`) | `[weak self]` | Prevents keeping `self` alive if callback is retained |
| Inner `Task { @MainActor }` | Strong (via `guard let`) | Short-lived hop; the binding dies with the Task |
| Access to `self` | Direct (no `?.`) | Clean, no pyramid of optional chaining |

### When @MainActor on Task IS Needed

Task inherits the actor of its **enclosing function**, not its enclosing
**class**. When the Task is inside a non-isolated closure (system callback,
`Task.detached`, etc.), the annotation is **required**:

```swift
@MainActor
final class MyService {

    // ❌ Task inherits @MainActor — annotation is REDUNDANT
    func directMethod() {
        Task { @MainActor in ... }      // remove @MainActor
    }

    // ✅ Callback runs on bg queue — annotation is REQUIRED
    func withCallback() {
        someCallback { [weak self] in
            Task { @MainActor in ... }  // keep @MainActor
        }
    }
}
```

> **Contrast with SKILL.md line 82**: "never write `Task { @MainActor in }`
> inside a `@MainActor` class" applies to Tasks directly in method bodies,
> **not** to Tasks nested inside non-isolated closures.

## Custom Actor for Background Work

```swift
actor ImageCache {
    private var storage: [URL: Data] = [:]
    private var pendingRequests: [URL: Task<Data?, Never>] = [:]

    func image(for url: URL) async -> Data? {
        // Return cached data immediately
        if let data = storage[url] { return data }

        // Deduplicate concurrent requests for the same URL
        if let existing = pendingRequests[url] { return await existing.value }

        let task = Task<Data?, Never> {
            try? await Task.sleep(for: .seconds(1))  // simulate network
            return Data()  // placeholder
        }
        pendingRequests[url] = task

        let data = await task.value
        if let data { storage[url] = data }
        pendingRequests[url] = nil
        return data
    }

    func clear() {
        storage.removeAll()
        pendingRequests.removeAll()
    }
}
```

## Cancellation Patterns

```swift
@MainActor
final class SearchViewModel {

    @ObservationIgnored
    private var searchTask: Task<Void, Never>?

    var results: [Item] = []
    var isSearching = false

    func search(_ query: String) {
        // Cancel any in-flight search before starting a new one
        searchTask?.cancel()

        guard !query.isEmpty else {
            results = []
            return
        }

        searchTask = Task { [weak self] in
            guard let self else { return }

            // Debounce
            try? await Task.sleep(for: .milliseconds(300))

            // Check cancellation after suspend point
            guard !Task.isCancelled else { return }

            self.isSearching = true
            defer { self.isSearching = false }

            do {
                let items = try await self.interactor.search(query: query)

                // Check again — results might be stale if user typed more
                guard !Task.isCancelled else { return }

                self.results = items
            } catch is CancellationError {
                // Silently ignore — task was cancelled for a newer search
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
```

## @unchecked Sendable — NEVER Use

```swift
// ❌ TERRIBLE — silences the compiler, data races still happen
final class Cache: @unchecked Sendable {
    var storage: [String: Data] = [:]  // mutation from any thread!
}

// ✅ GOOD — use actor for shared mutable state
actor Cache {
    private var storage: [String: Data] = [:]

    func get(_ key: String) -> Data? { storage[key] }
    func set(_ key: String, _ data: Data) { storage[key] = data }
}

// ✅ ALSO GOOD — use @MainActor if it's UI-bound
@MainActor
final class UICache {
    private var storage: [String: Data] = [:]

    func get(_ key: String) -> Data? { storage[key] }
    func set(_ key: String, _ data: Data) { storage[key] = data }
}
```

## Sendable Closure Crossing Isolation

```swift
actor BackgroundWorker {
    typealias Completion = @Sendable (Result<Data, Error>) -> Void

    func process(_ items: [Item], completion: @escaping Completion) {
        Task.detached {
            do {
                let result = try await self.heavyProcessing(items)
                await completion(.success(result))
            } catch {
                await completion(.failure(error))
            }
        }
    }

    private func heavyProcessing(_ items: [Item]) async throws -> Data {
        // CPU-intensive work...
        try await Task.sleep(for: .seconds(1))
        return Data()
    }
}
```

## Decision Tree: Which Isolation to Use

| Scenario | Solution |
|----------|----------|
| UI state (ViewModels, Spies) | `@MainActor` |
| Shared mutable state (caches, stores) | Custom `actor` |
| Immutable data crossing boundaries | `Sendable` struct |
| Closures sent to other actors | `@Sendable` attribute |
| Class with mutable state crossing isolation | Redesign — use struct or actor |
| Suppressing a concurrency warning | **Never** — fix the root cause |
