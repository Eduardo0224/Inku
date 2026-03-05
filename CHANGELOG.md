# Changelog

All notable changes to the Inku project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

Nothing pending for next release.

---

## [3.0.1] - 2026-03-05

### 🔒 Security & Performance Improvements

**Inku v3.0.1** introduces critical security enhancements, structured logging, and performance optimizations. This patch release improves the internal security architecture without changing user-facing functionality.

### Added

#### Security Enhancements

- **Keychain Integration** - Secure credential storage
  - Migrated app token from hardcoded value to Keychain
  - `KeychainService` with protocol-first design for testability
  - Secure storage for `AuthToken`, email, and app token
  - Error handling with `KeychainError` enum
  - Support for token retrieval, update, and deletion
  - Files: `KeychainService.swift`, `KeychainServiceProtocol.swift`

- **SSL Certificate Pinning** - Server validation layer
  - `SSLPinningDelegate` implementing `URLSessionDelegate`
  - SHA-256 public key hash validation
  - Configurable pinning (enabled/disabled for testing)
  - Protection against man-in-the-middle attacks
  - Currently disabled for test server (ready for production)
  - Files: `SSLPinningDelegate.swift`

- **Secrets Management** - Secure configuration
  - `Secrets.xcconfig` for sensitive configuration (gitignored)
  - `Secrets.xcconfig.example` template for team setup
  - Environment variable injection: `APP_TOKEN_KEY`
  - Build-time configuration without hardcoded secrets
  - Files: `Secrets.xcconfig.example`, `.gitignore`

#### Logging System

- **Structured Logging with os.Logger** - Production-ready logging
  - Replaced all `print()` statements with `os.Logger`
  - Category-based loggers: Network, Cache, Auth, UI
  - Log level support: debug, info, warning, error
  - `Logger+Inku.swift` extension with predefined loggers
  - Better debugging and monitoring capabilities
  - Files: `Logger+Inku.swift`

#### Architecture Improvements

- **CollectionViewModel Environment** - SwiftUI best practices
  - Migrated from custom `EnvironmentKey` to `@Entry` macro
  - Simplified environment setup in `InkuApp.swift`
  - Modern SwiftUI pattern (iOS 18+)
  - Files: `CollectionViewModel.swift`, `InkuApp.swift`

- **Optional SharedModelContainer** - Safer initialization
  - Changed `SharedModelContainer.shared` from `!` to `?`
  - Removed `fatalError()` for production safety
  - Graceful handling of initialization failures
  - Better error propagation to UI layer
  - Files: `SharedModelContainer.swift`

#### Performance Optimizations

- **Image Loading Improvements** - InkuUI v1.15.1
  - Upgraded to InkuUI 1.15.1 with SHA-256 cache keys
  - Screen scale factor support for Retina displays
  - visionOS layout fixes for cover images
  - Memory-efficient image caching
  - Dependency: InkuUI 1.15.1

- **InkuCoverImage maxWidth Parameter** - Layout control
  - Added optional `maxWidth` parameter to all `InkuCoverImage` consumers
  - Better control over image sizing in different contexts
  - Prevents oversized images in compact layouts
  - Files: `MangaDetailView.swift`, `CollectionMangaCard.swift`, etc.

- **Pagination Threshold** - Smoother scrolling
  - Reduced threshold from 5 to 3 elements
  - Earlier data prefetching for infinite scroll
  - Improved perceived performance
  - Files: `MangaListViewModel.swift`, `SearchViewModel.swift`

### Changed

#### Authentication Flow

- **App Token Management** - Secure initialization
  - `AuthInteractor.register()` now fetches app token from Keychain
  - Authorization header includes app token from secure storage
  - Fails gracefully if app token not found (`.unauthorized`)
  - Files: `AuthInteractor.swift`

#### Error Handling

- **Improved Error Messages** - Better user feedback
  - Specific error for missing app token during registration
  - `KeychainError` with localized descriptions
  - Proper error propagation through ViewModel layer

### Fixed

- **Security Vulnerabilities**
  - ❌ **Before**: App token hardcoded in source code
  - ✅ **After**: App token securely stored in Keychain + Secrets.xcconfig
  - ❌ **Before**: No SSL certificate validation
  - ✅ **After**: SSL pinning infrastructure ready for production

- **Logging Issues**
  - ❌ **Before**: `print()` statements scattered throughout ViewModels
  - ✅ **After**: Structured logging with `os.Logger` by category

- **Initialization Safety**
  - ❌ **Before**: `SharedModelContainer.shared!` could crash if initialization fails
  - ✅ **After**: Optional `SharedModelContainer.shared?` with graceful error handling

### Testing

- **Security Test Suite** (19 tests total)
  - `KeychainServiceTests` (14 tests)
    - AuthToken storage, retrieval, update, deletion
    - Email storage, retrieval, update, deletion
    - App token storage, retrieval, update (NEW)
    - Batch delete operations
    - Error handling scenarios
    - Serialized execution to prevent race conditions
  - `SSLPinningDelegateTests` (2 tests)
    - Behavior when pinning disabled
    - Challenge cancellation for invalid auth methods
    - Synchronous tests without expectations
  - `AuthenticationTests` updates (3 tests)
    - Register with app token from Keychain
    - Register failure when app token missing
    - Verify app token retrieval during registration
  - Files: `KeychainServiceTests.swift`, `SSLPinningDelegateTests.swift`, `AuthenticationTests+Interactor.swift`

### Documentation

- ✅ CHANGELOG.md updated for v3.0.1
- ✅ Secrets.xcconfig.example with setup instructions
- ✅ Test coverage for all security components
- ✅ SSL Pinning documentation with integration notes

### Notes

- **Backward Compatible**: Existing v3.0.0 users can upgrade seamlessly
- **Migration Required**: First-time users must configure `Secrets.xcconfig`
- **SSL Pinning**: Infrastructure ready, disabled for test server
- **Production Ready**: All security improvements validated with tests
- **No UI Changes**: All improvements are internal (security, logging, performance)

### Breaking Changes

**None** - This is a patch release with internal improvements only. No API or user-facing changes.

---

## [3.0.0] - 2026-02-15

### 🎉 Deluxe Version Release - Multi-Platform Support & Static Widgets

**Inku v3.0.0** introduces comprehensive multi-platform support across iOS, iPadOS, macOS, and visionOS, along with native widgets for all platforms. Users can now access their manga collection from any Apple device with a consistent, platform-optimized experience. The new widget system allows quick access to collection progress directly from the home screen, lock screen, or desktop.

### Added

#### Multi-Platform Support (macOS + visionOS)

- **macOS Native App** - Full-featured desktop experience
  - NavigationSplitView with collapsible sidebar
  - 4 navigation sections: Browse, Collection, Search, Profile
  - Keyboard shortcuts for navigation (⌘1-4)
  - Toggle sidebar command (⌘⌥S) with localized menu and icon
  - Native macOS menu commands with SF Symbol icons
  - Minimum window size: 800x600
  - Application Support directory for data storage
  - All features from iOS version fully functional
  - Files: `InkuMacApp.swift`, `MacOSRootView.swift`

- **visionOS Native App** - Spatial computing optimized
  - Tab-based navigation optimized for visionOS
  - Adaptive layouts for immersive environment
  - All core features available in spatial interface
  - App Group shared storage with iOS/iPadOS
  - Files: `InkuVisionApp.swift`

- **Platform-Specific Optimizations**
  - SharedModelContainer with platform-specific storage paths
  - iOS/visionOS: App Group for widget data sharing
  - macOS: Application Support directory for user data
  - DRY refactoring with reusable configuration methods
  - Files: `SharedModelContainer.swift`

#### Widget Support (All Platforms)

- **InkuCollectionWidget** - Multi-size widget family
  - **Small Widget**: Single manga card with progress
  - **Medium Widget**: 2 manga cards horizontally
  - **Large Widget**: 4 manga cards in 2x2 grid
  - **Extra Large Widget**: 6 manga cards in 2x3 grid
  - Live data from SwiftData with automatic updates
  - Empty state with localized messages
  - Adaptive layouts per widget size
  - Files: `InkuWidget.swift`, `SmallWidgetView.swift`, `MediumWidgetView.swift`, `LargeWidgetView.swift`, `ExtraLargeWidgetView.swift`

- **Widget Data Provider**
  - InkuWidgetProvider with timeline updates
  - Fetches up to 6 manga from collection
  - Sort order: Date Added (desc) → Last Modified (desc)
  - Filters for reading + collection manga
  - Snapshot support for widget gallery
  - App Group shared ModelContainer
  - Files: `InkuWidget.swift`

- **Widget Models**
  - WidgetMangaData for efficient data transfer
  - Cover image data caching
  - Volume and progress tracking
  - Lightweight model optimized for widgets
  - Files: `WidgetMangaData.swift`

- **Widget Localization**
  - Complete Spanish/English support
  - Localized widget configuration description
  - Empty state messages (title, message, hint)
  - "Collection" section title
  - Files: `Localizable.xcstrings` with WIDGET_* keys

#### Architecture Improvements

- **Dependency Injection Fix**
  - Fixed critical bug where CollectionViewModel wasn't injected into AuthViewModel
  - Added `setupViewModels()` pattern in all app entry points
  - Ensures `authViewModel.setCollectionViewModel()` called on launch
  - Fixes CRUD operations (delete, edit) that depend on CollectionViewModel
  - Applied to: InkuApp, InkuMacApp, InkuVisionApp
  - Files: `InkuApp.swift:32-36`, `InkuMacApp.swift:32-36`, `InkuVisionApp.swift`

- **SharedModelContainer DRY Refactoring**
  - Extracted repeated configuration code into reusable methods
  - `createModelConfiguration(for:)` - Platform decision logic
  - `appGroupStoreURL()` - App Group URL helper
  - `applicationSupportStoreURL()` - macOS Application Support helper
  - `createConfiguration(for:at:)` - ModelConfiguration creation
  - `createDefaultConfiguration(for:)` - Fallback configuration
  - Platform-specific methods: `createIOSConfiguration`, `createMacOSConfiguration`, `createVisionOSConfiguration`
  - Better maintainability and clarity
  - Files: `SharedModelContainer.swift`

#### Localization Enhancements

- **macOS Command Localization**
  - Added `COMMAND_TOGGLE_SIDEBAR` key
  - English: "Toggle Sidebar"
  - Spanish: "Alternar Barra Lateral"
  - L10n.Commands enum for type-safe access
  - SF Symbol icon: "sidebar.left"
  - Files: `Localizable.xcstrings`, `L10n.swift`

### Changed

#### User Experience Improvements

- **Widget Sort Order**
  - Changed from prioritizing currently reading manga
  - Now shows most recently added/modified manga first
  - Sort: dateAdded (desc) → lastModified (desc)
  - Better reflects user's active collection
  - Files: `InkuWidget.swift`

- **Widget Preview Data**
  - Updated with real manga information
  - 6 featured manga: Monster, Berserk, 20th Century Boys, Yokohama Kaidashi Kikou, Hajime no Ippo, Full Moon wo Sagashite
  - Avoided code duplication by extracting coverURL variables
  - Safe URL handling with flatMap (no force unwrapping)
  - Files: `SmallWidgetView.swift`, `MediumWidgetView.swift`, `LargeWidgetView.swift`, `ExtraLargeWidgetView.swift`

#### Version Management

- **Version Synchronization**
  - Fixed CFBundleShortVersionString mismatch warning
  - All targets now synchronized at 3.0.0:
    - Inku (main app)
    - InkuWidget (widget extension)
    - InkuTests (test target)
  - MARKETING_VERSION updated across project
  - Files: `Inku.xcodeproj/project.pbxproj`

### Fixed

- **Critical CRUD Bug**
  - **Issue**: "Attempt to present alert while presentation is in progress" when editing/deleting manga
  - **Root Cause**: CollectionViewModel not available in AuthViewModel (guard failed at AuthViewModel:368)
  - **Solution**: Injected CollectionViewModel at app initialization for all platforms
  - Now deleteMangaFromCollection and other collection operations work properly
  - Files: `InkuApp.swift`, `InkuMacApp.swift`, `InkuVisionApp.swift`

- **Version Mismatch Warning**
  - Fixed: "CFBundleShortVersionString of app extension ('1.0') must match parent app ('2.0.0')"
  - All targets now have matching version numbers
  - Prevents App Store validation issues
  - Files: `Inku.xcodeproj/project.pbxproj`

### Platform Support

- **Supported Platforms**:
  - iOS 18.6+ (iPhone)
  - iPadOS 18.6+ (iPad)
  - macOS 15.0+ (Mac)
  - visionOS 2.0+ (Apple Vision Pro)

- **Widget Availability**:
  - iOS: Home Screen, Lock Screen, StandBy
  - iPadOS: Home Screen, Lock Screen
  - macOS: Notification Center, Desktop
  - All sizes available on all platforms

### Documentation

- ✅ CHANGELOG.md updated for v3.0.0
- ✅ Version bumped to 3.0.0 in project file
- ✅ Widget localization keys added
- ✅ macOS command localization added
- ✅ Platform-specific storage documented
- ✅ Dependency injection pattern documented

### Notes

- **Multi-Platform Ready**: All core features work seamlessly across iOS, iPadOS, macOS, and visionOS
- **Widget Extensions**: Separate widget extension target shares data via App Group
- **Backward Compatible**: Existing iOS/iPadOS users can upgrade without data loss
- **Migration Path**: macOS and visionOS automatically access shared collection when installed

---

## [2.0.0] - 2026-02-06

### 🎉 Advanced Version Release - Authentication & Cloud Sync

**Inku v2.0.0** introduces a complete authentication system with user accounts, profile management, and bidirectional cloud synchronization. Users can now create accounts, log in, and automatically sync their manga collections across devices with intelligent conflict resolution.

### Added

#### Authentication System (AuthView + AuthViewModel)

- **Dual-mode authentication UI** - Login and Sign Up tabs with smooth transitions
- **Form validation** - Real-time validation for email, username, and password
- **Password requirements** - Minimum 8 characters with visual validation
- **Secure input** - SecureField with show/hide toggle
- **Error handling** - Contextual error messages by type (auth, network, validation)
- **Loading states** - Indicators during async operations
- **Auto-dismiss** - Sheet closes automatically after successful login/registration
- **Email validation** - Regex pattern for valid email format
- **Username validation** - No spaces, limited special characters
- **Session management** - Token persistence with UserDefaults/Keychain
- **Logout functionality** - Complete session cleanup and redirection
- **Clean Architecture** - AuthInteractor (protocol-first) + AuthViewModel (@Observable)
- **Files**: `AuthView.swift`, `AuthViewModel.swift`, `AuthInteractor.swift`, `AuthInteractorProtocol.swift`

#### Profile View (ProfileView)

- **User information display** - Username, email, registration date
- **Collection statistics** - Total manga, volumes, chapters in collection
- **Status breakdown** - Visual breakdown by reading status (Reading, Completed, Plan to Read, etc.)
- **Sync controls** - Manual sync button with progress indicator
- **Last sync timestamp** - Shows last successful synchronization
- **Logout button** - Confirmation alert before closing session
- **Error alerts** - Specific messages for sync failures
- **Loading states** - Skeleton views during data loading
- **Adaptive layout** - Optimized for iPhone and iPad
- **InkuUI integration** - Uses tokens (spacing, radius, colors) and components
- **Files**: `ProfileView.swift`

#### Cloud Sync System

- **Automatic sync** - Automatic synchronization after successful login/registration
- **Manual sync** - Button in ProfileView for on-demand sync
- **Bidirectional sync** - Local → Cloud and Cloud → Local
- **Conflict resolution** - Timestamps to determine most recent version
- **Batch operations** - Efficient loading and sending of complete collections
- **Incremental updates** - Only syncs changes since last update
- **Background updates** - Sync when returning to app (scene phase)
- **Error recovery** - Automatic retries and informative error messages
- **Local-first** - Full offline functionality, sync when connected
- **Delete propagation** - Local deletions reflected in cloud
- **Add propagation** - New local manga uploaded to cloud
- **Update propagation** - Status/progress changes synchronized
- **Files**: Updated `CollectionViewModel.swift`, `AuthViewModel.swift`

#### API Integration (AuthInteractor + NetworkService)

- **POST /auth/register** - New user registration (actually POST /users)
- **POST /auth/login** - Authentication with email/password (actually POST /users/login)
- **GET /user/profile** - Profile data retrieval
- **GET /collection** - Download collection from cloud (GET /collection/manga)
- **POST /collection** - Upload complete collection to cloud (POST /collection/manga)
- **PUT /collection/:id** - Individual manga update
- **DELETE /collection/:id** - Delete manga from cloud (DELETE /collection/manga/:id)
- **Authorization headers** - Bearer token in all authenticated requests
- **Error mapping** - AuthError with specific cases (invalidCredentials, userExists, etc.)
- **Timeout handling** - Network timeout management
- **Decodable models** - UserResponse, AuthResponse, CloudManga with local model mapping
- **Files**: `AuthInteractor.swift`, `NetworkService.swift`, `APIEndpoints.swift`

#### Code Organization & Architecture

- **Feature-based structure**:
  - `Features/Auth/` with Models, Interactor (Protocol + Spy), ViewModel, Views
  - `Features/Profile/` with dedicated View
  - `Features/Collection/` updated with sync logic
- **Protocol-first design** - `AuthInteractorProtocol` for testability
- **Dependency Injection** - Interactor injected into ViewModel, ViewModel into View
- **@Observable pattern** - ViewModels use Observation framework
- **@State ownership** - Views own ViewModels via @State
- **Async/await** - All async operations with async/await (no Combine)
- **MARK comments** - Strict ordering (Properties → States → Environment → Body → Init → Functions)
- **Error types** - AuthError, NetworkError enums for typed error handling
- **Environment Objects** - AuthViewModel in environment for global access
- **ViewModifier injection** - CollectionViewModel receives AuthViewModel for sync

#### Testing (Swift Testing Framework)

- **Comprehensive test suite** - 15+ tests covering login, register, sync, errors
- **Spy pattern** - `SpyAuthInteractor` with configurable flags and data
- **ViewModel tests** - Login, register, logout, validation, error handling
- **Interactor tests** - API calls, token storage, error mapping
- **Sync tests** - Conflict resolution, batch operations, error recovery
- **@MainActor** - ViewModel tests executed on main actor
- **Async testing** - `@Test func testName() async` pattern
- **Organized suites** - `@Suite` for Auth, Profile, Sync
- **Clear assertions** - `#expect()` with descriptive messages
- **Mock data** - Fixtures for users, tokens, manga collections
- **Isolated tests** - No dependencies between tests, independent setup
- **Files**: `AuthTests.swift`, `AuthTests+ViewModel.swift`, `AuthTests+Interactor.swift`

#### Localization

- **AuthLocalizable.xcstrings** - Complete strings for AuthView (login, register, validation)
- **ProfileLocalizable.xcstrings** - Strings for ProfileView (stats, sync, logout)
- **Spanish + English** - Full coverage in both languages
- **Error messages** - Localized messages for all error types
- **Validation feedback** - Localized validation feedback
- **Button labels** - Contextual labels (Login/Register, Sync, Logout)
- **Status descriptions** - Localized reading status names
- **Type-safe access** - L10n.Auth and L10n.Profile enums
- **Files**: `AuthLocalizable.xcstrings`, `ProfileLocalizable.xcstrings`

#### UX/UI Improvements

- **Onboarding flow** - First-time automatically shows AuthView
- **Tab bar integration** - ProfileView in 3rd tab with person.circle icon
- **Sheet presentation** - AuthView as sheet with `.presentationDetents([.large])`
- **Form sections** - Visual grouping of inputs by function
- **Visual feedback** - Checkmarks, error icons, loading spinners
- **Keyboard handling** - Submit buttons and keyboard dismissal
- **Secure by default** - Hidden passwords, show/hide options
- **Confirmation alerts** - Confirmation before logout
- **Success feedback** - Toast/alert after successful operations
- **Adaptive colors** - Uses `.inkuText`, `.inkuSurface` from InkuUI
- **Spacing tokens** - `InkuSpacing` for visual consistency
- **Glass effects** - InkuGlass for buttons and surfaces

### Changed

#### User Experience Improvements

- **Session persistence** - Users stay logged in between app launches
- **Automatic sync** - Collections sync automatically after authentication
- **Smart error messages** - Context-aware error messages for different failure scenarios
- **Loading overlays** - Non-intrusive loading indicators during sync
- **Logout confirmation** - Prevents accidental session termination

#### Collection Management

- **Cloud backup** - All collection data backed up to cloud
- **Cross-device sync** - Access collection from any device
- **Conflict resolution** - Automatic resolution using timestamps (most recent wins)
- **Sync status tracking** - Visual indication of last sync time

### Fixed

- **Token expiration handling** - Graceful handling of expired tokens
- **Network error recovery** - Better error messages and retry logic
- **Form validation edge cases** - Improved validation for special characters
- **Sync race conditions** - Proper handling of concurrent sync operations

### Testing

- ✅ 15+ comprehensive tests for Authentication and Sync
- ✅ ViewModel tests with Spy interactors
- ✅ Interactor tests with SpyNetworkService
- ✅ Sync logic integration tests
- ✅ All existing tests passing

### Documentation

- ✅ README.md updated for v2.0.0
- ✅ Added Authentication & Cloud Sync features section
- ✅ Updated API section (authentication with Bearer tokens)
- ✅ Added AuthLocalizable.xcstrings and ProfileLocalizable.xcstrings to localization files
- ✅ Updated roadmap with v2.0.0 progress
- ✅ Added placeholders for v2.0.0 screenshots

### Notes

- **Breaking Changes**: Users must create accounts to use cloud features
- **Backward Compatible**: Local-only functionality still works without authentication
- **Migration Path**: Existing local collections automatically sync on first login

---

## [1.5.0] - 2026-01-29

### 🎉 Medium Version Release - Advanced Filters & Grid View

**Inku v1.5.0** enhances the manga browsing experience with advanced multi-criteria filtering and adaptive grid view. This release includes comprehensive search capabilities, presentation mode toggle, and InkuUI enhancements for improved visual consistency.

### Added

#### Advanced Filters Feature

- **AdvancedFilterView** - Multi-criteria search interface
  - Simultaneous search by title, author (first/last name), genres, demographics, and themes
  - Search modes: Contains (default) and Begins With for title searches
  - Multi-select pickers for genres, demographics, and themes
  - 6 sort options: Score ↑↓, Title A-Z/Z-A, Volumes ↑↓
  - Preloaded data from MangaListViewModel (genres, demographics, themes)
  - Preselection support for continuing existing searches
  - Smart search button (enabled only when criteria present)
  - Clear all functionality for resetting filters
  - Form-based UI with `.presentationSizing(.form)`
  - Files: `AdvancedFilterView.swift`, `FilterDisclosureSection.swift`

- **AdvancedFilters Architecture** - Complete Clean Architecture implementation
  - `AdvancedFiltersInteractor` with protocol-first design
  - `AdvancedFiltersViewModel` with @Observable pattern
  - `MockAdvancedFiltersInteractor` for previews
  - `SpyAdvancedFiltersInteractor` for testing
  - Integration with existing MangaListViewModel
  - Files: `AdvancedFiltersInteractor.swift`, `AdvancedFiltersViewModel.swift`

- **Models for Advanced Search**
  - `CustomSearch` model with multi-criteria support
  - `SearchSortOption` enum with 6 sorting options
  - Integration with existing `MangaFilter` enum
  - Files: `CustomSearch.swift`, `SearchSortOption.swift`

- **Localization for Advanced Filters**
  - Complete Spanish/English support in `AdvancedFiltersLocalizable.xcstrings`
  - 50+ localized strings for filters UI
  - Sort options, placeholders, error messages
  - Multi-select picker strings

- **Comprehensive Test Suite** (37 tests)
  - ViewModel tests: search building, clearing, validation
  - Interactor tests: API integration, error handling
  - Integration tests: MangaListViewModel with advanced filters
  - Spy pattern for dependency injection
  - Files: `AdvancedFiltersTests.swift`, `MangaListTests+AdvancedFilters.swift`

#### Grid View Feature

- **Grid View for MangaList** - Browse manga in adaptive grid layout
  - Toggle button to switch between list and grid presentation modes
  - Adaptive grid: 2 columns (iPhone), 4-6 columns (iPad based on width)
  - MangaCardView component for grid items
  - MangaGridView and MangaGridSkeletonView components
  - Presentation mode persistence with @AppStorage
  - Spring animation transitions between modes for noticeable effect
  - Files: `MangaPresentationMode.swift`, `MangaCardView.swift`, `MangaGridView.swift`, `MangaGridSkeletonView.swift`

- **Adaptive 2-Column Grid for List Mode** - Responsive list layout
  - Automatically switches to 2-column grid when horizontal space allows (width >= 700)
  - Always uses grid on iPad (.regular size class)
  - Dynamic column count: 1-2 columns based on device and width
  - Matches CollectionListView adaptive pattern
  - Files: `MangaListView.swift`

- **Enhanced InkuMangaCard** (InkuUI v1.11.0)
  - Added score display with star rating
  - Added status indicator (publishing/completed/hiatus/discontinued)
  - Renamed badge parameter to genre for clarity
  - Consistent information parity with InkuMangaRow
  - Updated previews with new parameters

- **ViewModifier Organization** - Improved code structure
  - Separated LiquidGlassBackgroundModifier into individual file
  - Separated TabBarMinimizeBehaviorModifier into individual file with dedicated extension
  - Added MARK comments for better code organization
  - Files: `View+LiquidGlass.swift`, `View+TabBarMinimizeBehavior.swift`

#### MangaList Enhancements

- **Advanced filter integration** in MangaListViewModel
  - `currentAdvancedSearch` and `currentSortOption` state tracking
  - `isAdvancedFilterActive` computed property
  - `applyAdvancedSearch(_:sortOption:)` async function
  - `clearFilters()` resets both simple and advanced filters
  - Smart toolbar icons (filled when filters active)
  - Error handling with retry option

- **New API endpoint** for advanced search
  - `/manga/search/advanced` with POST method
  - Accepts `CustomSearch` model with multi-criteria
  - Returns paginated `MangaResponse`
  - Added to `NetworkService` and `APIEndpoints`

### Changed

#### InkuUI v1.11.0 - Enhanced Components

- **InkuMangaCard** now shows score and status
  - Added `score: Double?` parameter with star rating
  - Added `status: Status?` parameter with color-coded indicator
  - Renamed `badge` → `genre` for clarity
  - Status enum: `.publishing`, `.completed`, `.hiatus`, `.discontinued`
  - Status colors: green (publishing), blue (completed), orange (hiatus), red (discontinued)
  - Better visual consistency between row and card layouts
  - Backward compatible (score and status are optional)

#### User Experience Improvements

- **Animation Improvements** - More noticeable transitions
  - Changed from `.smooth(duration: 0.3)` to `.spring(response: 0.35, dampingFraction: 0.75)`
  - Spring animation provides better visual feedback for presentation mode toggle
  - More natural and noticeable transition effect

- **Smart UI behaviors**
  - Filter menu disabled when error present
  - Retry opens advanced filters if they were active
  - Toast-style error messages for filter errors
  - Loading states during advanced search

#### Code Organization

- **MARK Comment Ordering** - Standardized code structure
  - Fixed ordering in MangaListView: States → Environment → Initializers
  - Renamed "Computed Properties" to "Private Functions" for consistency
  - Follows established pattern across the codebase

- **ViewModifier separation**
  - Each ViewModifier in its own file
  - MARK comments for View Extension and View Modifier sections
  - Private structs for internal modifiers

### Fixed

- **InkuCoverImage aspect ratio** - Changed from `.fill` to `.fit`
  - Prevents horizontal manga covers from being cropped incorrectly
  - Ensures covers maintain proper aspect ratio in all contexts
  - Updated MangaHeaderSection layout after aspect ratio change

- **MangaHeaderSection layout** - Scorebadge positioning
  - Fixed scorebadge placement after aspect ratio fix
  - Moved from ZStack overlay to position below titles
  - More consistent visual hierarchy

### Testing

- ✅ 37 comprehensive tests for Advanced Filters
- ✅ ViewModel tests with Spy interactors
- ✅ Interactor tests with SpyNetworkService
- ✅ Integration tests for MangaListViewModel
- ✅ All existing tests passing

### Documentation

- ✅ README.md updated for v1.5.0
- ✅ Added v1.5.0 features section
- ✅ Updated code organization diagram
- ✅ Added AdvancedFiltersLocalizable.xcstrings to localization files
- ✅ Updated roadmap with completed v1.5.0 and future versions

---

### 📚 Documentation

**Major documentation restructuring to separate reusable patterns from project-specific content.**

> **Note**: These are documentation-only changes. No code changes to v1.0.0. These will be included in the next version release.

### Added

#### skills/ - Reusable iOS Development Patterns (5 files, ~3,500 lines)

- `skills/clean-architecture-ios/SKILL.md` - Complete Clean Architecture guide
  - **CORRECTED**: Mock vs Spy terminology (Mock for previews, Spy for tests)
  - Production, Mock, and Spy implementation patterns
  - Dependency injection patterns
  - Feature-based organization

- `skills/swiftui-observable/SKILL.md` - SwiftUI + Observation patterns
  - @Observable patterns with @State ownership
  - MARK comment structure (10-section order)
  - Async/await patterns and pagination
  - Error handling and state management

- `skills/swift-testing-patterns/SKILL.md` - Modern testing patterns
  - Swift Testing framework (@Test, @Suite, #expect)
  - Spy pattern with tracking properties
  - SUT (Subject Under Test) pattern
  - Parameterized testing

- `skills/swiftui-components/SKILL.md` - Component patterns
  - One component = one file rule
  - @ViewBuilder usage
  - Custom view modifiers
  - Liquid Glass guidelines (DO/DON'T tables)

- `skills/ios-localization/SKILL.md` - Localization patterns
  - String Catalog (.xcstrings) patterns
  - Type-safe L10n enum structure
  - Pluralization and interpolation
  - Package localization (#bundle vs .module)

#### specs/ - Inku-Specific Documentation

- `specs/project-overview.md` - Complete Inku project description
  - Technology stack, all features, iPad optimization
  - InkuUI design system overview
  - Current status and roadmap

- `specs/api-endpoints.md` - Complete MangaAPI documentation
  - All 15+ endpoints with request/response examples
  - Swift models for all API responses
  - Error handling and pagination patterns

- `specs/inku-ui-design-system.md` - InkuUI Design System
  - Combined specs 07 + 09
  - Inku color palette (#FFD0B5 accent)
  - InkuUI Swift Package v1.9.1 documentation
  - All components, design tokens, view modifiers
  - Decision tree for Library vs App components

- `REORGANIZATION_SUMMARY.md` - Complete reorganization guide
  - What changed and why
  - File statistics (~5,000 lines total)
  - Implementation details

### Changed

- **CLAUDE.md** - Updated with new documentation structure
  - Skills (reusable patterns) section
  - Specs (project-specific) section
  - Clear guidance on which file to read for each task
  - Updated project structure diagram

### Fixed

- **Terminology Correction**: Mock vs Spy in Clean Architecture
  - **Before**: Specs incorrectly said "Two implementations: Production + Spy"
  - **After**: Correctly documented three implementations:
    - **Production**: Real app logic (e.g., `MangaListInteractor`)
    - **Mock**: For previews and manual testing (e.g., `MockMangaListInteractor`)
    - **Spy**: For unit tests with tracking (e.g., `SpyMangaListInteractor` in test target)
  - This now matches the actual implementation in Inku v1.0.0

### Documentation

#### Benefits of Reorganization

**Before** (specs-only):
- ❌ Mixed reusable patterns with Inku-specific details
- ❌ Hard to reuse knowledge in other projects
- ❌ Unclear what's general vs project-specific
- ❌ Inconsistent terminology (Spy vs Mock confusion)

**After** (specs + skills):
- ✅ Clear separation: patterns vs project details
- ✅ Skills are 100% reusable in other iOS projects
- ✅ Specs are concise and Inku-focused
- ✅ Corrected Mock/Spy terminology matches codebase
- ✅ Better Claude Code context management

### Notes

- **No version bump**: These are documentation-only changes
- v1.0.0 codebase remains unchanged
- Legacy numbered specs (01-09) retained for reference
- New documentation structure improves Claude Code context management
- All corrections verified against actual v1.0.0 implementation

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
