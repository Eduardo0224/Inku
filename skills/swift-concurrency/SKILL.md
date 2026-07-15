---
name: swift-concurrency
description: >-
  Swift 6 concurrency patterns: actor isolation, Sendable, Task management,
  @MainActor inheritance, and Strict Concurrency Checking. Use when writing
  concurrent code, fixing concurrency warnings, reviewing Sendable conformance,
  or user mentions "actor", "Sendable", "@MainActor", "Task", "concurrency",
  "Strict Concurrency Checking", or "data race".
user-invocable: true
when_to_use: |
  When writing concurrent Swift code, fixing concurrency warnings, or reviewing Sendable conformance. When the user mentions "actor", "Sendable", "@MainActor", "Task", "concurrency", "Strict Concurrency Checking", or "data race".
---

## Overview

Write data-race-free Swift code using the language's concurrency model. Understand actor isolation inheritance, `Sendable` requirements, and proper `Task` lifecycle management. Target Strict Concurrency Checking = Complete with no `@unchecked Sendable` workarounds.

> **Project-specific settings**: Check `CLAUDE.md` for:
> - Strict Concurrency Checking level (should be "Complete")
> - Default actor isolation setting (typically "nonisolated" for app targets)
> - Any project-specific Sendable conventions

## Instructions

1. **Make all model types Sendable** — use `Codable` + `Hashable` for automatic conformance
2. **Isolate mutable state** — `@MainActor` for UI state, custom actors for background work
3. **Never silence the compiler** — fix the root cause instead of using `@unchecked Sendable`
4. **Understand actor inheritance** — Tasks, closures, and async methods inherit their enclosing actor
5. **Manage task lifecycles** — cancel previous work before starting new, check cancellation between steps

## Rules

### Sendable Conformance

- **Model structs** — Automatic `Sendable` via `Codable` + `Hashable` with value-type properties
- **Enums** — Automatic `Sendable` when all associated values are `Sendable`
- **Classes** — Rarely needed. If unavoidable, use `final` + only `let` stored properties
- **Closures** — `@Sendable` attribute required when crossing isolation boundaries

```swift
// ✅ Good — automatic Sendable
struct Item: Codable, Hashable, Identifiable {
    let id: String
    let name: String
}

// ❌ Bad — class with mutable state crossing isolation
final class ServiceCache: @unchecked Sendable {
    var cache: [String: Data] = [:]  // data race!
}
```

### @MainActor Usage

- **ViewModels** — always `@MainActor` (published properties update UI)
- **Spies (tests)** — `@MainActor` protects mutable tracking state
- **UIKit ViewControllers** — implicitly `@MainActor`
- **Never on Models** — models are value types, actors don't apply

### Actor Inheritance

Closures and async methods **inherit** the actor of their enclosing scope:

```swift
@MainActor
final class MyViewModel {
    func load() {
        // ✅ Task inherits @MainActor — no annotation needed
        Task {
            let data = await fetch()      // runs on main actor
            self.updateUI(with: data)     // runs on main actor
        }

        // ❌ Redundant — Task already inherits @MainActor
        Task { @MainActor in
            // ...
        }
    }
}
```

**The rule**: `Task` inherits the actor of its **enclosing function/closure**, not its enclosing class. Inside a non-isolated closure (system callback like `WCSession`, `URLSession`, `HKHealthStore`), `Task { @MainActor in }` **is required** — the closure runs on a background queue and the Task does NOT inherit `@MainActor` from the class.

> **Exception documented in**: `${CLAUDE_SKILL_DIR}/references/examples.md` — "System Callback → @MainActor Hop"

### Task Lifecycle Management

| Pattern | [weak self] needed? | Why |
|---------|-------------------|-----|
| Stored task (`self.loadTask = task`) | **YES** | Retain cycle: self → task → closure → self |
| Fire-and-forget Task | No (optional) | No cycle, but keeps self alive until done |
| `.task {}` modifier | No | SwiftUI auto-cancels on view disappear |

**Stored task — MUST use `[weak self]`:**

```swift
@MainActor
final class FeatureViewModel {
    @ObservationIgnored
    private var loadTask: Task<Void, Never>?

    @discardableResult
    func loadData() -> Task<Void, Never> {
        loadTask?.cancel()

        let task = Task { [weak self] in  // ← REQUIRED
            guard let self, !Task.isCancelled else { return }
            // ... async work ...
            guard !Task.isCancelled else { return }
            self.data = result
        }

        loadTask = task
        return task
    }
}
```

### Cancellation

- **Non-throwing tasks**: `guard !Task.isCancelled else { return }`
- **Throwing tasks**: `try Task.checkCancellation()` (throws `CancellationError`)
- **Check between async steps** — cancellation is cooperative, not preemptive
- **Cancel old work** before starting new: `previousTask?.cancel()`

### Global Actors vs. Custom Actors

```swift
// @MainActor — for UI-bound state
@MainActor
final class ViewModel { }

// Custom actor — for background-isolated state
actor ImageCache {
    private var storage: [URL: Data] = [:]

    func store(_ data: Data, for url: URL) {
        storage[url] = data
    }
}
```

### Concurrency Settings

The recommended project settings:

```
SWIFT_STRICT_CONCURRENCY = complete    // Strict Concurrency Checking
SWIFT_DEFAULT_ACTOR_ISOLATION = nonisolated  // Default isolation
```

- `complete` — full checking; catches all potential data races
- `nonisolated` — types are not isolated to any actor by default (you opt into isolation)

## Verification Checklist

- [ ] No `@unchecked Sendable` anywhere in the codebase
- [ ] No `Task { @MainActor in }` inside `@MainActor` classes
- [ ] Stored tasks use `[weak self]`
- [ ] Cancellation checked between async steps
- [ ] Previous tasks cancelled before starting new ones
- [ ] All model types are `Sendable` (via `Codable` + `Hashable`)
- [ ] `@MainActor` on all ViewModels and Spies
- [ ] No `#available` guards for concurrency features on supported deployment targets

## Common Mistakes

- **`@unchecked Sendable`** → Fix the root cause. Use `@MainActor`, a custom actor, or make the type a struct.
- **`Task { @MainActor in }` in @MainActor class body** → The task inherits the actor from the method, not the class. Inside non-isolated closures (system callbacks), `@MainActor` IS required. See references/examples.md.
- **No `[weak self]` in stored task** → Creates a retain cycle. Always use `[weak self]` when `self` stores the task.
- **Not checking cancellation** → Long tasks keep running after being cancelled. Check between steps.
- **`class` crossing isolation** → Use `struct` or `actor` instead. Classes with mutable state can't be `Sendable`.
- **Forgetting `@Sendable` on closure parameters** → Closures stored across isolation boundaries need `@Sendable`.

## References

- `${CLAUDE_SKILL_DIR}/references/examples.md` — Sendable patterns, actor isolation examples, task lifecycle
- [Swift Concurrency Guide](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/concurrency/)
- `skills/clean-architecture-ios/SKILL.md` — Architecture integration with concurrency
