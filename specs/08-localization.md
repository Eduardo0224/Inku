# Localization Specification

## Overview

**Format**: String Catalog (`.xcstrings`) - Xcode 15+
**Languages**: English (en) - Development, Spanish (es) - Secondary
**Key Convention**: SCREAMING_SNAKE_CASE (uppercase)

## String Catalog Architecture

### App vs Package Localization

| Location | Bundle | Table | Example |
|----------|--------|-------|---------|
| Main App | Default | Feature-based | `MangaList.xcstrings` |
| InkuUI Package | `#bundle` | `InkuUI` | `InkuUI.xcstrings` |

### File Structure

```
Mangaka/
├── Resources/
│   ├── Localizable.xcstrings      ← Common strings
│   ├── MangaList.xcstrings        ← Feature-specific
│   ├── MangaDetail.xcstrings
│   ├── Search.xcstrings
│   └── Favorites.xcstrings

InkuUI/
└── Sources/InkuUI/
    └── Resources/
        └── InkuUI.xcstrings       ← Package strings
```

## Key Naming Convention

**Format**: `SCREAMING_SNAKE_CASE`

| Part | Description | Example |
|------|-------------|---------|
| FEATURE | Feature name | `MANGA_LIST`, `MANGA_DETAIL` |
| CONTEXT | UI context | `SCREEN`, `SECTION`, `BUTTON`, `LABEL`, `PLACEHOLDER`, `EMPTY`, `ERROR`, `ALERT` |
| IDENTIFIER | Specific element | `TITLE`, `SUBTITLE`, `SEARCH`, `ADD_FAVORITE` |

**Examples:**
- `MANGA_LIST_SCREEN_TITLE`
- `MANGA_DETAIL_BUTTON_ADD_FAVORITE`
- `COMMON_CANCEL`
- `ERROR_NETWORK`

## Modern Localization API (iOS 16+)

### Basic Usage with Table

```swift
// Using table parameter for feature-specific String Catalog
String(localized: "SCREEN_TITLE", table: "MangaList")
```

### Bundle Parameter for Packages

```swift
// In InkuUI package - use #bundle macro (iOS 26+)
String(localized: "LOADING", table: "InkuUI", bundle: #bundle)

// For iOS 18 compatibility, use Bundle.module
String(localized: "LOADING", table: "InkuUI", bundle: .module)
```

## Type-Safe Localization Pattern

### Main App - Feature Tables

```swift
// MARK: - Localization

enum L10n {
    
    // MARK: - Common (Localizable.xcstrings)
    
    enum Common {
        static let ok = String(localized: "COMMON_OK")
        static let cancel = String(localized: "COMMON_CANCEL")
        static let save = String(localized: "COMMON_SAVE")
        static let delete = String(localized: "COMMON_DELETE")
        static let edit = String(localized: "COMMON_EDIT")
        static let done = String(localized: "COMMON_DONE")
        static let retry = String(localized: "COMMON_RETRY")
        static let loading = String(localized: "COMMON_LOADING")
    }
    
    // MARK: - Errors (Localizable.xcstrings)
    
    enum Error {
        static let title = String(localized: "ERROR_TITLE")
        static let generic = String(localized: "ERROR_GENERIC")
        static let network = String(localized: "ERROR_NETWORK")
        static let notFound = String(localized: "ERROR_NOT_FOUND")
    }
    
    // MARK: - Manga List (MangaList.xcstrings)
    
    enum MangaList {
        private static let table = "MangaList"
        
        enum Screen {
            static let title = String(localized: "SCREEN_TITLE", table: table)
        }
        
        enum Section {
            static let featured = String(localized: "SECTION_FEATURED", table: table)
            static let recent = String(localized: "SECTION_RECENT", table: table)
            static let popular = String(localized: "SECTION_POPULAR", table: table)
        }
        
        enum Placeholder {
            static let search = String(localized: "PLACEHOLDER_SEARCH", table: table)
        }
        
        enum Empty {
            static let title = String(localized: "EMPTY_TITLE", table: table)
            static let subtitle = String(localized: "EMPTY_SUBTITLE", table: table)
        }
        
        // Pluralization
        static func mangaCount(_ count: Int) -> String {
            String(localized: "MANGA_COUNT \(count)", table: table)
        }
    }
    
    // MARK: - Manga Detail (MangaDetail.xcstrings)
    
    enum MangaDetail {
        private static let table = "MangaDetail"
        
        enum Screen {
            static let title = String(localized: "SCREEN_TITLE", table: table)
        }
        
        enum Section {
            static let synopsis = String(localized: "SECTION_SYNOPSIS", table: table)
            static let chapters = String(localized: "SECTION_CHAPTERS", table: table)
            static let characters = String(localized: "SECTION_CHARACTERS", table: table)
            static let related = String(localized: "SECTION_RELATED", table: table)
        }
        
        enum Label {
            static let author = String(localized: "LABEL_AUTHOR", table: table)
            static let status = String(localized: "LABEL_STATUS", table: table)
            static let genres = String(localized: "LABEL_GENRES", table: table)
            static let demographic = String(localized: "LABEL_DEMOGRAPHIC", table: table)
            static let score = String(localized: "LABEL_SCORE", table: table)
        }
        
        enum Button {
            static let addFavorite = String(localized: "BUTTON_ADD_FAVORITE", table: table)
            static let removeFavorite = String(localized: "BUTTON_REMOVE_FAVORITE", table: table)
            static let startReading = String(localized: "BUTTON_START_READING", table: table)
            static let share = String(localized: "BUTTON_SHARE", table: table)
        }
        
        enum Alert {
            static let deleteTitle = String(localized: "ALERT_DELETE_TITLE", table: table)
            static let deleteMessage = String(localized: "ALERT_DELETE_MESSAGE", table: table)
        }
        
        // Interpolation
        static func scoreValue(_ score: Double) -> String {
            String(localized: "SCORE_VALUE \(score)", table: table)
        }
        
        static func chaptersCount(_ count: Int) -> String {
            String(localized: "CHAPTERS_COUNT \(count)", table: table)
        }
    }
    
    // MARK: - Search (Search.xcstrings)
    
    enum Search {
        private static let table = "Search"
        
        enum Screen {
            static let title = String(localized: "SCREEN_TITLE", table: table)
        }
        
        enum Placeholder {
            static let search = String(localized: "PLACEHOLDER_SEARCH", table: table)
        }
        
        enum Filter {
            static let genre = String(localized: "FILTER_GENRE", table: table)
            static let status = String(localized: "FILTER_STATUS", table: table)
            static let demographic = String(localized: "FILTER_DEMOGRAPHIC", table: table)
        }
        
        enum Empty {
            static let noResults = String(localized: "EMPTY_NO_RESULTS", table: table)
            static let tryDifferent = String(localized: "EMPTY_TRY_DIFFERENT", table: table)
        }
        
        static func resultsCount(_ count: Int) -> String {
            String(localized: "RESULTS_COUNT \(count)", table: table)
        }
    }
    
    // MARK: - Favorites (Favorites.xcstrings)
    
    enum Favorites {
        private static let table = "Favorites"
        
        enum Screen {
            static let title = String(localized: "SCREEN_TITLE", table: table)
        }
        
        enum Empty {
            static let title = String(localized: "EMPTY_TITLE", table: table)
            static let subtitle = String(localized: "EMPTY_SUBTITLE", table: table)
            static let action = String(localized: "EMPTY_ACTION", table: table)
        }
    }
}
```

### InkuUI Package Localization

```swift
// In InkuUI/Sources/InkuUI/L10n/InkuL10n.swift

public enum InkuL10n {
    private static let table = "InkuUI"
    
    // MARK: - Loading States
    
    public enum Loading {
        public static var message: String {
            if #available(iOS 26, *) {
                String(localized: "LOADING_MESSAGE", table: table, bundle: #bundle)
            } else {
                String(localized: "LOADING_MESSAGE", table: table, bundle: .module)
            }
        }
    }
    
    // MARK: - Empty States
    
    public enum Empty {
        public static var defaultTitle: String {
            if #available(iOS 26, *) {
                String(localized: "EMPTY_DEFAULT_TITLE", table: table, bundle: #bundle)
            } else {
                String(localized: "EMPTY_DEFAULT_TITLE", table: table, bundle: .module)
            }
        }
        
        public static var defaultSubtitle: String {
            if #available(iOS 26, *) {
                String(localized: "EMPTY_DEFAULT_SUBTITLE", table: table, bundle: #bundle)
            } else {
                String(localized: "EMPTY_DEFAULT_SUBTITLE", table: table, bundle: .module)
            }
        }
    }
    
    // MARK: - Error States
    
    public enum Error {
        public static var defaultTitle: String {
            if #available(iOS 26, *) {
                String(localized: "ERROR_DEFAULT_TITLE", table: table, bundle: #bundle)
            } else {
                String(localized: "ERROR_DEFAULT_TITLE", table: table, bundle: .module)
            }
        }
        
        public static var retry: String {
            if #available(iOS 26, *) {
                String(localized: "ERROR_RETRY", table: table, bundle: #bundle)
            } else {
                String(localized: "ERROR_RETRY", table: table, bundle: .module)
            }
        }
    }
    
    // MARK: - Accessibility
    
    public enum Accessibility {
        public static var loading: String {
            if #available(iOS 26, *) {
                String(localized: "A11Y_LOADING", table: table, bundle: #bundle)
            } else {
                String(localized: "A11Y_LOADING", table: table, bundle: .module)
            }
        }
    }
}
```

### Simplified Package Localization (iOS 26+ only)

If targeting iOS 26+ exclusively, use the simpler pattern:

```swift
public enum InkuL10n {
    private static let table = "InkuUI"
    
    public enum Loading {
        public static let message = String(localized: "LOADING_MESSAGE", table: table, bundle: #bundle)
    }
    
    public enum Empty {
        public static let defaultTitle = String(localized: "EMPTY_DEFAULT_TITLE", table: table, bundle: #bundle)
        public static let defaultSubtitle = String(localized: "EMPTY_DEFAULT_SUBTITLE", table: table, bundle: #bundle)
    }
    
    public enum Error {
        public static let defaultTitle = String(localized: "ERROR_DEFAULT_TITLE", table: table, bundle: #bundle)
        public static let retry = String(localized: "ERROR_RETRY", table: table, bundle: #bundle)
    }
}
```

### InkuUI Components Using Localization

```swift
// InkuLoadingView with localized default message
public struct InkuLoadingView: View {
    
    var message: String?
    
    public init(message: String? = nil) {
        self.message = message
    }
    
    public var body: some View {
        VStack(spacing: InkuSpacing.spacing16) {
            ProgressView()
                .controlSize(.large)
            
            Text(message ?? InkuL10n.Loading.message)
                .font(.inkuBodySmall)
                .foregroundStyle(.inkuTextSecondary)
        }
        .accessibilityLabel(InkuL10n.Accessibility.loading)
    }
}

// InkuEmptyView with localized defaults
public struct InkuEmptyView: View {
    
    let icon: String
    let title: String
    var subtitle: String?
    var actionTitle: String?
    var action: (() -> Void)?
    
    public init(
        icon: String = "tray",
        title: String? = nil,
        subtitle: String? = nil,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title ?? InkuL10n.Empty.defaultTitle
        self.subtitle = subtitle
        self.actionTitle = actionTitle
        self.action = action
    }
    
    // body implementation...
}

// InkuErrorView with localized retry button
public struct InkuErrorView: View {
    
    let message: String
    var retryAction: (() -> Void)?
    
    public init(
        message: String? = nil,
        retryAction: (() -> Void)? = nil
    ) {
        self.message = message ?? InkuL10n.Error.defaultTitle
        self.retryAction = retryAction
    }
    
    public var body: some View {
        InkuEmptyView(
            icon: "exclamationmark.triangle",
            title: message,
            actionTitle: retryAction != nil ? InkuL10n.Error.retry : nil,
            action: retryAction
        )
    }
}
```

## Usage in Views

```swift
import SwiftUI
import InkuUI

struct MangaListView: View {
    
    @State private var viewModel: MangaListViewModel
    
    var body: some View {
        NavigationStack {
            content
                .navigationTitle(L10n.MangaList.Screen.title)
                .searchable(
                    text: $viewModel.searchText,
                    prompt: L10n.MangaList.Placeholder.search
                )
        }
    }
    
    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            InkuLoadingView()  // Uses InkuL10n internally
            
        case .empty:
            InkuEmptyView(
                icon: "books.vertical",
                title: L10n.MangaList.Empty.title,
                subtitle: L10n.MangaList.Empty.subtitle
            )
            
        case .error(let message):
            InkuErrorView(message: message) {
                Task { await viewModel.loadMangas() }
            }
            
        case .loaded:
            mangaGrid
        }
    }
    
    private var countLabel: some View {
        Text(L10n.MangaList.mangaCount(viewModel.mangas.count))
            .font(.inkuCaption)
            .foregroundStyle(.inkuTextTertiary)
    }
}

struct MangaDetailView: View {
    
    @State private var viewModel: MangaDetailViewModel
    @State private var showingDeleteAlert = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: InkuSpacing.spacing24) {
                // Synopsis section
                SectionView(title: L10n.MangaDetail.Section.synopsis) {
                    Text(viewModel.manga.synopsis)
                }
                
                // Info labels
                InfoRow(label: L10n.MangaDetail.Label.author, value: viewModel.manga.author)
                InfoRow(label: L10n.MangaDetail.Label.status, value: viewModel.manga.status)
                
                // Actions
                InkuButton(L10n.MangaDetail.Button.addFavorite, icon: "heart") {
                    viewModel.addToFavorites()
                }
            }
        }
        .alert(
            L10n.MangaDetail.Alert.deleteTitle,
            isPresented: $showingDeleteAlert
        ) {
            Button(L10n.Common.cancel, role: .cancel) { }
            Button(L10n.Common.delete, role: .destructive) {
                viewModel.delete()
            }
        } message: {
            Text(L10n.MangaDetail.Alert.deleteMessage)
        }
    }
}
```

## Pluralization

### In Code

```swift
// Function that handles pluralization
static func mangaCount(_ count: Int) -> String {
    String(localized: "MANGA_COUNT \(count)", table: "MangaList")
}
```

### In String Catalog (Visual Editor)

For key `MANGA_COUNT %lld` in `MangaList.xcstrings`:

| Variation | English | Spanish |
|-----------|---------|---------|
| zero | No manga | Sin manga |
| one | 1 manga | 1 manga |
| other | %lld manga | %lld manga |

### Complex Plurals

Key: `CHAPTERS_COUNT %lld` in `MangaDetail.xcstrings`:

**English:**
- zero: "No chapters"
- one: "1 chapter"
- other: "%lld chapters"

**Spanish:**
- zero: "Sin capítulos"
- one: "1 capítulo"
- other: "%lld capítulos"

## String Interpolation

### Single Variable

```swift
// Code
static func welcomeMessage(_ userName: String) -> String {
    String(localized: "WELCOME_MESSAGE \(userName)")
}

// String Catalog - Key: "WELCOME_MESSAGE %@"
// English: "Welcome, %@!"
// Spanish: "¡Bienvenido, %@!"
```

### Multiple Variables

```swift
// Code
static func mangaInfo(title: String, author: String) -> String {
    String(localized: "MANGA_INFO \(title) \(author)", table: "MangaDetail")
}

// String Catalog - Key: "MANGA_INFO %@ %@"
// English: "%1$@ by %2$@"
// Spanish: "%1$@ de %2$@"
```

## String Catalog Keys Reference

### Localizable.xcstrings (Common)

```
// Common Actions
COMMON_OK = "OK" / "Aceptar"
COMMON_CANCEL = "Cancel" / "Cancelar"
COMMON_SAVE = "Save" / "Guardar"
COMMON_DELETE = "Delete" / "Eliminar"
COMMON_EDIT = "Edit" / "Editar"
COMMON_DONE = "Done" / "Listo"
COMMON_RETRY = "Retry" / "Reintentar"
COMMON_LOADING = "Loading..." / "Cargando..."

// Errors
ERROR_TITLE = "Error" / "Error"
ERROR_GENERIC = "Something went wrong" / "Algo salió mal"
ERROR_NETWORK = "No internet connection" / "Sin conexión a internet"
ERROR_NOT_FOUND = "Not found" / "No encontrado"
```

### MangaList.xcstrings

```
SCREEN_TITLE = "Manga" / "Manga"
SECTION_FEATURED = "Featured" / "Destacados"
SECTION_RECENT = "Recently Added" / "Añadidos recientemente"
SECTION_POPULAR = "Popular" / "Populares"
PLACEHOLDER_SEARCH = "Search manga..." / "Buscar manga..."
EMPTY_TITLE = "No manga found" / "No se encontró manga"
EMPTY_SUBTITLE = "Try adjusting your filters" / "Intenta ajustar los filtros"
MANGA_COUNT %lld = (plural)
```

### MangaDetail.xcstrings

```
SCREEN_TITLE = "Details" / "Detalles"
SECTION_SYNOPSIS = "Synopsis" / "Sinopsis"
SECTION_CHAPTERS = "Chapters" / "Capítulos"
SECTION_CHARACTERS = "Characters" / "Personajes"
LABEL_AUTHOR = "Author" / "Autor"
LABEL_STATUS = "Status" / "Estado"
LABEL_GENRES = "Genres" / "Géneros"
LABEL_DEMOGRAPHIC = "Demographic" / "Demografía"
LABEL_SCORE = "Score" / "Puntuación"
BUTTON_ADD_FAVORITE = "Add to Favorites" / "Añadir a Favoritos"
BUTTON_REMOVE_FAVORITE = "Remove from Favorites" / "Quitar de Favoritos"
BUTTON_START_READING = "Start Reading" / "Comenzar a Leer"
ALERT_DELETE_TITLE = "Delete from Favorites?" / "¿Eliminar de Favoritos?"
ALERT_DELETE_MESSAGE = "This cannot be undone." / "Esta acción no se puede deshacer."
CHAPTERS_COUNT %lld = (plural)
SCORE_VALUE %lf = "%.1f/10" / "%.1f/10"
```

### InkuUI.xcstrings (Package)

```
LOADING_MESSAGE = "Loading..." / "Cargando..."
EMPTY_DEFAULT_TITLE = "Nothing here" / "Nada aquí"
EMPTY_DEFAULT_SUBTITLE = "Check back later" / "Vuelve más tarde"
ERROR_DEFAULT_TITLE = "Something went wrong" / "Algo salió mal"
ERROR_RETRY = "Try Again" / "Reintentar"
A11Y_LOADING = "Loading content" / "Cargando contenido"
A11Y_ERROR = "Error occurred" / "Ocurrió un error"
A11Y_CLOSE = "Close" / "Cerrar"
```

## Xcode Workflow

### Creating Feature-Specific String Catalog

1. File → New → File → String Catalog
2. Name it `{FeatureName}.xcstrings` (e.g., `MangaList.xcstrings`)
3. Place in `Resources/` folder
4. Reference with `table: "MangaList"` in code

### Adding Languages

1. Select String Catalog file
2. In Inspector → Localizations → Click "+"
3. Select "Spanish"

### Automatic Extraction

Xcode extracts strings when you:
1. Build the project (⌘B)
2. Use `String(localized:)` with consistent table parameter

## Testing Localization

### Preview Different Languages

```swift
#Preview("English") {
    MangaListView()
        .environment(\.locale, Locale(identifier: "en"))
}

#Preview("Spanish") {
    MangaListView()
        .environment(\.locale, Locale(identifier: "es"))
}
```

### In Simulator

1. Settings → General → Language & Region
2. Change preferred language

### Pseudo-localization

1. Edit Scheme → Options
2. Application Language → "Double-Length Pseudolanguage"

## Summary

| Concept | Implementation |
|---------|----------------|
| Key format | `SCREAMING_SNAKE_CASE` |
| App strings | `String(localized: "KEY", table: "Feature")` |
| Package strings | `String(localized: "KEY", table: "InkuUI", bundle: #bundle)` |
| iOS 18 fallback | `bundle: .module` |
| Type-safe access | `L10n.Feature.Context.key` |
| Pluralization | Function with interpolation |
| File per feature | `{Feature}.xcstrings` |
