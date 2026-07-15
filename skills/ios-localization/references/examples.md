# iOS Localization — Full Code Examples

> **Note**: These examples use `L10n` as the localization enum name and `SCREAMING_SNAKE_CASE` as the key convention. Adapt the enum name, key format, and supported languages to your project (check `CLAUDE.md`).

## Localization Enum Structure

```swift
// Core/Extensions/L10n.swift
// Adapt enum name to your project: L10n, Strings, S, etc. (see CLAUDE.md)

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
        }

        enum Placeholder {
            static let search = String(localized: "PLACEHOLDER_SEARCH", table: table)
        }

        enum Empty {
            static let title = String(localized: "EMPTY_TITLE", table: table)
            static let subtitle = String(localized: "EMPTY_SUBTITLE", table: table)
        }

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

        enum Label {
            static let director = String(localized: "LABEL_DIRECTOR", table: table)
            static let releaseDate = String(localized: "LABEL_RELEASE_DATE", table: table)
            static let rating = String(localized: "LABEL_RATING", table: table)
        }

        enum Button {
            static let addFavorite = String(localized: "BUTTON_ADD_FAVORITE", table: table)
            static let removeFavorite = String(localized: "BUTTON_REMOVE_FAVORITE", table: table)
        }

        enum Alert {
            static let deleteTitle = String(localized: "ALERT_DELETE_TITLE", table: table)
            static let deleteMessage = String(localized: "ALERT_DELETE_MESSAGE", table: table)
        }

        static func ratingValue(_ rating: Double) -> String {
            String(localized: "RATING_VALUE \(rating)", table: table)
        }
    }
}
```

## Usage in Views

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
        case .loading: ProgressView()
        case .empty:
            EmptyStateView(
                title: L10n.MovieList.Empty.title,
                subtitle: L10n.MovieList.Empty.subtitle
            )
        case .loaded: movieList
        }
    }

    private var countLabel: some View {
        Text(L10n.MovieList.movieCount(viewModel.movies.count))
            .font(.caption)
            .foregroundStyle(.secondary)
    }
}
```

## Alert Usage

```swift
.alert(
    L10n.MovieDetail.Alert.deleteTitle,
    isPresented: $showingDeleteAlert
) {
    Button(L10n.Common.cancel, role: .cancel) { }
    Button(L10n.Common.delete, role: .destructive) { viewModel.delete() }
} message: {
    Text(L10n.MovieDetail.Alert.deleteMessage)
}
```

## String Catalog Examples

### Localizable.xcstrings (Common)

Add entries for each supported language (see CLAUDE.md for your language list):

```
COMMON_OK        → English: "OK"         | [Lang2]: "[translation]"
COMMON_CANCEL    → English: "Cancel"     | [Lang2]: "[translation]"
COMMON_SAVE      → English: "Save"       | [Lang2]: "[translation]"
COMMON_RETRY     → English: "Retry"      | [Lang2]: "[translation]"
ERROR_TITLE      → English: "Error"      | [Lang2]: "[translation]"
ERROR_GENERIC    → English: "Something went wrong"  | [Lang2]: "[translation]"
ERROR_NETWORK    → English: "No internet connection" | [Lang2]: "[translation]"
```

### Feature Catalog (MovieList.xcstrings)

```
SCREEN_TITLE         → English: "Movies"     | [Lang2]: "[translation]"
SECTION_FEATURED     → English: "Featured"   | [Lang2]: "[translation]"
PLACEHOLDER_SEARCH   → English: "Search..."  | [Lang2]: "[translation]"
EMPTY_TITLE          → English: "No movies"  | [Lang2]: "[translation]"

MOVIE_COUNT %lld     → one: "1 movie" | other: "%lld movies"
                       [Lang2] one: "[translation]" | other: "[translation]"
```

## SPM Package Localization

```swift
// Inside an SPM package — adapt enum name to your package
public enum MyUIL10n {
    private static let table = "MyUI"

    public enum Loading {
        public static let message = String(
            localized: "LOADING_MESSAGE",
            table: table,
            bundle: #bundle
        )
    }
}
```

## Localized Previews

```swift
// Replace locale identifiers with your supported languages
#Preview("English") {
    MovieListView()
        .environment(\.locale, Locale(identifier: "en"))
}

#Preview("Spanish") {
    MovieListView()
        .environment(\.locale, Locale(identifier: "es"))
}
```
