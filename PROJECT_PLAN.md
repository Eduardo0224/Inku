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

### Phase 3: Advanced Version (v2.0.0)

**Requirements**:
- ✅ Everything from Medium Version (v1.5.0)
- ✅ **Cloud storage** for user collection
- ✅ **User authentication** (registration and login)
- ✅ **Token/credentials** stored in Keychain
- ⚠️ Local persistence optional (recommended for offline support)

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

### Phase 4: Deluxe Version (v3.0.0)

**Requirements**:
- ✅ Everything from Advanced Version (v2.0.0)
- ✅ **Multi-platform support** (at least one additional Apple platform)
- ✅ **Static Widget** showing reading progress

#### Feature 10: Multi-Platform Support
**Description**: Extend app to additional Apple platforms

**Platforms** (choose at least one):
- **macOS**: Full desktop experience
- **watchOS**: Quick collection overview and reading progress
- **tvOS**: Browse and view collection on Apple TV

**User Stories**:
- As a user, I want to access Inku on my Mac/Apple Watch/Apple TV
- As a user, I want a consistent experience across devices
- As a user, I want platform-specific optimizations

**UI Components** (platform-specific):
- macOS: Multi-column layout, keyboard shortcuts, menu bar
- watchOS: Complications, glances, simple navigation
- tvOS: Focus-based navigation, large text, remote control support

---

#### Feature 11: Widget
**Description**: Static widget showing current reading progress

**User Stories**:
- As a user, I want to see what I'm currently reading on my home screen
- As a user, I want to see my reading progress at a glance
- As a user, I want to quickly access mangas I'm reading

**Widget Types**:
- Small: Currently reading manga (1 manga)
- Medium: Reading list (2-3 mangas)
- Large: Full reading progress (4-6 mangas)

**Widget Data**:
- Manga cover image
- Manga title
- Current volume / Total volumes
- Reading progress percentage

**UI Components**:
- `MangaWidgetView`: Widget entry view
- `WidgetProvider`: Timeline provider for widget data

---

## Development Roadmap

### 🎯 Phase 1: Basic Version (v1.0.0) - MVP

#### Sprint 1: Foundation (Week 1)
- [x] Project setup and architecture
- [x] Git workflow and documentation
- [ ] Create `develop` branch
- [ ] Core models (Manga, Author, Genre, etc.)
- [ ] NetworkService implementation
- [ ] Basic error handling

#### Sprint 2: MangaList Feature (Week 1-2)
- [ ] MangaList models and DTOs
- [ ] MangaList interactor
- [ ] MangaList ViewModel
- [ ] MangaList views
- [ ] Pagination logic
- [ ] Basic filters (genre/demographic/theme)
- [ ] Unit tests

#### Sprint 3: MangaDetail Feature (Week 2)
- [ ] MangaDetail interactor
- [ ] MangaDetail ViewModel
- [ ] MangaDetail views
- [ ] Navigation integration
- [ ] Unit tests

#### Sprint 4: Search Feature (Week 2-3)
- [ ] Search models
- [ ] Search interactor
- [ ] Search ViewModel
- [ ] Search views
- [ ] Debouncing for search input
- [ ] Unit tests

#### Sprint 5: Collection Feature (Week 3)
- [ ] Local storage setup (SwiftData/JSON)
- [ ] Collection models
- [ ] Collection interactor
- [ ] Collection ViewModel
- [ ] Collection views
- [ ] Add/Edit/Delete operations
- [ ] Unit tests

#### Sprint 6: InkuUI Design System (Week 4)
- [ ] Create InkuUI package
- [ ] Design tokens (colors, spacing, radius)
- [ ] Reusable components
- [ ] Component tests

#### Sprint 7: Integration & Polish (Week 4)
- [ ] Navigation flow
- [ ] Loading states
- [ ] Error handling
- [ ] Empty states
- [ ] iPad layout optimization
- [ ] String localization
- [ ] Integration tests

#### Sprint 8: Testing & Release v1.0.0 (Week 5)
- [ ] Full app testing
- [ ] Bug fixes
- [ ] Performance optimization
- [ ] Documentation
- [ ] Release v1.0.0 🎉

---

### 🚀 Phase 2: Medium Version (v1.5.0) - Enhanced Filtering

#### Sprint 9: Advanced Filters (Week 6)
- [ ] CustomSearch model
- [ ] Multi-criteria search interactor
- [ ] Advanced filter ViewModel
- [ ] AdvancedFilterView UI
- [ ] MultiSelectFilterView UI
- [ ] Sort options implementation
- [ ] Unit tests

#### Sprint 10: Grid View (Week 6-7)
- [ ] Grid layout components
- [ ] MangaGridView implementation
- [ ] MangaGridItemView implementation
- [ ] View mode toggle
- [ ] Grid pagination
- [ ] Unit tests
- [ ] Release v1.5.0 🎉

---

### 🔐 Phase 3: Advanced Version (v2.0.0) - Cloud & Auth

#### Sprint 11: Authentication (Week 7-8)
- [ ] User and AuthToken models
- [ ] KeychainService implementation
- [ ] AuthService implementation
- [ ] TokenManager implementation
- [ ] Registration flow
- [ ] Login flow
- [ ] Token renewal logic
- [ ] Unit tests

#### Sprint 12: Cloud Collection (Week 8-9)
- [ ] Cloud collection models
- [ ] Cloud collection interactor
- [ ] CloudSyncService implementation
- [ ] Conflict resolution logic
- [ ] Sync status UI
- [ ] Collection CRUD with cloud
- [ ] Unit tests

#### Sprint 13: Integration & Testing (Week 9)
- [ ] Auth flow integration
- [ ] Offline support
- [ ] Error handling for network issues
- [ ] Migration from local to cloud
- [ ] Full integration testing
- [ ] Release v2.0.0 🎉

---

### 🌟 Phase 4: Deluxe Version (v3.0.0) - Multi-Platform & Widget

#### Sprint 14: Multi-Platform Support (Week 10-12)
**Choose at least ONE platform:**

**Option A: macOS**
- [ ] macOS target setup
- [ ] macOS-specific UI components
- [ ] Multi-column layout
- [ ] Keyboard shortcuts
- [ ] Menu bar integration
- [ ] Testing

**Option B: watchOS**
- [ ] watchOS target setup
- [ ] Watch-specific UI
- [ ] Complications
- [ ] Glances
- [ ] Testing

**Option C: tvOS**
- [ ] tvOS target setup
- [ ] Focus-based navigation
- [ ] Remote control support
- [ ] Large text optimization
- [ ] Testing

#### Sprint 15: Widget (Week 12-13)
- [ ] Widget extension setup
- [ ] Widget provider implementation
- [ ] Small widget view
- [ ] Medium widget view
- [ ] Large widget view
- [ ] Widget data refresh logic
- [ ] Testing

#### Sprint 16: Final Polish & Release (Week 13)
- [ ] Cross-platform testing
- [ ] Widget testing
- [ ] Performance optimization
- [ ] Documentation update
- [ ] Release v3.0.0 🎉🎊

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
- 🎯 **Target Version**: v1.0.0 (Basic/MVP)
- 🔄 **Next Step**: Create `develop` branch and start Feature 1 (MangaList)

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
