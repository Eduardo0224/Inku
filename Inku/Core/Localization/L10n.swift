//
//  L10n.swift
//  Inku
//
//  Created by Eduardo Andrade on 23/12/25.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2025 Eduardo Andrade. All rights reserved.
//

import Foundation

enum L10n {

    // MARK: - Tabs (Localizable.xcstrings)

    enum Tabs {
        static let browse = String(localized: .tabBrowse)
    }

    // MARK: - Common (Localizable.xcstrings)

    enum Common {
        static let ok = String(localized: .commonOk)
        static let cancel = String(localized: .commonCancel)
        static let done = String(localized: .commonDone)
        static let retry = String(localized: .commonRetry)
        static let loading = String(localized: .commonLoading)
    }

    // MARK: - Errors (Localizable.xcstrings)

    enum Error {
        static let title = String(localized: .errorTitle)
        static let generic = String(localized: .errorGeneric)
        static let network = String(localized: .errorNetwork)
        static let timeout = String(localized: .errorTimeout)
    }

    // MARK: - Manga List (MangaListLocalizable.xcstrings)

    enum MangaList {

        enum Screen {
            static let title = String(localized: .MangaListLocalizable.screenTitle)
        }

        enum Section {
            static let featured = String(localized: .MangaListLocalizable.sectionFeatured)
            static let recent = String(localized: .MangaListLocalizable.sectionRecent)
            static let popular = String(localized: .MangaListLocalizable.sectionPopular)
        }

        enum Placeholder {
            static let search = String(localized: .MangaListLocalizable.placeholderSearch)
        }

        enum Empty {
            static let title = String(localized: .MangaListLocalizable.emptyTitle)
            static let subtitle = String(localized: .MangaListLocalizable.emptySubtitle)
        }

        enum Filter {
            static let clear = String(localized: .MangaListLocalizable.filterClear)
            static let genre = String(localized: .MangaListLocalizable.filterGenre)
            static let demographic = String(localized: .MangaListLocalizable.filterDemographic)
            static let theme = String(localized: .MangaListLocalizable.filterTheme)
        }
    }

    // MARK: - Manga Detail (MangaDetailLocalizable.xcstrings)

    enum MangaDetail {

        enum Screen {
            static let title = String(localized: .MangaDetailLocalizable.screenTitle)
        }

        enum Stats {
            static let score = String(localized: .MangaDetailLocalizable.statsScore)
            static let volumes = String(localized: .MangaDetailLocalizable.statsVolumes)
            static let chapters = String(localized: .MangaDetailLocalizable.statsChapters)
            static let status = String(localized: .MangaDetailLocalizable.statsStatus)
        }

        enum Synopsis {
            static let title = String(localized: .MangaDetailLocalizable.synopsisTitle)
            static let readMore = String(localized: .MangaDetailLocalizable.synopsisReadMore)
            static let readLess = String(localized: .MangaDetailLocalizable.synopsisReadLess)
            static let empty = String(localized: .MangaDetailLocalizable.synopsisEmpty)
        }

        enum Authors {
            static let title = String(localized: .MangaDetailLocalizable.authorsTitle)
            static let empty = String(localized: .MangaDetailLocalizable.authorsEmpty)
        }

        enum Tags {
            static let title = String(localized: .MangaDetailLocalizable.tagsTitle)
            static let empty = String(localized: .MangaDetailLocalizable.tagsEmpty)
        }

        enum Publication {
            static let title = String(localized: .MangaDetailLocalizable.publicationTitle)
            static let unknown = String(localized: .MangaDetailLocalizable.publicationUnknown)
            static let present = String(localized: .MangaDetailLocalizable.publicationPresent)
            static let since = String(localized: .MangaDetailLocalizable.publicationSince)
        }

        enum Background {
            static let title = String(localized: .MangaDetailLocalizable.backgroundTitle)
            static let button = String(localized: .MangaDetailLocalizable.backgroundButton)
        }
    }

    // MARK: - Search (SearchLocalizable.xcstrings)

    enum Search {

        enum Screen {
            static let title = String(localized: .SearchLocalizable.screenTitle)
        }

        enum Scope {
            static let title = String(localized: .SearchLocalizable.scopeTitle)
            static let author = String(localized: .SearchLocalizable.scopeAuthor)
        }

        enum EmptyState {
            static let title = String(localized: .SearchLocalizable.emptyStateTitle)
            static let message = String(localized: .SearchLocalizable.emptyStateMessage)
        }

        enum NoResults {
            static let title = String(localized: .SearchLocalizable.noResultsTitle)
            static let message = String(localized: .SearchLocalizable.noResultsMessage)
        }

        enum Placeholder {
            static let search = String(localized: .SearchLocalizable.placeholder)
        }

        enum Results {
            static let singular = String(localized: .SearchLocalizable.resultSingular)
            static let plural = String(localized: .SearchLocalizable.resultPlural)
            static func forQuery(_ query: String) -> String {
                String(localized: .SearchLocalizable.forQuery(query))
            }
            static let searching = String(localized: .SearchLocalizable.searching)
        }
    }
}
