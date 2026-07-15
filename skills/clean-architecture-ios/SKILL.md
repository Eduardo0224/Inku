---
name: clean-architecture-ios
description: >-
  Clean Architecture for iOS apps with SwiftUI. Four-layer pattern: Models,
  Interactors (protocol-first), ViewModels (@Observable), and Views. Feature-based
  folder organization. Use when creating new features, setting up project structure,
  implementing MVVM with SwiftUI, or user mentions "Clean Architecture", "interactor",
  "ViewModel", "dependency injection", "feature organization", or "protocol-first".
user-invocable: true
when_to_use: |
  When creating a new feature or setting up feature-based folder structure. When implementing MVVM with SwiftUI, defining Interactor protocols, or setting up dependency injection. When the user mentions "Clean Architecture", "interactor", "ViewModel", "dependency injection", "feature organization", "protocol-first", or "feature-based".
---

## Overview

Implement every iOS feature using four layers with unidirectional dependency flow. Organize code by feature, not by layer. Every Interactor gets a protocol, a production implementation, a Mock (for previews), and a Spy (for tests).

> **Project-specific settings**: Before applying this skill, check the project's `CLAUDE.md` for:
> - Minimum deployment target (affects available APIs)
> - Concurrency settings (Strict Concurrency Checking level)
> - Naming conventions (Mock vs. Stub, Spy vs. Fake)
> - Localization pattern (enum name, key format)
> - Design system package name (if any)

## Instructions

1. **Start with Models** — pure structs, `Codable` + `Sendable`, no business logic
2. **Define the Interactor protocol** — all methods the feature needs
3. **Implement production Interactor** — inject services via initializer with defaults
4. **Create Mock Interactor** — configurable stub data for SwiftUI previews (same feature folder)
5. **Create Spy Interactor** — tracking `wasCalled` properties for unit tests (test target only)
6. **Build the ViewModel** — `@Observable` + `@MainActor`, receives Interactor via `init`
7. **Build the View** — owns ViewModel via `@State`, delegates all actions to ViewModel

## Rules

### Layer Responsibilities

- **Model** — Pure data. `Identifiable`, `Codable`, `Hashable`, `Sendable`. No imports beyond Foundation. Computed properties for formatting only.
- **Interactor** — All business logic and data access. Always protocol-first. Never import SwiftUI.
- **ViewModel** — Presentation logic and state. `@Observable` + `@MainActor`. Mark non-observed dependencies `@ObservationIgnored`. Transform data for display, handle errors into user messages.
- **View** — UI rendering only. Own ViewModel via `@State`. Pass Interactor to ViewModel in `init`. Delegate all actions to ViewModel. Zero business logic.

### Dependency Injection

- Every layer receives dependencies via initializer with default values
- View receives optional Interactor protocol: `init(interactor: FooInteractorProtocol = FooInteractor())`
- ViewModel receives Interactor protocol the same way
- Interactor receives services (NetworkServiceProtocol, etc.) the same way

### Three Implementations Per Interactor

- **Production** (`[Feature]/Interactor/[Feature]Interactor.swift`) — real logic with real services
- **Mock** (`[Feature]/Interactor/Mock[Feature]Interactor.swift`) — stub data, configurable error flag, for previews. No `wasCalled` tracking. Lives in app target.
- **Spy** (`[App]Tests/Shared/Spies/Spy[Feature]Interactor.swift`) — `wasCalled` booleans, `last*` capture properties, `reset()` method. For unit tests only. Annotate with `@MainActor` — never use `@unchecked Sendable`.

### Feature Organization

```
Features/[FeatureName]/
├── Models/                     ← Feature-specific models
├── Interactor/
│   ├── Protocols/              ← Interactor protocol
│   ├── [Feature]Interactor.swift
│   └── Mock[Feature]Interactor.swift
├── ViewModel/
│   └── [Feature]ViewModel.swift
└── Views/
    ├── [Feature]View.swift
    └── Components/             ← Child views used only by this feature
```

### MARK Comment Order

In every Swift file, follow this exact order (customize in CLAUDE.md if different):

1. `// MARK: - Private Properties`
2. `// MARK: - States`
3. `// MARK: - Bindings`
4. `// MARK: - Environment`
5. `// MARK: - Properties`
6. `// MARK: - Body` (Views only)
7. `// MARK: - Initializers`
8. `// MARK: - Private Views` (Views only)
9. `// MARK: - Private Functions`
10. `// MARK: - Functions`

### Concurrency Safety

See also: `skills/swift-concurrency/SKILL.md` for detailed concurrency rules.

- **Never** use `@unchecked Sendable` — it bypasses compiler verification
- Use `@MainActor` on Spies — mutable test state is protected by the main actor
- **Never** write `Task { @MainActor in ... }` inside a `@MainActor` class — the task inherits the actor context
- The compiler settings should be: Strict Concurrency Checking = **Complete** (or whatever the project's CLAUDE.md specifies)
- Every type crossing an isolation boundary must be `Sendable`

### Dos and Don'ts

- **DO** inject dependencies via protocol-typed initializer parameters with defaults
- **DO** make every Interactor conform to a protocol before writing the implementation
- **DO** use `@ObservationIgnored` for non-reactive properties in `@Observable` classes
- **DO** keep feature folders self-contained — easy to remove or refactor
- **DON'T** put business logic in Views — delegate to ViewModel
- **DON'T** import SwiftUI in Interactors or Models
- **DON'T** call network/API directly from Views or ViewModels — always through an Interactor
- **DON'T** call a test-only class "Mock" — Mock = previews, Spy = tests
- **DON'T** use `@unchecked Sendable` — it silences the compiler instead of fixing the concurrency issue

## Verification Checklist

- [ ] Models are pure structs with no business logic
- [ ] Interactor protocol defined before implementation
- [ ] Production, Mock, and Spy implementations all exist
- [ ] ViewModel uses `@Observable` and `@MainActor`
- [ ] Non-observed ViewModel properties marked `@ObservationIgnored`
- [ ] View owns ViewModel via `@State`
- [ ] View passes Interactor to ViewModel in `init`
- [ ] All async operations use `async/await`
- [ ] Feature organized in feature-based folder structure
- [ ] Mock is in feature folder (app target), Spy is in test target
- [ ] MARK comments follow the project's defined order

## Common Mistakes

- **Business logic in Views** → Move to ViewModel via Interactor
- **Missing protocol** → Always define the Interactor protocol first
- **Hardcoded dependencies** → Inject via initializer with protocol type and default value
- **Spy in production code** → Spy lives in test target; Mock lives in feature folder for previews
- **ViewModel not @MainActor** → ViewModels MUST be `@MainActor` — published properties update UI on main thread
- **Redundant `Task { @MainActor in }`** → Inside a `@MainActor` class, `Task {}` already inherits the actor. The annotation is noise that signals misunderstanding of actor isolation.

## References

- `${CLAUDE_SKILL_DIR}/references/examples.md` — Full code examples: Model, Interactor (Prod/Mock/Spy), ViewModel, View, DI flow
- `skills/swift-concurrency/SKILL.md` — Detailed concurrency patterns and safety rules
