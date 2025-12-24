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
    }
}
