# Inku - Project Plan

## Project Overview

**Inku** is a manga collection management iOS/iPadOS app that consumes a REST API with 64,000+ manga titles. Users can browse, search, and manage their personal manga collection, tracking which volumes they own and their reading progress.

## Project Goals

- **Primary**: Deliver a functional MVP (Minimum Viable Product) for manga collection management
- **Secondary**: Implement advanced features (authentication, cloud sync, statistics)
- **Technical**: Demonstrate Clean Architecture, SwiftUI best practices, and professional Git workflow

## Technology Stack

- **Language**: Swift 6
- **UI Framework**: SwiftUI + Observation framework
- **Target**: iOS 26 (primary) with iOS 18 fallback
- **Architecture**: Clean Architecture (4 layers)
- **Testing**: Swift Testing framework
- **Design System**: InkuUI package
- **Localization**: Spanish & English (String Catalog)

## API Base URL

```
https://mymanga-acacademy-5607149ebe3d.herokuapp.com
```

**API Documentation (Swagger)**: https://mymanga-acacademy-5607149ebe3d.herokuapp.com/docs

---

## MVP Requirements (Version 1.0.0)

### Mandatory Features
1. ✅ Browse any manga from the database
2. ✅ At least one categorization in listings/filters (genre, demographic, or theme)
3. ✅ Save manga to local collection
4. ✅ Display user's collection
5. ✅ Functional layout for iPhone and iPad
6. ✅ Display manga cover images

### User Collection Data
- Number of volumes owned
- Current reading volume
- Complete collection flag

---

## Development Phases

### Phase 1: MVP - Core Features (v1.0.0)

#### Feature 1: MangaList
**Description**: Display paginated list of mangas with basic filtering

**User Stories**:
- As a user, I want to see a list of mangas so I can browse available titles
- As a user, I want to filter by genre/demographic/theme to find relevant mangas
- As a user, I want to see manga covers, titles, and basic info in the list
- As a user, I want to load more mangas by scrolling (pagination)

**Endpoints**:
- `GET /list/mangas?page={page}&per={per}` - Paginated list
- `GET /list/genres` - Get all genres
- `GET /list/demographics` - Get all demographics
- `GET /list/themes` - Get all themes
- `GET /list/mangaByGenre/{genre}?page={page}&per={per}` - Filter by genre
- `GET /list/mangaByDemographic/{demo}?page={page}&per={per}` - Filter by demographic
- `GET /list/mangaByTheme/{theme}?page={page}&per={per}` - Filter by theme

**Models**:
- `Manga`: Main manga model with all properties
- `Author`: Author info (id, firstName, lastName, role)
- `Genre`: Genre info (id, genre)
- `Demographic`: Demographic info (id, demographic)
- `Theme`: Theme info (id, theme)
- `MangaListResponse`: Wrapper with data and metadata
- `PaginationMetadata`: Pagination info (total, page, per)

**UI Components**:
- `MangaListView`: Main list view with filters
- `MangaRowView`: Individual manga row with cover, title, score
- `FilterSheetView`: Filter selection sheet
- `LoadingView`: Loading indicator
- `EmptyStateView`: Empty state when no results

---

#### Feature 2: MangaDetail
**Description**: Display detailed information about a specific manga

**User Stories**:
- As a user, I want to see full details of a manga
- As a user, I want to see the cover image, synopsis, authors, genres, etc.
- As a user, I want to add the manga to my collection from this screen

**Endpoints**:
- `GET /search/manga/{id}` - Get manga by ID

**Models**:
- Uses existing `Manga` model

**UI Components**:
- `MangaDetailView`: Main detail view
- `MangaCoverView`: Large cover image
- `MangaInfoSection`: Info section (volumes, chapters, status, score)
- `MangaAuthorsSection`: Authors list
- `MangaSynopsisSection`: Synopsis text
- `MangaTagsSection`: Genres, demographics, themes
- `AddToCollectionButton`: Button to add to collection

---

#### Feature 3: Search
**Description**: Search mangas by title or author

**User Stories**:
- As a user, I want to search mangas by title
- As a user, I want to search by author name
- As a user, I want to see search results as I type

**Endpoints**:
- `GET /search/mangasContains/{text}?page={page}&per={per}` - Search by title
- `GET /search/author/{name}` - Search by author

**Models**:
- Uses existing `Manga` and `Author` models
- `SearchQuery`: Search parameters

**UI Components**:
- `SearchView`: Main search view
- `SearchBarView`: Search input
- `SearchResultsView`: Results list (reuses `MangaRowView`)

---

#### Feature 4: Collection (Local Storage)
**Description**: Manage user's local manga collection

**User Stories**:
- As a user, I want to save mangas to my collection
- As a user, I want to track volumes owned and reading progress
- As a user, I want to mark if I have the complete collection
- As a user, I want to edit or remove mangas from my collection
- As a user, I want to see my collection organized

**Endpoints**:
- None (local storage only for MVP)

**Models**:
- `UserMangaCollection`: User's manga with collection data
  - manga: Manga
  - volumesOwned: [Int]
  - currentReadingVolume: Int?
  - hasCompleteCollection: Bool
  - dateAdded: Date

**Storage**:
- SwiftData or JSON file persistence

**UI Components**:
- `CollectionView`: Main collection view
- `CollectionItemView`: Collection item card
- `AddToCollectionSheet`: Sheet to add/edit manga in collection
- `CollectionStatsView`: Quick stats (total mangas, volumes, etc.)

---

#### Feature 5: Core Services
**Description**: Shared services for networking, caching, and persistence

**Services**:
- `NetworkService`: HTTP client for API calls
- `CacheService`: Image and data caching
- `PersistenceService`: Local storage for collection
- `ImageLoader`: Async image loading

---

### Phase 2: Medium Version (v1.5.0)

**Requirements**:
- ✅ Everything from Basic Version (v1.0.0)
- ✅ **Complete filter set** based on ALL categories (genres, demographics, themes)
- ✅ **Multiple view modes**: List, Detail, and Grid views

#### Feature 6: Advanced Filters
**Description**: Complete filtering system for all manga categories

**User Stories**:
- As a user, I want to filter by multiple genres simultaneously
- As a user, I want to filter by demographics (Shounen, Shoujo, Seinen, Kids, Josei)
- As a user, I want to filter by themes (School, Mecha, Vampires, etc.)
- As a user, I want to combine multiple filters
- As a user, I want to sort results (by score, date, title, etc.)

**Endpoints**:
- `POST /search/manga` - Custom search with multiple criteria

**Models**:
- `CustomSearch`: Multi-criteria search request
  - searchTitle: String?
  - searchAuthorFirstName: String?
  - searchAuthorLastName: String?
  - searchGenres: [String]?
  - searchThemes: [String]?
  - searchDemographics: [String]?
  - searchContains: Bool

**UI Components**:
- `AdvancedFilterView`: Complete filter interface
- `MultiSelectFilterView`: Multi-selection for genres/themes/demographics
- `SortOptionsView`: Sort options selector

---

#### Feature 7: Grid View
**Description**: Grid layout for manga browsing

**User Stories**:
- As a user, I want to see mangas in a grid layout
- As a user, I want to switch between list and grid views
- As a user, I want to see more content at once in grid mode

**UI Components**:
- `MangaGridView`: Grid layout view
- `MangaGridItemView`: Individual grid item with cover and title
- `ViewModeToggle`: Switch between list/grid modes

---

### Phase 3: Advanced Version (v2.0.0) ✅ COMPLETED

**Requirements**:
- ✅ Everything from Medium Version (v1.5.0)
- ✅ **Cloud storage** for user collection
- ✅ **User authentication** (registration and login)
- ✅ **Token/credentials** stored in Keychain
- ✅ Local persistence with offline support

#### Feature 8: Authentication
**Description**: Complete user authentication flow

**User Stories**:
- As a user, I want to create an account with email and password
- As a user, I want to log in to access my collection from any device
- As a user, I want my credentials stored securely
- As a user, I want automatic token renewal

**Endpoints**:
- `POST /users` - User registration (requires App-Token header)
- `POST /users/login` - Login (Basic Auth) → Returns TOKEN
- `POST /users/renew` - Renew token (Bearer Auth)

**Security**:
- App-Token: `"sLGH38NhEJ0_anlIWwhsz1-LarClEohiAHQqayF0FY"`
- Credentials: Basic Auth (base64 encoded username:password)
- Token: Bearer token (valid for 2 days)
- Storage: Keychain for sensitive data

**Models**:
- `User`: User credentials (email, password)
- `AuthToken`: Token with expiration
- `AuthState`: Current authentication state

**Services**:
- `AuthService`: Authentication management
- `KeychainService`: Secure credential storage
- `TokenManager`: Token lifecycle management

**UI Components**:
- `LoginView`: Login screen
- `RegistrationView`: Sign-up screen
- `AuthStateView`: Authentication state wrapper

---

#### Feature 9: Cloud Collection Sync
**Description**: Sync user collection with cloud API

**User Stories**:
- As a user, I want my collection stored in the cloud
- As a user, I want to access my collection from multiple devices
- As a user, I want to add/update/delete mangas in cloud
- As a user, I want offline support with local cache

**Endpoints**:
- `POST /collection/manga` - Add/update manga in collection (requires Bearer token)
- `GET /collection/manga` - Get user's collection (requires Bearer token)
- `GET /collection/manga/{mangaID}` - Get specific manga (requires Bearer token)
- `DELETE /collection/manga/{mangaID}` - Remove manga (requires Bearer token)

**Models**:
- `UserMangaCollectionRequest`: Request model
  - manga: Int (manga ID)
  - completeCollection: Bool
  - volumesOwned: [Int]
  - readingVolume: Int?

**Services**:
- `CloudSyncService`: Sync local and cloud data
- `ConflictResolver`: Resolve sync conflicts

**UI Components**:
- `SyncStatusView`: Cloud sync status indicator
- `ConflictResolutionSheet`: Resolve sync conflicts

---

### Phase 4: Deluxe Version (v3.0.0) ✅ COMPLETED

**Requirements**:
- ✅ Everything from Advanced Version (v2.0.0)
- ✅ **Multi-platform support** (macOS + visionOS)
- ✅ **Static Widget** showing reading progress (4 sizes)

#### Feature 10: Multi-Platform Support ✅
**Description**: Extend app to additional Apple platforms

**Platforms Implemented**:
- ✅ **macOS**: Full desktop experience with NavigationSplitView
- ✅ **visionOS**: Spatial computing optimized interface

**User Stories**:
- ✅ As a user, I want to access Inku on my Mac/Apple Vision Pro
- ✅ As a user, I want a consistent experience across devices
- ✅ As a user, I want platform-specific optimizations

**UI Components Implemented**:
- ✅ macOS: NavigationSplitView, keyboard shortcuts (⌘1-4, ⌘⌥S), menu commands
- ✅ visionOS: Tab-based navigation, adaptive layouts for immersive environment
- ✅ Platform-specific storage: App Groups (iOS/visionOS), Application Support (macOS)

---

#### Feature 11: Widget ✅
**Description**: Static widget showing current reading progress

**User Stories**:
- ✅ As a user, I want to see what I'm currently reading on my home screen
- ✅ As a user, I want to see my reading progress at a glance
- ✅ As a user, I want to quickly access mangas I'm reading

**Widget Types Implemented**:
- ✅ Small: 1 manga card with progress
- ✅ Medium: 2 manga cards horizontally
- ✅ Large: 4 manga cards in 2x2 grid
- ✅ Extra Large: 6 manga cards in 2x3 grid

**Widget Data**:
- ✅ Manga cover image (cached)
- ✅ Manga title
- ✅ Volumes owned / Total volumes
- ✅ Current reading volume

**UI Components Implemented**:
- ✅ `InkuWidget`: Widget entry and provider
- ✅ `SmallWidgetView`, `MediumWidgetView`, `LargeWidgetView`, `ExtraLargeWidgetView`
- ✅ `InkuWidgetProvider`: Timeline provider with live SwiftData integration
- ✅ `WidgetMangaData`: Widget-specific data model

---

## Development Roadmap

### 🎯 Phase 1: Basic Version (v1.0.0) - MVP ✅ COMPLETED

#### Sprint 1: Foundation (Week 1) ✅
- [x] Project setup and architecture
- [x] Git workflow and documentation
- [x] Create `develop` branch
- [x] Core models (Manga, Author, Genre, etc.)
- [x] NetworkService implementation
- [x] Basic error handling

#### Sprint 2: MangaList Feature (Week 1-2) ✅
- [x] MangaList models and DTOs
- [x] MangaList interactor
- [x] MangaList ViewModel
- [x] MangaList views
- [x] Pagination logic
- [x] Basic filters (genre/demographic/theme)
- [x] Unit tests (ViewModel + Interactor)
- [x] **PR #2**: feat(MangaList): Implement manga list feature

#### Sprint 3: MangaDetail Feature (Week 2) ✅
- [x] MangaDetail interactor (via CollectionInteractor)
- [x] MangaDetail ViewModel (stateless, uses environment)
- [x] MangaDetail views (Header, Stats, Synopsis, Authors, Tags)
- [x] Navigation integration
- [x] Add to collection functionality
- [x] **PR #6**: feat(Integration): Add Collection to MangaDetail navigation

#### Sprint 4: Search Feature (Week 2-3) ✅
- [x] Search models
- [x] Search interactor
- [x] Search ViewModel
- [x] Search views (manga and author scopes)
- [x] Debouncing for search input
- [x] Unit tests (ViewModel)
- [x] **PR #3**: feat(Search): Implement search feature

#### Sprint 5: Collection Feature (Week 3) ✅
- [x] Local storage setup (SwiftData)
- [x] Collection models (CollectionManga)
- [x] Collection interactor with protocol
- [x] Collection ViewModel with environment key
- [x] Collection views (List, Stats, Edit sheet)
- [x] Add/Edit/Delete operations
- [x] Unit tests (ViewModel + Interactor)
- [x] **PR #5**: feat(Collection): Add collection management

#### Sprint 6: InkuUI Design System (Week 4) ✅
- [x] Create InkuUI package
- [x] Design tokens (colors, spacing, radius, typography)
- [x] Reusable components (10+ components)
- [x] Component tests and previews
- [x] **Package v1.9.1**: Published as Swift Package

#### Sprint 7: Integration & Polish (Week 4) ✅
- [x] Navigation flow (all features connected)
- [x] Loading states (skeleton, pagination)
- [x] Error handling (alerts, retry actions)
- [x] Empty states (context-aware)
- [x] iPad layout optimization (adaptive layouts)
- [x] String localization (Spanish/English)
- [x] Integration tests
- [x] **PR #6**: feat(Integration): Complete MVP polish
- [x] **PR #7**: feat(iPad): Add comprehensive adaptive layouts

#### Sprint 8: Testing & Release v1.0.0 (Week 5) ✅
- [x] Full app testing
- [x] Bug fixes (preview crashes, navigation)
- [x] Performance optimization
- [x] Documentation (CHANGELOG.md, CLAUDE.md)
- [x] Custom app icon with adaptive variants
- [x] Code cleanup and DRY refactoring
- [x] **Ready for Release v1.0.0** 🎉

---

### 🚀 Phase 2: Medium Version (v1.5.0) - Enhanced Filtering ✅ COMPLETED

#### Sprint 9: Advanced Filters (Week 6) ✅
- [x] CustomSearch model
- [x] Multi-criteria search interactor
- [x] Advanced filter ViewModel
- [x] AdvancedFilterView UI
- [x] MultiSelectFilterView UI
- [x] Sort options implementation
- [x] Unit tests

#### Sprint 10: Grid View (Week 6-7) ✅
- [x] Grid layout components
- [x] MangaGridView implementation
- [x] MangaGridItemView implementation
- [x] View mode toggle
- [x] Grid pagination
- [x] Unit tests
- [x] Release v1.5.0 🎉

---

### 🔐 Phase 3: Advanced Version (v2.0.0) - Cloud & Auth ✅ COMPLETED

#### Sprint 11: Authentication (Week 7-8) ✅
- [x] User and AuthToken models
- [x] KeychainService implementation
- [x] AuthService implementation (AuthInteractor)
- [x] TokenManager implementation
- [x] Registration flow
- [x] Login flow
- [x] Token renewal logic
- [x] Unit tests

#### Sprint 12: Cloud Collection (Week 8-9) ✅
- [x] Cloud collection models
- [x] Cloud collection interactor
- [x] CloudSyncService implementation (in CollectionViewModel)
- [x] Conflict resolution logic (timestamp-based)
- [x] Sync status UI (ProfileView)
- [x] Collection CRUD with cloud
- [x] Unit tests

#### Sprint 13: Integration & Testing (Week 9) ✅
- [x] Auth flow integration
- [x] Offline support (local-first architecture)
- [x] Error handling for network issues
- [x] Migration from local to cloud (automatic on first login)
- [x] Full integration testing
- [x] Release v2.0.0 🎉

---

### 🌟 Phase 4: Deluxe Version (v3.0.0) - Multi-Platform & Widget ✅ COMPLETED

#### Sprint 14: Multi-Platform Support (Week 10-12) ✅
**Implemented Platforms:**

**macOS** ✅
- [x] macOS target setup
- [x] macOS-specific UI components (`InkuMacApp`, `MacOSRootView`)
- [x] NavigationSplitView layout
- [x] Keyboard shortcuts (⌘1-4, ⌘⌥S)
- [x] Localized menu commands with SF Symbol icons
- [x] Application Support storage
- [x] Testing

**visionOS** ✅
- [x] visionOS target setup
- [x] visionOS-specific UI (`InkuVisionApp`)
- [x] Tab-based navigation optimized for spatial computing
- [x] Adaptive layouts for immersive environment
- [x] App Group shared storage
- [x] Testing

#### Sprint 15: Widget (Week 12-13) ✅
- [x] Widget extension setup (`InkuWidget` target)
- [x] Widget provider implementation (`InkuWidgetProvider`)
- [x] Small widget view (1 manga)
- [x] Medium widget view (2 mangas)
- [x] Large widget view (4 mangas in 2x2 grid)
- [x] Extra Large widget view (6 mangas in 2x3 grid)
- [x] Widget data refresh logic with SwiftData timeline
- [x] Widget localization (Spanish/English)
- [x] Empty states with localized messages
- [x] Testing

#### Sprint 16: Final Polish & Release (Week 13) ✅
- [x] Cross-platform testing (iOS, iPadOS, macOS, visionOS)
- [x] Widget testing (all sizes, empty states)
- [x] Fixed critical CRUD bug (dependency injection)
- [x] SharedModelContainer DRY refactoring
- [x] Version synchronization (v3.0.0)
- [x] Documentation update (CHANGELOG.md, README.md)
- [x] Release v3.0.0 🎉🎊

---

### 📊 Version Summary

| Version | Release | Features | Estimated Time |
|---------|---------|----------|----------------|
| **v1.0.0** (Basic) | Week 5 | Browse, Search, Local Collection | 5 weeks |
| **v1.5.0** (Medium) | Week 7 | + Advanced Filters, Grid View | +2 weeks |
| **v2.0.0** (Advanced) | Week 9 | + Auth, Cloud Sync | +2 weeks |
| **v3.0.0** (Deluxe) | Week 13 | + Multi-Platform, Widget | +4 weeks |

**Total estimated time: 13 weeks** (3+ months for complete deluxe version)

---

## Feature Development Workflow

For each feature, follow this layer-by-layer approach:

1. **Models** → Review & Confirm ✅
2. **Interactor** → Review & Confirm ✅
3. **ViewModel** → Review & Confirm ✅
4. **Views** → Review & Confirm ✅
5. **Tests** → Review & Confirm ✅

---

## Current Status

- ✅ Project setup and architecture
- ✅ Git workflow (GITFLOW.md)
- ✅ Project plan with 4 versions
- ✅ Commit template configured
- ✅ **v1.0.0 COMPLETED** - MVP with all core features
- ✅ **v1.5.0 COMPLETED** - Advanced filters and grid view
- ✅ **v2.0.0 COMPLETED** - Authentication and cloud sync
- ✅ **v3.0.0 COMPLETED** - Multi-platform and widgets
- 🎉 **Release Status**: Ready for v3.0.0 tag
- 📋 **All Features Completed**:
  - ✅ MangaList with pagination and filters
  - ✅ Search (manga by title, author by name)
  - ✅ Advanced multi-criteria filters
  - ✅ Grid view with adaptive layouts
  - ✅ Collection management (SwiftData)
  - ✅ MangaDetail with full information
  - ✅ Authentication system (registration/login)
  - ✅ Cloud sync (bidirectional)
  - ✅ Profile view with sync controls
  - ✅ Multi-platform support (iOS, iPadOS, macOS, visionOS)
  - ✅ Widget system (Small, Medium, Large, Extra Large)
  - ✅ iPad adaptive layouts
  - ✅ InkuUI design system (v1.11.0+)
  - ✅ Spanish/English localization
  - ✅ Comprehensive test suite
- 🔄 **Next Step**: Merge feature/multi-platform-widget → develop → main and create v3.0.0 tag

---

## Delivery Strategy

### Recommended Approach: Incremental Delivery

**Priority 1 - REQUIRED**: Version 1.0.0 (Basic/MVP)
- This is the minimum viable product required for passing
- Focus all initial efforts here
- Estimated time: 5 weeks

**Priority 2 - OPTIONAL**: Version 1.5.0 (Medium)
- Adds advanced filtering and grid view
- Good for showcasing additional skills
- Estimated time: +2 weeks

**Priority 3 - OPTIONAL**: Version 2.0.0 (Advanced)
- Cloud sync and authentication
- Demonstrates full-stack capabilities
- Estimated time: +2 weeks

**Priority 4 - OPTIONAL**: Version 3.0.0 (Deluxe)
- Multi-platform and widget
- Maximum complexity and skill demonstration
- Estimated time: +4 weeks

### Development Recommendation

1. **Start with v1.0.0** - Get the MVP working perfectly
2. **Test thoroughly** - Ensure quality before adding features
3. **Evaluate time** - If time permits, move to v1.5.0
4. **Incremental releases** - Tag each version properly
5. **Document everything** - Update CHANGELOG.md with each version

---

## Notes

- **Code**: All code in English
- **UI**: Localized text (Spanish & English via String Catalog)
- **Architecture**: Follow Clean Architecture strictly
- **Testing**: Test coverage target 80%+
- **Documentation**: Document all public APIs
- **Async**: Use async/await for all network calls
- **Git**: Follow GITFLOW.md strategy for all branches and commits
- **Review**: Layer-by-layer review for each feature
- **Quality over quantity**: A perfect v1.0.0 is better than a buggy v3.0.0
