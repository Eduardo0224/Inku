---
name: swiftui-observable
description: >-
  Modern SwiftUI patterns with Observation framework (@Observable macro, iOS 17+).
  Covers ViewModels, property wrappers, MARK comment ordering, async/await, pagination,
  and error handling. Use when creating SwiftUI views, building ViewModels, implementing
  pagination, handling async state, or user mentions "@Observable", "@State", "ViewModel",
  "async/await SwiftUI", "pagination", or "Observation framework".
user-invocable: true
when_to_use: |
  When creating SwiftUI views, building ViewModels, implementing pagination, or handling async state. When the user mentions "@Observable", "@State", "ViewModel", "async/await SwiftUI", "pagination", "Observation framework", or "MARK comment".
---

## Overview

Always use `@Observable` (iOS 17+) for ViewModels — never `ObservableObject` with `@Published`. Views own ViewModels via `@State`. All async work uses `async/await`. Pagination uses separate loading states for initial load vs. loading more.

> **Project-specific settings**: Before applying this skill, check `CLAUDE.md` for:
> - Minimum deployment target (determines available APIs)
> - Localization pattern (enum name, string catalog structure)
> - API endpoint organization convention
> - Design system / UI package name

## Instructions

1. **Create ViewModel** — `@Observable @MainActor final class`, inject Interactor via `init`
2. **Mark non-observed dependencies** — `@ObservationIgnored` on Interactor, page counters, IDs
3. **Create View** — own ViewModel via `@State private var`, inject Interactor in `init`
4. **Add async behavior** — `.task {}` for initial load, `.refreshable {}` for pull-to-refresh
5. **Handle errors** — catch in ViewModel, set `errorMessage`, display via `.alert()`
6. **Add pagination** — separate `isLoading` (initial) from `isLoadingMore` (pagination), guard against concurrent loads

## Rules

### Property Wrappers

- **`@State`** — View owns an `@Observable` ViewModel → `@State private var viewModel`
- **`@Bindable`** — Child view receives parent's `@Observable` and needs `$` bindings → `@Bindable var viewModel`
- **`@Binding`** — Primitive two-way sync (Bool, String) → `@Binding var isPresented`
- **`@Environment`** — System values (dismiss, colorScheme) or shared models → `@Environment(\.dismiss)`
- **`@ObservationIgnored`** — Inside `@Observable`, properties that should NOT trigger UI updates → `@ObservationIgnored private let interactor`

### ViewModel Rules

- Mark with `@Observable` and `@MainActor`
- Inject Interactor via `init` with protocol type and default value
- Mark Interactor and internal state (page numbers, IDs) as `@ObservationIgnored`
- Use computed properties for derived data (`filteredItems`, `formattedDate`)
- Set `isLoading = true` with `defer { isLoading = false }` for all async operations
- Handle errors in a private `handleError(_:)` method — never expose raw errors to UI

### View Rules

- Own ViewModel via `@State private var`
- Inject Interactor in `init`, pass to ViewModel
- Use `.task { await viewModel.loadData() }` for automatic load-on-appear with cancellation
- Use `.refreshable { await viewModel.loadData() }` for pull-to-refresh
- Use `@ViewBuilder` computed properties for conditional content (loading/error/empty/data)
- Never call business logic directly — always delegate to ViewModel

### Pagination Rules

- Track `currentPage` and `itemsPerPage` as `@ObservationIgnored` in ViewModel
- Use separate `isLoading` (initial/full reload) and `isLoadingMore` (append) flags
- Guard every load function: `guard !isLoading, !isLoadingMore, hasMorePages else { return }`
- Trigger `loadMore` when the last item appears: `if item == viewModel.items.last { Task { await viewModel.loadMore() } }`
- Show `ProgressView` only during `isLoadingMore`, not during initial `isLoading`
- Reset `currentPage = 1` and clear array on full reload

### Async/Await Rules

- Use `.task {}` for lifecycle-bound async work (auto-cancelled on view disappear)
- Use `async/await` for all network and database operations — never completion handlers
- `defer` for resetting loading flags — ensures cleanup even on error
- Handle `URLError.cancelled` silently — don't show errors for cancelled tasks

### Task Management in @MainActor ViewModels

**`[weak self]` depends on whether `self` owns the Task:**

- **Task stored as property** (`self.loadTask = task`) → MUST use `[weak self]` — forms a retain cycle: `self → task → closure → self`
- **Fire-and-forget Task** (not stored, not awaited) → `[weak self]` optional — no cycle, but keeps `self` alive until completion
- **`.task {}` modifier** → no `[weak self]` needed — SwiftUI auto-cancels when view disappears

- **DO** return `Task<Void, Never>` with `@discardableResult` from methods that start async work — allows callers to cancel or await
- **DO** store task references as `@ObservationIgnored private var` so they can be cancelled before starting new work
- **DO** cancel previous tasks before starting new ones: `loadTask?.cancel()`
- **DO** check cancellation between async operations with `guard !Task.isCancelled else { return }` in non-throwing tasks
- **DO** use `try Task.checkCancellation()` in throwing tasks — propagates cancellation as a `CancellationError`
- **NEVER** write `Task { @MainActor in ... }` inside a `@MainActor` class — the task already inherits the actor's isolation context. Adding `@MainActor` is redundant and suggests the developer doesn't understand actor inheritance.

**Stored task (MUST use `[weak self]`):**

```swift
@MainActor
final class FeatureViewModel {

    @ObservationIgnored
    private var loadTask: Task<Void, Never>?

    @discardableResult
    func loadInitialDataIfNeeded() -> Task<Void, Never> {
        loadTask?.cancel()

        let task = Task { [weak self] in  // ← [weak self] REQUIRED: self owns loadTask
            guard let self, !Task.isCancelled else { return }

            async let data1: Void = self.fetchData1()
            async let data2: Void = self.fetchData2()
            _ = await (data1, data2)

            guard !Task.isCancelled else { return }

            self.hasLoadedData = true
        }

        loadTask = task
        return task
    }
}
```

**Fire-and-forget (no cycle, `[weak self]` optional):**

```swift
func loadOnAppear() {
    Task {  // ← strong capture OK — task completes quickly, no cycle
        let data = await fetch()
        self.data = data
    }
}
```

### Error Handling Rules

- Create a single `private func handleError(_ error: Error)` in ViewModel
- Map typed errors (NetworkError) to user-facing messages
- Log detailed errors for debugging: `print("[ViewModelName] Error: \(error)")`
- Never expose internal error details to the user
- Display errors via `.alert()` with a Binding to `errorMessage`

### Formatting Rules

- Always use `.formatted()` APIs — never `String(format:)` or `DateFormatter`
- Numbers: `value.formatted(.number.precision(.fractionLength(2)))`
- Dates: `date.formatted(date: .numeric, time: .omitted)`
- Percentages: `value.formatted(.percent.precision(.fractionLength(1)))`

### API Endpoint Organization

- Use case-less enums as namespaces for endpoints
- Group by feature with MARK comments
- Use static functions for parameterized endpoints

```swift
enum API {
    enum Endpoints {
        // Group endpoints by feature with MARK comments
        // MARK: - Feature Name
        static let items = "/items"
        static func itemSearch(_ query: String) -> String { "/items/search?q=\(query)" }
    }
    enum Constants {
        static let defaultPageSize = 20
    }
}
```

## Verification Checklist

- [ ] ViewModel uses `@Observable` and `@MainActor` (not `ObservableObject`)
- [ ] Non-observed properties use `@ObservationIgnored`
- [ ] View owns ViewModel via `@State private var`
- [ ] Dependencies injected via initializer with defaults
- [ ] All async operations use `async/await`
- [ ] Pagination uses separate `isLoading` and `isLoadingMore`
- [ ] Error handling provides user-friendly messages
- [ ] Modern `.formatted()` APIs for all formatting
- [ ] API endpoints in case-less enum
- [ ] MARK comments follow project's defined order
- [ ] `.task` used for lifecycle-bound async work

## Common Mistakes

- **Using `ObservableObject` with `@Published`** → Use `@Observable` macro (iOS 17+)
- **Missing `@ObservationIgnored`** → Interactor and counters trigger unnecessary UI updates
- **Wrong MARK order** → Follow the project's defined order in CLAUDE.md
- **Single `isLoading` for pagination** → Separate `isLoading` (initial) from `isLoadingMore` (append)
- **No guard against concurrent pagination loads** → `guard !isLoadingMore else { return }`
- **Legacy formatters** → Use `.formatted()` instead of `DateFormatter` / `String(format:)`

## References

- `${CLAUDE_SKILL_DIR}/references/examples.md` — Full ViewModel with pagination, View with error handling, API enum, pagination guard pattern
