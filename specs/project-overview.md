# Inku - Project Overview

## Project Description

**Inku** is an iOS/iPadOS native manga collection management application that allows users to browse, search, and manage their personal manga collection. The app consumes a REST API with 64,000+ manga titles and provides a professional, visually distinctive interface optimized for both iPhone and iPad.

## Project Goals

- **Primary**: Deliver a functional MVP (v1.0.0) for manga collection management
- **Secondary**: Implement advanced features (authentication, cloud sync, statistics) in future versions
- **Technical**: Demonstrate Clean Architecture, SwiftUI best practices, and professional Git workflow

## Technology Stack

| Technology | Version/Framework | Purpose |
|------------|-------------------|---------|
| **Language** | Swift 6 | Primary development language |
| **UI Framework** | SwiftUI + Observation | Modern declarative UI with `@Observable` macro |
| **Target Platforms** | iOS 26 (primary), iOS 18 (fallback) | iPhone and iPad support |
| **Minimum Deployment** | iOS 18.6+ / iPadOS 18.6+ | Minimum supported version |
| **Architecture** | Clean Architecture (4 layers) | Models → Interactors → ViewModels → Views |
| **Persistence** | SwiftData | Local manga collection storage |
| **Networking** | URLSession + async/await | Async networking with structured concurrency |
| **Testing** | Swift Testing framework | Modern testing with `@Test` and `#expect` macros |
| **Design System** | InkuUI Swift Package | Reusable components and design tokens |
| **Localization** | String Catalog (.xcstrings) | Spanish & English support |
| **Git Workflow** | GITFLOW (simplified) | develop, feature/*, release/*, main branches |

## Core Features (v1.0.0 - MVP)

### 1. MangaList Feature
**Browse 64,000+ manga titles with pagination and filtering**

- Infinite scroll pagination (20 items per page)
- Filter by genre, demographic, or theme (Menu-based UI)
- Skeleton loading pattern with shimmer effect
- Smart error handling (full-screen vs inline alerts)
- Empty state with visual feedback
- Navigation to MangaDetailView

**Files**: `Features/MangaList/`

### 2. Search Feature
**Multi-scope search functionality**

- Search manga by title (contains, begins with modes)
- Search authors by name (first + last name)
- Scope toggle between manga and author search
- Adaptive grid layout (2 columns iPhone, 4/5 columns iPad)
- Skeleton loading for both scopes
- Empty states and no results states

**Files**: `Features/Search/`

### 3. Collection Feature
**Local manga collection management with SwiftData**

- Add manga to collection with SwiftData persistence
- Track volumes owned, reading progress, completion status
- Edit collection data (volumes, reading volume, completion)
- Delete from collection with confirmation alerts
- Filter collection (All, Reading, Complete, Incomplete)
- Sort by date added, title, or progress
- Search within collection
- Statistics view with visual analytics

**Files**: `Features/Collection/`

### 4. MangaDetail Feature
**Comprehensive manga information display**

- Large cover image with blur background + glass effect
- Header section with title, Japanese title, and score badge
- Stats section (volumes, chapters, publication status)
- Publication dates section with formatted date display
- Synopsis with expand/collapse functionality
- Background information (separate section on iPad)
- Authors section with role badges
- Tags section (genres, demographics, themes)
- Add to collection / Manage collection actions
- Adaptive 2-column layout on iPad landscape

**Files**: `Features/MangaDetail/`

## iPad Optimization

### Adaptive Layouts
- Size class-based layout decisions (`@Environment(\.horizontalSizeClass)`)
- Dynamic breakpoint detection (width > 1000px for landscape)
- **Search/Results**: 2 (iPhone) / 4 (iPad portrait) / 5 (iPad landscape) column grids
- **Collection**: LazyVStack (iPhone) / 1-2 column grid (iPad)
- **MangaDetail**: Single column (portrait) / 2-column layout (landscape)

### iPadOS Native Features
- `.tabViewStyle(.sidebarAdaptable)` for native sidebar
- Tab reordering for optimal sidebar UX
- Proper orientation support (all on iPad, portrait-only on iPhone)

### iOS 26+ Enhancements
- Liquid Glass background effect (`.backgroundExtensionEffect()`)
- Conditional support with graceful fallback for iOS 18

## InkuUI Design System (v1.9.1)

**Swift Package with reusable components and design tokens**

### Design Tokens
- **Colors**: `.inkuText`, `.inkuTextSecondary`, `.inkuSurface`, `.inkuAccent`, etc.
- **Spacing**: `InkuSpacing.spacing{4,8,12,16,24,32}`
- **Corner Radius**: `InkuRadius.radius{8,12,16}`
- **Typography**: `.inkuDisplayMedium`, `.inkuHeadline`, `.inkuBody`, `.inkuCaption`

### Reusable Components
- `InkuMangaRow`: Manga list item with cover, title, score
- `InkuSearchResultCard`: Search result card with badge
- `InkuAuthorResultCard`: Author search result
- `InkuCoverImage`: Async image loader with caching
- `InkuEmptyView`: Empty state with icon, title, subtitle
- `InkuErrorView`: Error state with retry action
- `InkuLoadingView`: Loading indicator with message
- `InkuProgressBar`: Progress indicator for collection
- `InkuStatCard`: Stat card for manga details
- `InkuListContainer`: Reusable list container with header

### Modifiers
- `.inkuCard()`: Card style with shadow and radius
- `.inkuGlass()`: Glass effect modifier (iOS 26+)
- `.inkuTabStyle()`: Custom tab bar styling

## API Integration

**Base URL**: `https://mymanga-acacademy-5607149ebe3d.herokuapp.com`

**API Documentation (Swagger)**: [https://mymanga-acacademy-5607149ebe3d.herokuapp.com/docs](https://mymanga-acacademy-5607149ebe3d.herokuapp.com/docs)

See `specs/api-endpoints.md` for detailed endpoint documentation.

## Localization

**Languages**: Spanish (es) and English (en)

- String Catalog implementation (`.xcstrings`)
- Separate catalogs for features:
  - `Localizable.xcstrings` (Common, Tabs, Errors)
  - `MangaListLocalizable.xcstrings`
  - `SearchLocalizable.xcstrings`
  - `CollectionLocalizable.xcstrings`
  - `MangaDetailLocalizable.xcstrings`
- `L10n.swift` enum structure for type-safe access
- All UI strings localized (no hardcoded strings)

## Project Structure

```
Inku/
├── InkuApp.swift                      # App entry point
├── Core/                              # Shared code
│   ├── Models/                        # Shared models (Manga, Author, etc.)
│   ├── Services/                      # NetworkService, CacheService
│   ├── Extensions/                    # Swift extensions
│   ├── Localization/                  # L10n.swift
│   └── Components/                    # Shared app-specific components
├── Features/                          # Feature modules
│   ├── MangaList/
│   │   ├── Models/
│   │   ├── Interactor/
│   │   │   ├── Protocols/
│   │   │   ├── MangaListInteractor.swift
│   │   │   └── MockMangaListInteractor.swift
│   │   ├── ViewModel/
│   │   │   └── MangaListViewModel.swift
│   │   └── Views/
│   │       ├── MangaListView.swift
│   │       └── Components/
│   ├── Search/
│   ├── Collection/
│   └── MangaDetail/
└── Resources/
    ├── Assets.xcassets
    └── *.xcstrings                    # Localization catalogs
```

## Testing Strategy

**Framework**: Swift Testing (not XCTest)

| Layer | Test Type | Implementation |
|-------|-----------|----------------|
| ViewModels | Unit tests | `@MainActor` with SpyInteractor |
| Interactors | Unit tests | SpyNetworkService |
| Views | SwiftUI Previews | MockInteractor for data |

**Test Organization**:
```
InkuTests/
├── Features/
│   ├── MangaList/
│   │   ├── MangaListTests.swift
│   │   ├── MangaListTests+ViewModel.swift
│   │   └── MangaListTests+Interactor.swift
│   └── ...
└── Shared/
    └── Spies/
        ├── SpyMangaListInteractor.swift
        └── SpyNetworkService.swift
```

## Current Status (v1.0.0)

✅ **MVP COMPLETED** - Released on 2026-01-23

### Features Completed
- ✅ MangaList with pagination and filters
- ✅ Search (manga by title, author by name)
- ✅ Collection management (SwiftData)
- ✅ MangaDetail with full information
- ✅ iPad adaptive layouts
- ✅ InkuUI design system (v1.9.1)
- ✅ Spanish/English localization
- ✅ Comprehensive test suite
- ✅ Custom app icon with adaptive variants (iOS 18+)

### Statistics
- **89 files** modified
- **12,539 insertions**, 110 deletions
- **8 sprints** completed (Foundation, MangaList, MangaDetail, Search, Collection, InkuUI, Integration, Release)
- **7 pull requests** merged to develop
- **1 release** tag (v1.0.0)

## Future Versions (Planned)

### v1.5.0 - Medium Version
- Advanced filters (multi-select for genres, demographics, themes)
- Grid view mode toggle
- Sort options (by score, date, title)

### v2.0.0 - Advanced Version
- User authentication (registration and login)
- Cloud collection sync
- Token/credentials storage in Keychain
- Offline support with local cache

### v3.0.0 - Deluxe Version
- Multi-platform support (macOS, watchOS, or tvOS)
- Static widget showing reading progress
- Complications (if watchOS)

## Development Workflow

**Git Strategy**: Simplified GITFLOW

```
main          ← Production releases (v1.0.0, v1.1.0, etc.)
  ↑
release/*     ← Release preparation (release/v1.0.0)
  ↑
develop       ← Integration branch
  ↑
feature/*     ← Feature development (feature/search, feature/collection)
```

**Commit Convention**: Conventional Commits with gitmoji

```
[type](scope): 🎨 Brief description

- Detailed explanation
- What changed and why

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>
```

## Key Design Decisions

### Why Clean Architecture?
- Clear separation of concerns
- Testable business logic (Interactors)
- Independent layers (can change UI without touching business logic)
- Protocol-first design enables dependency injection

### Why @Observable over ObservableObject?
- Modern Observation framework (iOS 17+)
- Less boilerplate (no `@Published` needed)
- Better performance (fine-grained observation)
- Cleaner syntax with `@State` ownership

### Why SwiftData over CoreData?
- Modern declarative API matching SwiftUI
- Automatic schema migration
- Type-safe queries with Swift syntax
- Native `@Observable` support

### Why Swift Testing over XCTest?
- Modern macro-based syntax (`@Test`, `#expect`)
- Better parameterized testing with `arguments:`
- Clearer test organization with `@Suite`
- Native async/await support

### Why Feature-based Organization?
- Scales better than layer-based (Models/, Views/, etc.)
- Each feature is self-contained
- Easier to understand "what does Search do?"
- Supports team collaboration (different people, different features)

## Repository

**GitHub**: [https://github.com/Eduardo0224/Inku](https://github.com/Eduardo0224/Inku)

## Educational Context

**Program**: Swift Developer Program (SDP26) - Otoño 2025
**Institution**: Apple Coding Academy
**Purpose**: Educational project demonstrating professional iOS development practices
**Copyright**: © 2025 Eduardo Andrade. All rights reserved.
