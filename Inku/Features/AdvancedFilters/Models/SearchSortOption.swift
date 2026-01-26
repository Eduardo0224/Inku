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

/// Sorting options for manga search results.
///
/// Used in AdvancedFilters to determine how results should be sorted.
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

    /// Localized display name for UI.
    var displayName: String {
        switch self {
        case .scoreDescending:
            return String(localized: "sort.score.high_to_low", defaultValue: "Score: High to Low")
        case .scoreAscending:
            return String(localized: "sort.score.low_to_high", defaultValue: "Score: Low to High")
        case .titleAscending:
            return String(localized: "sort.title.a_to_z", defaultValue: "Title: A to Z")
        case .titleDescending:
            return String(localized: "sort.title.z_to_a", defaultValue: "Title: Z to A")
        case .volumesDescending:
            return String(localized: "sort.volumes.high_to_low", defaultValue: "Volumes: Most to Least")
        case .volumesAscending:
            return String(localized: "sort.volumes.low_to_high", defaultValue: "Volumes: Least to Most")
        }
    }

    /// SF Symbol icon for UI.
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

    /// Returns `true` if this is a descending sort.
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

    /// Sorts an array of mangas based on this option.
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
