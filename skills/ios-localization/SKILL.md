# iOS Localization with String Catalog

## Description

Modern iOS localization using String Catalog (`.xcstrings`) with type-safe access patterns, pluralization support, and Swift Package support. This pattern uses the `String(localized:)` API (iOS 16+) and supports both app and package localization.

## When to Use

- Creating multilingual iOS/iPadOS/macOS apps
- Building localized Swift Packages
- Implementing type-safe localization patterns
- Supporting pluralization and string interpolation
- Organizing feature-based localization
- Adding localization to design system packages

## Rule 1: String Catalog Architecture

**Use feature-based String Catalog organization.**

### App vs Package Localization

| Location | Bundle | Table | Example |
|----------|--------|-------|---------|
| Main App | Default | Feature-based | `MovieList.xcstrings` |
| Swift Package | `#bundle` or `.module` | Package name | `UIKit.xcstrings` |

### File Structure

```
MyApp/
├── Resources/
│   ├── Localizable.xcstrings      ← Common strings
│   ├── MovieList.xcstrings        ← Feature-specific
│   ├── MovieDetail.xcstrings
│   ├── Search.xcstrings
│   └── Favorites.xcstrings

MyUIPackage/
└── Sources/MyUIPackage/
    └── Resources/
        └── MyUI.xcstrings         ← Package strings
```

### Creating String Catalog in Xcode

1. File → New → File → String Catalog
2. Name it `{FeatureName}.xcstrings`
3. Place in `Resources/` folder
4. Reference with `table: "FeatureName"` in code

### Adding Languages

1. Select String Catalog file
2. Inspector → Localizations → Click "+"
3. Select language (e.g., "Spanish")

---

## Rule 2: Key Naming Convention

**Use SCREAMING_SNAKE_CASE for all localization keys.**

### Format Structure

| Part | Description | Example |
|------|-------------|---------|
| FEATURE | Feature name | `MOVIE_LIST`, `MOVIE_DETAIL` |
| CONTEXT | UI context | `SCREEN`, `SECTION`, `BUTTON`, `LABEL`, `PLACEHOLDER`, `EMPTY`, `ERROR`, `ALERT` |
| IDENTIFIER | Specific element | `TITLE`, `SUBTITLE`, `SEARCH`, `ADD_FAVORITE` |

### Examples

```
MOVIE_LIST_SCREEN_TITLE
MOVIE_DETAIL_BUTTON_ADD_FAVORITE
SEARCH_PLACEHOLDER_SEARCH
FAVORITES_EMPTY_TITLE
COMMON_CANCEL
ERROR_NETWORK
```

### Common Contexts

- `SCREEN_` - Screen titles
- `SECTION_` - Section headers
- `BUTTON_` - Button labels
- `LABEL_` - Form labels
- `PLACEHOLDER_` - Text field placeholders
- `EMPTY_` - Empty state messages
- `ERROR_` - Error messages
- `ALERT_` - Alert titles/messages
- `A11Y_` - Accessibility labels
- `COMMON_` - Shared strings

---

## Rule 3: Type-Safe Localization Pattern

**Create an L10n enum with nested enums for features.**

### Main App Pattern

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

    // MARK: - Movie List (MovieList.xcstrings)

    enum MovieList {
        private static let table = "MovieList"

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

        // Pluralization function
        static func movieCount(_ count: Int) -> String {
            String(localized: "MOVIE_COUNT \(count)", table: table)
        }
    }

    // MARK: - Movie Detail (MovieDetail.xcstrings)

    enum MovieDetail {
        private static let table = "MovieDetail"

        enum Screen {
            static let title = String(localized: "SCREEN_TITLE", table: table)
        }

        enum Section {
            static let synopsis = String(localized: "SECTION_SYNOPSIS", table: table)
            static let cast = String(localized: "SECTION_CAST", table: table)
            static let reviews = String(localized: "SECTION_REVIEWS", table: table)
        }

        enum Label {
            static let director = String(localized: "LABEL_DIRECTOR", table: table)
            static let releaseDate = String(localized: "LABEL_RELEASE_DATE", table: table)
            static let rating = String(localized: "LABEL_RATING", table: table)
        }

        enum Button {
            static let addFavorite = String(localized: "BUTTON_ADD_FAVORITE", table: table)
            static let removeFavorite = String(localized: "BUTTON_REMOVE_FAVORITE", table: table)
            static let watchTrailer = String(localized: "BUTTON_WATCH_TRAILER", table: table)
        }

        enum Alert {
            static let deleteTitle = String(localized: "ALERT_DELETE_TITLE", table: table)
            static let deleteMessage = String(localized: "ALERT_DELETE_MESSAGE", table: table)
        }

        // String interpolation
        static func ratingValue(_ rating: Double) -> String {
            String(localized: "RATING_VALUE \(rating)", table: table)
        }
    }
}
```

### Usage in Views

```swift
struct MovieListView: View {

    @State private var viewModel: MovieListViewModel

    var body: some View {
        NavigationStack {
            content
                .navigationTitle(L10n.MovieList.Screen.title)
                .searchable(
                    text: $viewModel.searchText,
                    prompt: L10n.MovieList.Placeholder.search
                )
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            LoadingView()

        case .empty:
            EmptyView(
                title: L10n.MovieList.Empty.title,
                subtitle: L10n.MovieList.Empty.subtitle
            )

        case .loaded:
            movieList
        }
    }

    private var countLabel: some View {
        Text(L10n.MovieList.movieCount(viewModel.movies.count))
            .font(.caption)
            .foregroundStyle(.secondary)
    }
}
```

### Alert Usage

```swift
struct MovieDetailView: View {

    @State private var showingDeleteAlert = false

    var body: some View {
        ScrollView {
            // Content...
        }
        .alert(
            L10n.MovieDetail.Alert.deleteTitle,
            isPresented: $showingDeleteAlert
        ) {
            Button(L10n.Common.cancel, role: .cancel) { }
            Button(L10n.Common.delete, role: .destructive) {
                viewModel.delete()
            }
        } message: {
            Text(L10n.MovieDetail.Alert.deleteMessage)
        }
    }
}
```

---

## Rule 4: Swift Package Localization

**Use `#bundle` macro (iOS 26+) or `.module` (iOS 18) for packages.**

### Package Localization Pattern (iOS 18 Compatibility)

```swift
// In MyUIPackage/Sources/MyUIPackage/L10n/MyUIL10n.swift

public enum MyUIL10n {
    private static let table = "MyUI"

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

        public static var error: String {
            if #available(iOS 26, *) {
                String(localized: "A11Y_ERROR", table: table, bundle: #bundle)
            } else {
                String(localized: "A11Y_ERROR", table: table, bundle: .module)
            }
        }
    }
}
```

### iOS 26+ Only Pattern (Simplified)

If targeting iOS 26+ exclusively:

```swift
public enum MyUIL10n {
    private static let table = "MyUI"

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

### Using Package Localization in Components

```swift
// LoadingView with localized default message
public struct LoadingView: View {

    var message: String?

    public init(message: String? = nil) {
        self.message = message
    }

    public var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .controlSize(.large)

            Text(message ?? MyUIL10n.Loading.message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .accessibilityLabel(MyUIL10n.Accessibility.loading)
    }
}

// EmptyView with localized defaults
public struct EmptyView: View {

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
        self.title = title ?? MyUIL10n.Empty.defaultTitle
        self.subtitle = subtitle
        self.actionTitle = actionTitle
        self.action = action
    }

    public var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundStyle(.tertiary)

            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)

                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            if let action, let actionTitle {
                Button(actionTitle, action: action)
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding(24)
    }
}

// ErrorView with localized retry button
public struct ErrorView: View {

    let message: String
    var retryAction: (() -> Void)?

    public init(
        message: String? = nil,
        retryAction: (() -> Void)? = nil
    ) {
        self.message = message ?? MyUIL10n.Error.defaultTitle
        self.retryAction = retryAction
    }

    public var body: some View {
        EmptyView(
            icon: "exclamationmark.triangle",
            title: message,
            actionTitle: retryAction != nil ? MyUIL10n.Error.retry : nil,
            action: retryAction
        )
    }
}
```

---

## Rule 5: Pluralization

**Use string interpolation for plural-aware strings.**

### In Code

```swift
enum MovieList {
    private static let table = "MovieList"

    // Pluralization function
    static func movieCount(_ count: Int) -> String {
        String(localized: "MOVIE_COUNT \(count)", table: table)
    }
}

// Usage
Text(L10n.MovieList.movieCount(movies.count))
```

### In String Catalog (Visual Editor)

For key `MOVIE_COUNT %lld` in `MovieList.xcstrings`:

| Variation | English | Spanish | Japanese |
|-----------|---------|---------|----------|
| zero | No movies | Sin películas | 映画なし |
| one | 1 movie | 1 película | 1つの映画 |
| other | %lld movies | %lld películas | %lld本の映画 |

### Complex Plurals

Key: `EPISODES_COUNT %lld` in `ShowDetail.xcstrings`:

**English:**
- zero: "No episodes"
- one: "1 episode"
- other: "%lld episodes"

**Spanish:**
- zero: "Sin episodios"
- one: "1 episodio"
- other: "%lld episodios"

**German:**
- zero: "Keine Episoden"
- one: "1 Episode"
- other: "%lld Episoden"

---

## Rule 6: String Interpolation

**Use Swift string interpolation for dynamic content.**

### Single Variable

```swift
// Code
enum Welcome {
    static func message(_ userName: String) -> String {
        String(localized: "WELCOME_MESSAGE \(userName)")
    }
}

// Usage
Text(L10n.Welcome.message("Alice"))
```

**String Catalog - Key: `WELCOME_MESSAGE %@`**
- English: "Welcome, %@!"
- Spanish: "¡Bienvenido, %@!"
- French: "Bienvenue, %@ !"

### Multiple Variables

```swift
// Code
enum MovieDetail {
    private static let table = "MovieDetail"

    static func info(title: String, director: String) -> String {
        String(localized: "MOVIE_INFO \(title) \(director)", table: table)
    }
}

// Usage
Text(L10n.MovieDetail.info(title: movie.title, director: movie.director))
```

**String Catalog - Key: `MOVIE_INFO %@ %@`**
- English: "%1$@ directed by %2$@"
- Spanish: "%1$@ dirigida por %2$@"
- Japanese: "%2$@監督の%1$@"

### Format Specifiers

| Specifier | Type | Example |
|-----------|------|---------|
| `%@` | String | "Hello %@" |
| `%lld` | Int | "Count: %lld" |
| `%lf` | Double | "Score: %.1f" |
| `%1$@` | Positional string | "%1$@ and %2$@" |

---

## Rule 7: Common String Catalog Keys

**Organize keys by feature with consistent contexts.**

### Localizable.xcstrings (Common)

```
// Common Actions
COMMON_OK = "OK" / "Aceptar" / "OK"
COMMON_CANCEL = "Cancel" / "Cancelar" / "キャンセル"
COMMON_SAVE = "Save" / "Guardar" / "保存"
COMMON_DELETE = "Delete" / "Eliminar" / "削除"
COMMON_EDIT = "Edit" / "Editar" / "編集"
COMMON_DONE = "Done" / "Listo" / "完了"
COMMON_RETRY = "Retry" / "Reintentar" / "再試行"
COMMON_LOADING = "Loading..." / "Cargando..." / "読み込み中..."

// Errors
ERROR_TITLE = "Error" / "Error" / "エラー"
ERROR_GENERIC = "Something went wrong" / "Algo salió mal" / "問題が発生しました"
ERROR_NETWORK = "No internet connection" / "Sin conexión a internet" / "インターネット接続なし"
ERROR_NOT_FOUND = "Not found" / "No encontrado" / "見つかりません"
```

### Feature-Specific String Catalog Example

**MovieList.xcstrings:**
```
SCREEN_TITLE = "Movies" / "Películas" / "映画"
SECTION_FEATURED = "Featured" / "Destacadas" / "注目"
SECTION_RECENT = "Recently Added" / "Añadidas recientemente" / "最近追加"
SECTION_POPULAR = "Popular" / "Populares" / "人気"
PLACEHOLDER_SEARCH = "Search movies..." / "Buscar películas..." / "映画を検索..."
EMPTY_TITLE = "No movies found" / "No se encontraron películas" / "映画が見つかりません"
EMPTY_SUBTITLE = "Try adjusting your filters" / "Intenta ajustar los filtros" / "フィルターを調整してください"
MOVIE_COUNT %lld = (plural variations)
```

### Package String Catalog Example

**MyUI.xcstrings:**
```
LOADING_MESSAGE = "Loading..." / "Cargando..." / "読み込み中..."
EMPTY_DEFAULT_TITLE = "Nothing here" / "Nada aquí" / "何もありません"
EMPTY_DEFAULT_SUBTITLE = "Check back later" / "Vuelve más tarde" / "後で確認してください"
ERROR_DEFAULT_TITLE = "Something went wrong" / "Algo salió mal" / "問題が発生しました"
ERROR_RETRY = "Try Again" / "Reintentar" / "再試行"
A11Y_LOADING = "Loading content" / "Cargando contenido" / "コンテンツを読み込み中"
A11Y_ERROR = "Error occurred" / "Ocurrió un error" / "エラーが発生しました"
A11Y_CLOSE = "Close" / "Cerrar" / "閉じる"
```

---

## Rule 8: Testing Localization

**Test all supported languages using previews and simulators.**

### Preview Different Languages

```swift
#Preview("English") {
    MovieListView()
        .environment(\.locale, Locale(identifier: "en"))
}

#Preview("Spanish") {
    MovieListView()
        .environment(\.locale, Locale(identifier: "es"))
}

#Preview("Japanese") {
    MovieListView()
        .environment(\.locale, Locale(identifier: "ja"))
}
```

### In Simulator

1. Settings → General → Language & Region
2. Change preferred language
3. Relaunch app

### Pseudo-localization

Test for layout issues with elongated text:

1. Edit Scheme → Options
2. Application Language → "Double-Length Pseudolanguage"
3. Run app to see UI with doubled text length

### Accessibility Testing

```swift
#Preview("Loading - VoiceOver") {
    LoadingView()
        .accessibilityShowsLargeContentViewer()
}
```

---

## Checklist

When implementing localization:

- [ ] Use SCREAMING_SNAKE_CASE for all keys
- [ ] Organize by feature with separate `.xcstrings` files
- [ ] Create type-safe `L10n` enum structure
- [ ] Use `table:` parameter for feature-specific catalogs
- [ ] Use `bundle: #bundle` (iOS 26) or `.module` (iOS 18) for packages
- [ ] Implement pluralization with string interpolation
- [ ] Use positional format specifiers for multiple variables
- [ ] Provide default values in package components
- [ ] Test all supported languages in previews
- [ ] Test pseudo-localization for layout issues
- [ ] Add accessibility labels for all interactive elements
- [ ] Organize keys by context (SCREEN, BUTTON, LABEL, etc.)

---

## Common Mistakes

### ❌ Mistake 1: Hardcoded Strings

```swift
// ❌ BAD: Hardcoded text
struct MovieListView: View {
    var body: some View {
        NavigationStack {
            List(movies) { movie in
                Text(movie.title)
            }
            .navigationTitle("Movies")  // ❌ Hardcoded
        }
    }
}
```

**Fix**: Use localized strings

```swift
// ✅ GOOD: Localized text
.navigationTitle(L10n.MovieList.Screen.title)
```

### ❌ Mistake 2: Missing Table Parameter

```swift
// ❌ BAD: No table parameter for feature-specific key
enum MovieList {
    static let title = String(localized: "SCREEN_TITLE")  // ❌ Uses Localizable.xcstrings
}
```

**Fix**: Specify table

```swift
// ✅ GOOD: Explicit table parameter
enum MovieList {
    private static let table = "MovieList"

    enum Screen {
        static let title = String(localized: "SCREEN_TITLE", table: table)
    }
}
```

### ❌ Mistake 3: Incorrect Bundle for Package

```swift
// ❌ BAD: Missing bundle parameter in package
public enum MyUIL10n {
    public static let loading = String(localized: "LOADING_MESSAGE", table: "MyUI")
    // ❌ Will look in main app bundle, not package
}
```

**Fix**: Use #bundle or .module

```swift
// ✅ GOOD: Explicit bundle
public enum MyUIL10n {
    private static let table = "MyUI"

    public static var loading: String {
        if #available(iOS 26, *) {
            String(localized: "LOADING_MESSAGE", table: table, bundle: #bundle)
        } else {
            String(localized: "LOADING_MESSAGE", table: table, bundle: .module)
        }
    }
}
```

### ❌ Mistake 4: Inconsistent Key Convention

```swift
// ❌ BAD: Mixed naming conventions
COMMON_OK = "OK"
common_cancel = "Cancel"  // ❌ lowercase
Common.Save = "Save"  // ❌ Pascal case
screen-title = "Title"  // ❌ kebab-case
```

**Fix**: Consistent SCREAMING_SNAKE_CASE

```swift
// ✅ GOOD: Consistent convention
COMMON_OK = "OK"
COMMON_CANCEL = "Cancel"
COMMON_SAVE = "Save"
SCREEN_TITLE = "Title"
```

### ❌ Mistake 5: Missing Pluralization

```swift
// ❌ BAD: Manual pluralization
let text = movies.count == 1 ? "1 movie" : "\(movies.count) movies"
```

**Fix**: Use String Catalog pluralization

```swift
// ✅ GOOD: String Catalog handles pluralization
static func movieCount(_ count: Int) -> String {
    String(localized: "MOVIE_COUNT \(count)", table: "MovieList")
}

// String Catalog key: MOVIE_COUNT %lld
// zero: "No movies"
// one: "1 movie"
// other: "%lld movies"
```

---

## Summary

| Concept | Implementation |
|---------|----------------|
| Key format | `SCREAMING_SNAKE_CASE` |
| App strings | `String(localized: "KEY", table: "Feature")` |
| Package strings (iOS 26+) | `String(localized: "KEY", table: "Package", bundle: #bundle)` |
| Package strings (iOS 18) | `String(localized: "KEY", table: "Package", bundle: .module)` |
| Type-safe access | `L10n.Feature.Context.key` |
| Pluralization | `String(localized: "KEY \(count)", table: "Feature")` |
| Interpolation | `String(localized: "KEY \(value)", table: "Feature")` |
| File per feature | `{Feature}.xcstrings` in Resources/ |
| Testing | Preview with `.environment(\.locale, Locale(identifier: "es"))` |

---

## Related Skills

- `skills/swiftui-observable/SKILL.md` - ViewModels using localized strings
- `skills/swiftui-components/SKILL.md` - Components with localized defaults
- `skills/clean-architecture-ios/SKILL.md` - L10n organization in architecture
