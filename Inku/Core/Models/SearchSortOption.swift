//
//  SearchSortOption.swift
//  Inku
//
//  Created by Eduardo Andrade on 26/01/26.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2026 Eduardo Andrade. All rights reserved.
//

import Foundation

enum SearchSortOption: String, CaseIterable, Identifiable, Sendable {

    // MARK: - Cases

    case scoreDescending
    case scoreAscending
    case titleAscending
    case titleDescending
    case volumesDescending
    case volumesAscending

    // MARK: - Identifiable

    var id: String { rawValue }

    // MARK: - Computed Properties

    var displayName: String {
        switch self {
        case .scoreDescending:
            L10n.AdvancedFilters.Sort.scoreHighToLow
        case .scoreAscending:
            L10n.AdvancedFilters.Sort.scoreLowToHigh
        case .titleAscending:
            L10n.AdvancedFilters.Sort.titleAToZ
        case .titleDescending:
            L10n.AdvancedFilters.Sort.titleZToA
        case .volumesDescending:
            L10n.AdvancedFilters.Sort.volumesHighToLow
        case .volumesAscending:
            L10n.AdvancedFilters.Sort.volumesLowToHigh
        }
    }

    var iconName: String {
        switch self {
        case .scoreDescending, .scoreAscending:
            "star.fill"
        case .titleAscending, .titleDescending:
            "textformat.abc"
        case .volumesDescending, .volumesAscending:
            "books.vertical.fill"
        }
    }

    var isDescending: Bool {
        switch self {
        case .scoreDescending, .titleDescending, .volumesDescending:
            true
        case .scoreAscending, .titleAscending, .volumesAscending:
            false
        }
    }
}

// MARK: - Sorting Logic

extension SearchSortOption {

    func sort(_ mangas: [Manga]) -> [Manga] {
        switch self {
        case .scoreDescending:
            mangas.sorted { ($0.score ?? 0) > ($1.score ?? 0) }
        case .scoreAscending:
            mangas.sorted { ($0.score ?? 0) < ($1.score ?? 0) }
        case .titleAscending:
            mangas.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .titleDescending:
            mangas.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedDescending }
        case .volumesDescending:
            mangas.sorted { ($0.volumes ?? 0) > ($1.volumes ?? 0) }
        case .volumesAscending:
            mangas.sorted { ($0.volumes ?? 0) < ($1.volumes ?? 0) }
        }
    }
}
