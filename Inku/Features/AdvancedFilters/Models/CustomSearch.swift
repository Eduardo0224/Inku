//
//  CustomSearch.swift
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

/// Multi-criteria search request model for advanced filtering.
///
/// This model is sent as JSON body to `POST /search/manga` endpoint.
/// It allows filtering mangas by multiple criteria simultaneously.
///
/// **API Endpoint**: `POST /search/manga`
///
/// **Example Usage**:
/// ```swift
/// let search = CustomSearch(
///     searchTitle: "dragon",
///     searchGenres: ["Action", "Adventure"],
///     searchDemographics: ["Shounen"],
///     searchContains: true
/// )
/// ```
struct CustomSearch: Codable, Sendable {

    // MARK: - Properties

    /// Title to search for (optional).
    /// Works with `searchContains` to determine if it's a "begins with" or "contains" search.
    var searchTitle: String?

    /// Author's first name to search for (optional).
    var searchAuthorFirstName: String?

    /// Author's last name to search for (optional).
    var searchAuthorLastName: String?

    /// Array of genre names to filter by (optional).
    /// Examples: ["Action", "Adventure", "Sci-Fi", "Romance"]
    var searchGenres: [String]?

    /// Array of theme names to filter by (optional).
    /// Examples: ["School", "Mecha", "Vampires", "Music"]
    var searchThemes: [String]?

    /// Array of demographic names to filter by (optional).
    /// Examples: ["Shounen", "Shoujo", "Seinen", "Kids", "Josei"]
    var searchDemographics: [String]?

    /// Determines search behavior for title and author fields.
    ///
    /// - `false`: "Begins with" search (default)
    /// - `true`: "Contains" search
    var searchContains: Bool

    // MARK: - Initializers

    init(
        searchTitle: String? = nil,
        searchAuthorFirstName: String? = nil,
        searchAuthorLastName: String? = nil,
        searchGenres: [String]? = nil,
        searchThemes: [String]? = nil,
        searchDemographics: [String]? = nil,
        searchContains: Bool = false
    ) {
        self.searchTitle = searchTitle
        self.searchAuthorFirstName = searchAuthorFirstName
        self.searchAuthorLastName = searchAuthorLastName
        self.searchGenres = searchGenres
        self.searchThemes = searchThemes
        self.searchDemographics = searchDemographics
        self.searchContains = searchContains
    }
}

// MARK: - Computed Properties

extension CustomSearch {

    /// Returns `true` if all search criteria are empty.
    var isEmpty: Bool {
        searchTitle == nil &&
        searchAuthorFirstName == nil &&
        searchAuthorLastName == nil &&
        (searchGenres?.isEmpty ?? true) &&
        (searchThemes?.isEmpty ?? true) &&
        (searchDemographics?.isEmpty ?? true)
    }

    /// Returns `true` if at least one search criterion is set.
    var hasFilters: Bool {
        !isEmpty
    }

    /// Count of active filters (for UI display).
    var activeFilterCount: Int {
        var count = 0
        if searchTitle != nil { count += 1 }
        if searchAuthorFirstName != nil { count += 1 }
        if searchAuthorLastName != nil { count += 1 }
        if let genres = searchGenres, !genres.isEmpty { count += genres.count }
        if let themes = searchThemes, !themes.isEmpty { count += themes.count }
        if let demographics = searchDemographics, !demographics.isEmpty { count += demographics.count }
        return count
    }
}

// MARK: - Test Data

extension CustomSearch {

    /// Empty search (no filters applied).
    static let emptySearch: Self = .init(
        searchContains: false
    )

    /// Test data: Search by title only.
    static let titleSearch: Self = .init(
        searchTitle: "dragon",
        searchContains: true
    )

    /// Test data: Search by multiple genres.
    static let genreSearch: Self = .init(
        searchGenres: ["Action", "Adventure"],
        searchContains: false
    )

    /// Test data: Complex multi-criteria search.
    static let complexSearch: Self = .init(
        searchTitle: "ball",
        searchGenres: ["Action", "Sci-Fi"],
        searchDemographics: ["Shounen"],
        searchContains: true
    )

    /// Test data: Author search.
    static let authorSearch: Self = .init(
        searchAuthorFirstName: "Akira",
        searchAuthorLastName: "Toriyama",
        searchContains: false
    )
}
