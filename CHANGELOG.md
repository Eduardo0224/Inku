# Changelog

All notable changes to the Inku project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

Nothing pending for next release.

---

## [1.0.0] - 2026-01-23

### 🎉 MVP Release - First Stable Version

**Inku v1.0.0** is the Minimum Viable Product release, featuring a complete manga collection management experience with browse, search, and local collection capabilities. This release includes comprehensive iPad optimization, full Spanish/English localization, and a professional design system.

### Added

#### Core Features

- **MangaList Feature** - Browse 64,000+ manga titles
  - Infinite scroll pagination with smart loading states
  - Filter by genre, demographic, and theme (Menu-based UI)
  - Skeleton loading pattern with shimmer effect from InkuUI
  - Smart error handling (full-screen error view vs inline alerts)
  - Empty state with visual feedback
  - Navigation to MangaDetailView
  - Comprehensive test suite (ViewModel + Interactor tests)
  - **Files**: `MangaListView.swift`, `MangaListViewModel.swift`, `MangaListInteractor.swift`
  - **PR**: [#2] feat(MangaList): Implement manga list feature

- **Search Feature** - Multi-scope search functionality
  - Search by manga title (contains, begins with modes)
  - Search by author name (first name + last name)
  - Scope toggle between manga and author search
  - Adaptive grid layout (2 columns iPhone, 4/5 columns iPad)
  - Skeleton loading for both scopes
  - Empty states and no results states
  - Navigation to MangaDetailView
  - **Files**: `SearchView.swift`, `SearchViewModel.swift`, `SearchInteractor.swift`
  - **PR**: [#3] feat(Search): Implement search feature

- **Collection Feature** - Local manga collection management
  - Add manga to collection with SwiftData persistence
  - Track volumes owned, reading progress, completion status
  - Edit collection data (volumes, reading volume, completion)
  - Delete from collection with confirmation
  - Filter collection (All, Reading, Complete, Incomplete)
  - Sort by date added, title, or progress
  - Search within collection
  - Statistics view with visual analytics
  - Empty states for each filter
  - Protocol-based architecture with DI
  - **Files**: `CollectionView.swift`, `CollectionViewModel.swift`, `CollectionInteractor.swift`
  - **PR**: [#5] feat(Collection): Add collection management

- **MangaDetail Feature** - Comprehensive manga information
  - Large cover image with blur background + glass effect
  - Header section with title, Japanese title, and score badge
  - Stats section (volumes, chapters, status)
  - Publication dates section
  - Synopsis with expand/collapse
  - Background information (separate section on iPad)
  - Authors section with role badges
  - Tags section (genres, demographics, themes)
  - Add to collection / Manage collection actions
  - Error handling with user-facing alerts
  - Adaptive 2-column layout on iPad landscape
  - **Files**: `MangaDetailView.swift`, `MangaHeaderSection.swift`, `MangaStatsSection.swift`
  - **PR**: [#6] feat(Integration): Add Collection to MangaDetail navigation

#### iPad Optimization

- **Adaptive Layouts** - Responsive design for iPad and iPhone
  - Size class-based layout decisions (`horizontalSizeClass`)
  - Dynamic breakpoint detection (width > 1000px for landscape)
  - **Search/Results**: 2 (iPhone) / 4 (iPad portrait) / 5 (iPad landscape) column grids
  - **Collection**: LazyVStack (iPhone) / 1-2 column grid (iPad)
  - **MangaDetail**: Single column (portrait) / 2-column layout (landscape)
  - **Files**: `MangaResultsView.swift`, `SearchView.swift`, `CollectionListView.swift`, `MangaDetailView.swift`
  - **PR**: [#7] feat(iPad): Add comprehensive adaptive layouts

- **iPadOS Native Features**
  - `.tabViewStyle(.sidebarAdaptable)` for native sidebar
  - Tab reordering for optimal sidebar UX
  - Proper orientation support (all orientations on iPad, portrait-only on iPhone)
  - **Files**: `InkuApp.swift`, `project.pbxproj`

- **iOS 26+ Enhancements**
  - Liquid Glass background effect (`.backgroundExtensionEffect()`)
  - Conditional support with fallback for iOS 18-25
  - Custom ViewModifier pattern for API availability
  - **Files**: `View+LiquidGlass.swift`

#### Architecture & Code Quality

- **Clean Architecture Implementation** (4 layers)
  - Models: Pure data structures (Codable, Sendable)
  - Interactors: Business logic with protocol-first design
  - ViewModels: Presentation logic with `@Observable`
  - Views: SwiftUI views with `@State` ownership
  - Protocol-based dependency injection throughout

- **CollectionViewModel Refactoring**
  - Created `CollectionInteractor` with `CollectionInteractorProtocol`
  - Added `MockCollectionInteractor` for previews/testing
  - Centralized manga loading logic (`loadMangaById(_:)`)
  - Environment key pattern for global access
  - **PR**: [#6] feat(Integration): Complete MVP polish

- **DRY Refactoring**
  - Extracted reusable section helpers in `MangaDetailView`
  - Extracted `coverImage()`, `scoreBadge`, `titleTexts()` in `MangaHeaderSection`
  - Extracted `mangaCards` in `CollectionListView`
  - Renamed `usesHorizontalLayout` → `isRegularSizeClass` for precision
  - Changed configuration properties from `var` to `let` for immutability
  - **PR**: [#7] refactor(iPad): Apply DRY principles

#### Testing

- **Comprehensive Test Suite**
  - MangaList: ViewModel + Interactor tests (8 tests total)
  - Search: ViewModel tests with mock interactor
  - Collection: ViewModel + Interactor tests (4 interactor tests)
  - SpyNetworkService for dependency injection
  - Pattern: Given-When-Then for clarity
  - **Files**: `MangaListTests.swift`, `SearchTests.swift`, `CollectionTests+Interactor.swift`
  - **Framework**: Swift Testing (not XCTest)

#### InkuUI Design System (v1.9.1)

- **Design Tokens**
  - Colors: `.inkuText`, `.inkuTextSecondary`, `.inkuSurface`, `.inkuAccent`, etc.
  - Spacing: `InkuSpacing.spacing{4,8,12,16,24,32}`
  - Corner Radius: `InkuRadius.radius{8,12,16}`
  - Typography: `.inkuDisplayMedium`, `.inkuHeadline`, `.inkuBody`, `.inkuCaption`

- **Reusable Components**
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

- **Modifiers**
  - `.inkuCard()`: Card style with shadow and radius
  - `.inkuGlass()`: Glass effect modifier
  - `.inkuTabStyle()`: Custom tab bar styling
  - `.sectionIndexWith()`: Section index modifier with iOS version check

#### Localization

- **Complete Spanish/English Support**
  - String Catalog implementation (`Localizable.xcstrings`)
  - Separate catalogs for features:
    - `Localizable.xcstrings` (Common, Tabs, Error)
    - `MangaListLocalizable.xcstrings`
    - `SearchLocalizable.xcstrings`
    - `CollectionLocalizable.xcstrings`
    - `MangaDetailLocalizable.xcstrings`
  - `L10n.swift` enum structure for type-safe access
  - All UI strings localized (no hardcoded strings)
  - Status strings: Publishing, Completed, Hiatus, Discontinued
  - **PR**: [#6] fix(Localization): Complete MangaDetail localization

- **Tab Titles Consistency**
  - `L10n.Tabs.browse`, `L10n.Tabs.collection`, `L10n.Tabs.search`
  - Consistent pattern across all tabs
  - **Commit**: fix(Localization): Standardize tab titles

#### Navigation & UX

- **Complete Navigation Flow**
  - MangaListView → MangaDetailView (NavigationLink)
  - SearchView → MangaDetailView (NavigationLink)
  - CollectionView → MangaDetailView (programmatic navigation)
  - Loading overlay during manga fetch from collection
  - Hide TabBar and toolbar during loading
  - **PR**: [#6] feat(Integration): Add Collection to MangaDetail navigation

- **Error Handling**
  - User-facing alerts for all error scenarios
  - Retry actions in error states
  - Error clearing functionality
  - Replaced print() statements with proper error handling
  - Alert patterns: full-screen error view vs inline alerts

- **Loading States**
  - Skeleton views with shimmer effect (MangaList, Search)
  - Pagination loading indicators
  - Loading overlays for async operations
  - Disabled UI during loading

- **Empty States**
  - Context-aware empty states (5 in SearchView, 4 in CollectionView)
  - Visual feedback with SF Symbols and symbol effects
  - Empty search results vs initial empty state
  - Filter-specific empty states

#### Assets & Branding

- **Custom App Icon**
  - Professional Inku branding
  - iOS 18+ adaptive icon system with 3 variants:
    - Default: Standard light mode icon
    - Dark: Dark mode optimized icon
    - Tinted Light: Themed appearance variant
  - 1024x1024 resolution for all variants
  - **Commit**: chore(Assets): Add custom app icon

#### Bug Fixes

- **Preview Crashes Fixed**
  - EmptyCollectionViewModel now uses no-op instead of fatalError
  - All previews provide MockCollectionViewModel in environment
  - Canvas previews work without crashes when navigating
  - **Commit**: fix(Previews): Prevent crash in Canvas previews

- **UINavigationBar Warning Fixed**
  - Changed searchable placement to `.navigationBarDrawer(displayMode: .always)`
  - Eliminates size class change warning
  - **PR**: [#7] feat(iPad): Add adaptive layouts

#### Core Services

- **NetworkService**
  - URLSession-based HTTP client
  - Async/await API
  - Generic request/response handling
  - Error mapping and handling
  - **File**: `NetworkService.swift`

- **CacheService**
  - Image caching with NSCache
  - Memory management
  - **File**: `CacheService.swift`

- **API Endpoints**
  - 64,000+ manga database
  - Pagination support
  - Filter endpoints (genre, demographic, theme)
  - Search endpoints (title, author)
  - Manga detail by ID
  - **Base URL**: `https://mymanga-acacademy-5607149ebe3d.herokuapp.com`

### Changed

- **Project Structure**
  - Feature-based organization (MangaList, Search, Collection, MangaDetail)
  - Core shared code (Models, Services, Extensions, Components)
  - InkuUI as separate Swift package
  - SwiftData for local persistence

- **Navigation Architecture**
  - TabView with `.sidebarAdaptable` for iPadOS
  - NavigationStack for hierarchical navigation
  - `.navigationDestination(for:)` pattern
  - Programmatic navigation with NavigationPath

### Removed

- **ContentView.swift** - Unused placeholder view deleted
- **Unused computed properties** - Cleaned up in Models and Services
- **Print statements** - Replaced with proper error handling

### Fixed

- Collection navigation to MangaDetail now works properly
- Error handling in MangaDetailView (add/remove collection)
- All hardcoded strings replaced with L10n
- Preview crashes when navigating from MangaList/Search
- Background image overflow in MangaDetailView on iPad
- UINavigationBar warning on size class changes

### Security

- No sensitive data stored (API is public, no authentication in MVP)
- Proper error handling to prevent information leakage

---

## [0.1.0] - 2024-12-20

### Added

- Initial Xcode project setup
- Basic iOS app structure with SwiftUI
- InkuApp.swift as app entry point
- ContentView.swift with placeholder content (later removed)
- Assets.xcassets with placeholder AppIcon
- Git repository initialization
- GITFLOW.md - Git workflow strategy
- PROJECT_PLAN.md - Complete project roadmap
- CLAUDE.md - AI assistant guidance
- specs/ directory with architecture and style guides
  - 01-architecture.md
  - 02-swiftui-patterns.md
  - 03-code-style.md
  - 04-async-networking.md
  - 05-testing.md
  - 06-ios-versions.md
  - 07-ui-design.md
  - 08-localization.md
  - 09-inku-ui.md

---

## Version Guidelines

### Semantic Versioning

- **0.x.x**: Pre-release versions (development phase)
- **1.0.0**: First stable release (MVP complete) ✅
- **Major (x.0.0)**: Breaking changes, major new features
- **Minor (1.x.0)**: New features, backward compatible
- **Patch (1.0.x)**: Bug fixes, minor improvements

### MVP Completed: Version 1.0.0 ✅

The Minimum Viable Product is complete with all required features:
- ✅ Browse manga from database
- ✅ Filter by genre/demographic/theme
- ✅ Search by title and author
- ✅ Save manga to local collection
- ✅ Display user's collection
- ✅ Functional layout for iPhone and iPad
- ✅ Display manga cover images
- ✅ Track volumes owned and reading progress
- ✅ Spanish/English localization
- ✅ Professional design system

### Next Versions (Planned)

- **v1.1.x**: Bug fixes and minor improvements
- **v1.5.0**: Advanced filters and grid view (Medium version)
- **v2.0.0**: Authentication and cloud sync (Advanced version)
- **v3.0.0**: Multi-platform and widgets (Deluxe version)

### Change Categories

- **Added**: New features or functionality
- **Changed**: Changes to existing functionality
- **Deprecated**: Features that will be removed in future versions
- **Removed**: Removed features
- **Fixed**: Bug fixes
- **Security**: Security vulnerability fixes

---

**Project**: Inku - Manga Collection Management
**Repository**: https://github.com/Eduardo0224/Inku
**Target Platform**: iOS 18.6+ / iPadOS 18.6+
**Language**: Swift 6
**UI Framework**: SwiftUI + Observation
**Architecture**: Clean Architecture (4 layers)
**Testing**: Swift Testing framework
**Localization**: Spanish & English
