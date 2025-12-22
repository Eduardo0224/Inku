# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Quick Reference

- **Project**: Inku - iOS/iPadOS Native App
- **Language**: Swift (English-only code)
- **UI Framework**: SwiftUI with Observation framework
- **Target**: iOS 26 (primary) with iOS 18 fallback
- **Architecture**: Clean Architecture (4 layers) - Feature-based organization
- **Testing**: Swift Testing framework only (no XCTest)
- **Localization**: String Catalog (Spanish & English)

## Specifications

Read the following specs in `specs/` based on task type:

| Task | Required Specs |
|------|----------------|
| New feature | `01-architecture.md` + `02-swiftui-patterns.md` |
| UI work | `02-swiftui-patterns.md` + `07-ui-design.md` + `09-inku-ui.md` |
| Reusable component | `09-inku-ui.md` |
| Networking | `04-async-networking.md` |
| Testing | `05-testing.md` |
| iOS 26 / LiquidGlass | `06-ios-versions.md` |
| Localization | `08-localization.md` |

> **Note**: All UI work should use InkuUI tokens (`InkuSpacing`, `InkuRadius`, `.inkuText`, etc.) and components when applicable.

## Project Structure

```
Inku/
├── CLAUDE.md                          ← This file
├── specs/                             ← Architecture & style guides
├── Inku.xcodeproj                     ← Xcode project
├── Inku/                              ← Main app target
│   ├── InkuApp.swift                  ← App entry point
│   ├── ContentView.swift
│   ├── Core/                          ← Shared code (create as needed)
│   │   ├── Models/
│   │   ├── Services/
│   │   │   ├── Protocols/
│   │   │   ├── NetworkService.swift
│   │   │   └── CacheService.swift
│   │   ├── Extensions/
│   │   └── Components/                ← App-specific shared components
│   ├── Features/                      ← Feature modules (create as needed)
│   │   └── [FeatureName]/
│   │       ├── Models/
│   │       ├── Interactor/
│   │       │   ├── Protocols/
│   │       │   ├── [Feature]Interactor.swift
│   │       │   └── Spy[Feature]Interactor.swift
│   │       ├── ViewModel/
│   │       │   └── [Feature]ViewModel.swift
│   │       └── Views/
│   │           ├── [Feature]View.swift
│   │           └── Components/
│   └── Resources/
│       ├── Assets.xcassets
│       └── Localizable.xcstrings       ← When created
├── InkuTests/                         ← Test target (create as needed)
│   └── Features/
│       └── [FeatureName]/
│           ├── [Feature]Tests.swift
│           ├── [Feature]Tests+ViewModel.swift
│           └── [Feature]Tests+Interactor.swift
└── InkuUI/                            ← UI Package (create when needed)
    ├── Package.swift
    ├── Sources/
    │   └── InkuUI/
    │       ├── Tokens/
    │       ├── Components/
    │       └── Modifiers/
    └── Tests/
```

## Golden Rules

1. ✅ Feature-based folder organization
2. ✅ One component = one file
3. ✅ Protocol-first for Interactors
4. ✅ `@Observable` for ViewModels (Observation framework)
5. ✅ `@State` for view-owned observable objects
6. ✅ `async/await` for all async operations
7. ✅ MARK comments in fixed order (see `03-code-style.md`)
8. ✅ English code, localized UI (String Catalog)
9. ✅ Swift Testing framework only (no XCTest)
10. ✅ LiquidGlass only where Apple recommends
11. ✅ Reusable UI components in InkuUI package
12. ✅ `import InkuUI` for design tokens and components

## Common Commands

### Building and Running

```bash
# Open project in Xcode
open Inku.xcodeproj

# Build from command line
xcodebuild -project Inku.xcodeproj -scheme Inku -sdk iphonesimulator

# Clean build
xcodebuild clean -project Inku.xcodeproj -scheme Inku
```

### Testing

```bash
# Run all tests
xcodebuild test -project Inku.xcodeproj -scheme Inku -destination 'platform=iOS Simulator,name=iPhone 16 Pro'

# Run specific test
xcodebuild test -project Inku.xcodeproj -scheme Inku -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -only-testing:InkuTests/FeatureTests

# Run tests with Swift Testing
swift test  # If using SPM package structure
```

In Xcode:
- **⌘+B** to build
- **⌘+R** to run
- **⌘+U** to run all tests
- **⌃+⌥+⌘+U** to run tests again

## Architecture Overview

### Clean Architecture (4 Layers)

```
Views (SwiftUI)          ← UI only, no logic
    ↓
ViewModels (@Observable) ← Presentation logic, state
    ↓
Interactors (Protocol)   ← Business logic, data access
    ↓
Models (Structs)         ← Pure data, Codable/Sendable
```

### Dependency Injection Pattern

All features use DI with protocol-first Interactors:

```swift
// View owns ViewModel via @State
struct MovieListView: View {
    @State private var viewModel: MovieListViewModel

    init(interactor: MovieListInteractorProtocol = MovieListInteractor()) {
        self.viewModel = MovieListViewModel(interactor: interactor)
    }
}

// ViewModel receives Interactor
@Observable
@MainActor
final class MovieListViewModel {
    @ObservationIgnored
    private let interactor: MovieListInteractorProtocol

    init(interactor: MovieListInteractorProtocol) {
        self.interactor = interactor
    }
}
```

### Testing with Spies

Always create Spy implementations for testing:

```swift
// Production
final class MovieInteractor: MovieInteractorProtocol { }

// Testing
final class SpyMovieInteractor: MovieInteractorProtocol {
    private(set) var fetchMoviesWasCalled = false
    var moviesToReturn: [Movie] = []
}
```

## Key Patterns

### MARK Comment Order

Strictly follow this order (see `03-code-style.md` for details):

1. `// MARK: - Private Properties`
2. `// MARK: - States` (@State, @Bindable, etc.)
3. `// MARK: - Bindings`
4. `// MARK: - Environment`
5. `// MARK: - Properties`
6. `// MARK: - Body`
7. `// MARK: - Initializers`
8. `// MARK: - Private Views`
9. `// MARK: - Private Functions`
10. `// MARK: - Functions`

### Test Structure

```swift
@Suite("Feature Name")
struct FeatureTests {

    @Suite("ViewModel Tests")
    @MainActor
    struct ViewModelTests {
        // MARK: - Subject Under Test
        let spyInteractor = SpyInteractor()

        // MARK: - Tests
        @Test("Load data successfully")
        func loadDataSuccess() async { }
    }
}
```

## InkuUI Package

When creating reusable UI components:

- **Create in InkuUI**: Components used in 2+ places, no business logic
- **Keep in App**: Feature-specific components, ViewModels, Interactors

Use `Inku` prefix for all public elements:
- Components: `InkuButton`, `InkuCard`
- Colors: `.inkuAccent`, `.inkuSurface`
- Spacing: `InkuSpacing.spacing16`
- Radius: `InkuRadius.radius12`
