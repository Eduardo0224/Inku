# Multi-Platform Architecture - Inku v3.0.0

## Overview

Inku v3.0.0 extends the app to **macOS**, **tvOS**, and adds **iOS Widgets**, maintaining Clean Architecture principles and code reusability across platforms.

## Platform Support

| Platform | Version | Features |
|----------|---------|----------|
| **iOS** | 18.6+ | Original app with widgets |
| **macOS** | 15.0+ | Multi-column layout, keyboard shortcuts, menu bar |
| **tvOS** | 18.0+ | Focus-based navigation, remote control |

## Project Structure

```
Inku/
├── Inku/                           # iOS App Target
│   ├── InkuApp.swift               # iOS entry point
│   └── Info.plist
├── InkuMac/                        # macOS App Target
│   ├── InkuMacApp.swift            # macOS entry point
│   ├── macOS/                      # macOS-specific views
│   │   ├── MacMainView.swift
│   │   ├── MacSidebarView.swift
│   │   └── MacToolbar.swift
│   └── Info.plist
├── InkuTV/                         # tvOS App Target
│   ├── InkuTVApp.swift             # tvOS entry point
│   ├── tvOS/                       # tvOS-specific views
│   │   ├── TVMainView.swift
│   │   ├── TVCardView.swift
│   │   └── TVFocusGuide.swift
│   └── Info.plist
├── InkuWidget/                     # Widget Extension
│   ├── InkuWidget.swift            # Widget main file
│   ├── InkuWidgetBundle.swift      # Widget bundle
│   ├── Widgets/
│   │   ├── SmallWidget.swift
│   │   ├── MediumWidget.swift
│   │   └── LargeWidget.swift
│   └── Info.plist
├── Shared/                         # Shared code across all platforms
│   ├── Core/                       # Moved from Inku/Core
│   │   ├── Models/
│   │   ├── Services/
│   │   ├── Extensions/
│   │   └── Localization/
│   └── Features/                   # Moved from Inku/Features
│       ├── MangaList/
│       ├── Search/
│       ├── Collection/
│       ├── MangaDetail/
│       ├── Authentication/
│       ├── Profile/
│       └── AdvancedFilters/
└── Resources/                      # Shared resources
    ├── Assets.xcassets             # All platform assets
    └── *.xcstrings                 # Localization files
```

## Code Sharing Strategy

### Shared Code (Platform-Independent)

All **Core** and **Features** code is shared:
- ✅ Models (Manga, Author, CollectionManga, etc.)
- ✅ Interactors (MangaListInteractor, SearchInteractor, etc.)
- ✅ ViewModels (MangaListViewModel, SearchViewModel, etc.)
- ✅ Services (NetworkService, KeychainService, etc.)
- ✅ Extensions and utilities

### Platform-Specific Code

Each platform has its own entry point and UI adaptations:

#### iOS-Specific
- `InkuApp.swift` - TabView with iOS-specific modifiers
- iOS-only modifiers (`.tabBarMinimizeBehaviorOnScrollDown()`)
- iPhone/iPad adaptive layouts

#### macOS-Specific
- `InkuMacApp.swift` - NavigationSplitView with sidebar
- Keyboard shortcuts (⌘N, ⌘F, ⌘,)
- Menu bar commands
- Multi-window support
- Toolbar items

#### tvOS-Specific
- `InkuTVApp.swift` - Focus-based TabView
- Large text and spacing for TV viewing distance
- Remote control navigation
- Focus guides for complex layouts
- Simplified UI (no forms, no keyboards)

#### Widget Extension
- Timeline Provider for data updates
- Small/Medium/Large widget views
- App Intents for widget configuration
- Shared access to SwiftData container

## Platform Detection

Use compiler directives for platform-specific code:

```swift
#if os(iOS)
// iOS-only code
.tabViewStyle(.sidebarAdaptable)
.tabBarMinimizeBehaviorOnScrollDown()
#elseif os(macOS)
// macOS-only code
.navigationSplitViewStyle(.balanced)
.toolbar { /* macOS toolbar */ }
#elseif os(tvOS)
// tvOS-only code
.focusSection()
.padding(.horizontal, 90)
#endif
```

## InkuUI Compatibility

InkuUI package is shared across all platforms with platform-specific adaptations:

### Cross-Platform Components
- ✅ `InkuMangaRow` - Works on all platforms
- ✅ `InkuCoverImage` - AsyncImage works everywhere
- ✅ `InkuEmptyView` - Platform-agnostic empty state
- ✅ `InkuLoadingView` - Progress indicators on all platforms

### Platform-Specific Tokens
```swift
// Spacing adapts to platform
#if os(tvOS)
InkuSpacing.spacing32  // Larger for TV
#else
InkuSpacing.spacing16  // Standard for iOS/macOS
#endif
```

## SwiftData Sharing

All platforms share the same SwiftData container:

```swift
// Shared model container
.modelContainer(for: CollectionManga.self)
```

**Important**: Widget extension needs App Group for shared data access.

### App Group Setup
1. Create App Group: `group.com.eduardoandrade.inku`
2. Enable in all targets: iOS app, macOS app, Widget extension
3. Configure SwiftData container with shared URL:

```swift
let groupContainer = FileManager.default.containerURL(
    forSecurityApplicationGroupIdentifier: "group.com.eduardoandrade.inku"
)
let storeURL = groupContainer!.appendingPathComponent("Inku.sqlite")
```

## Navigation Patterns

### iOS (TabView)
```swift
TabView {
    Tab("Browse", systemImage: "books.vertical") {
        MangaListView()
    }
    // ... other tabs
}
.tabViewStyle(.sidebarAdaptable)
```

### macOS (NavigationSplitView)
```swift
NavigationSplitView {
    MacSidebarView(selection: $selectedSection)
} detail: {
    switch selectedSection {
    case .browse: MangaListView()
    case .collection: CollectionView()
    case .search: SearchView()
    case .profile: ProfileView()
    }
}
```

### tvOS (Focus-Based TabView)
```swift
TabView {
    MangaListView()
        .tabItem { Label("Browse", systemImage: "books.vertical") }
    CollectionView()
        .tabItem { Label("Collection", systemImage: "bookmark") }
}
.focusSection()  // tvOS focus container
```

## Widget Architecture

### Widget Family Support
- **Small**: Single manga currently reading
- **Medium**: 2 manga with progress bars
- **Large**: Up to 4 manga with detailed info

### Timeline Provider
```swift
struct Provider: TimelineProvider {
    func timeline(for configuration: ConfigurationIntent, in context: Context) async -> Timeline<Entry> {
        // Fetch from shared SwiftData container
        // Return timeline with 15-minute refresh
    }
}
```

### Widget Views
```swift
struct SmallWidgetView: View {
    let manga: CollectionManga

    var body: some View {
        VStack {
            InkuCoverImage(url: manga.manga.mainPicture)
                .frame(height: 100)
            Text(manga.manga.title)
                .font(.caption)
        }
        .containerBackground(.inkuSurface, for: .widget)
    }
}
```

## Localization

All platforms use the same String Catalog files:
- `Localizable.xcstrings` - Common strings
- `MangaListLocalizable.xcstrings` - Feature-specific
- Platform-specific strings added as needed

### Platform-Specific Keys
```json
{
  "mac.menu.file.new": {
    "localizations": {
      "en": { "stringUnit": { "value": "New Window" } },
      "es": { "stringUnit": { "value": "Nueva Ventana" } }
    }
  }
}
```

## Testing Strategy

### Shared Code Tests
- All existing tests in `InkuTests/` work for all platforms
- Unit tests for ViewModels, Interactors, and Services remain unchanged
- No platform-specific test changes needed for business logic

**Note**: UI tests are not included in this project. Focus is on comprehensive unit test coverage for shared business logic.

## Build Configuration

### Xcode Targets
1. **Inku (iOS)** - iPhone & iPad
2. **InkuMac** - macOS
3. **InkuTV** - tvOS (Apple TV)
4. **InkuWidget** - iOS Widget Extension

### Shared Framework (Alternative)
For better code organization, consider creating a shared framework:
- **InkuKit.framework** - Contains Core/ and Features/
- All targets link against InkuKit
- Easier dependency management

## Key Design Decisions

### Why NavigationSplitView for macOS?
- Native macOS sidebar experience
- Multi-column layout automatically
- Keyboard navigation built-in
- Resizable sidebars

### Why Simplified UI for tvOS?
- Viewing distance (10ft rule)
- Limited input (remote control)
- Focus-based navigation only
- No text input (search via voice/keyboard)

### Why Separate App Targets?
- Clear separation of concerns
- Platform-specific optimizations
- Independent versioning possible
- Cleaner build process

## Migration Path

### Phase 1: Restructure (Current)
1. Move Core/ and Features/ to Shared/
2. Update all import paths
3. Verify iOS app still works

### Phase 2: macOS Target
1. Create macOS target
2. Create InkuMacApp.swift
3. Implement sidebar navigation
4. Add keyboard shortcuts

### Phase 3: tvOS Target
1. Create tvOS target
2. Create InkuTVApp.swift
3. Implement focus navigation
4. Simplify UI for TV

### Phase 4: Widget Extension
1. Create Widget Extension target
2. Setup App Group
3. Implement Timeline Provider
4. Create widget views

## Performance Considerations

### macOS
- Support multiple windows efficiently
- Optimize image caching for larger screens
- Keyboard shortcuts should be instant

### tvOS
- Lazy loading for large grids
- Focus engine optimization
- Preload adjacent content

### Widgets
- Minimize timeline updates (battery)
- Cache images in shared container
- Keep widget views lightweight

## Accessibility

All platforms must maintain accessibility:
- **VoiceOver**: iOS, macOS, tvOS
- **Dynamic Type**: All platforms
- **Keyboard Navigation**: macOS, tvOS
- **Focus Indicators**: tvOS critical

## Next Steps

1. ✅ Create this architecture document
2. ⏳ Add macOS target to Xcode
3. ⏳ Add tvOS target to Xcode
4. ⏳ Create Widget Extension
5. ⏳ Implement platform-specific entry points
6. ⏳ Test on all platforms

---

**Version**: 1.0.0
**Last Updated**: 2026-02-06
**Status**: Planning Phase
