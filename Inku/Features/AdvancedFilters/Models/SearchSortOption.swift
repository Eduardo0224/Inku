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
            return L10n.AdvancedFilters.Sort.scoreHighToLow
        case .scoreAscending:
            return L10n.AdvancedFilters.Sort.scoreLowToHigh
        case .titleAscending:
            return L10n.AdvancedFilters.Sort.titleAToZ
        case .titleDescending:
            return L10n.AdvancedFilters.Sort.titleZToA
        case .volumesDescending:
            return L10n.AdvancedFilters.Sort.volumesHighToLow
        case .volumesAscending:
            return L10n.AdvancedFilters.Sort.volumesLowToHigh
        }
    }

    var iconName: String {
        switch self {
        case .scoreDescending, .scoreAscending:
            return "star.fill"
        case .titleAscending, .titleDescending:
            return "textformat.abc"
        case .volumesDescending, .volumesAscending:
            return "books.vertical.fill"
        }
    }

    var isDescending: Bool {
        switch self {
        case .scoreDescending, .titleDescending, .volumesDescending:
            return true
        case .scoreAscending, .titleAscending, .volumesAscending:
            return false
        }
    }
}

// MARK: - Sorting Logic

extension SearchSortOption {

    func sort(_ mangas: [Manga]) -> [Manga] {
        switch self {
        case .scoreDescending:
            return mangas.sorted { ($0.score ?? 0) > ($1.score ?? 0) }
        case .scoreAscending:
            return mangas.sorted { ($0.score ?? 0) < ($1.score ?? 0) }
        case .titleAscending:
            return mangas.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .titleDescending:
            return mangas.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedDescending }
        case .volumesDescending:
            return mangas.sorted { ($0.volumes ?? 0) > ($1.volumes ?? 0) }
        case .volumesAscending:
            return mangas.sorted { ($0.volumes ?? 0) < ($1.volumes ?? 0) }
        }
    }
}
