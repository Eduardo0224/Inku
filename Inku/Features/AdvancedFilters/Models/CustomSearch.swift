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

    var searchTitle: String?
    var searchAuthorFirstName: String?
    var searchAuthorLastName: String?
    var searchGenres: [String]?
    var searchThemes: [String]?
    var searchDemographics: [String]?
    var searchContains: Bool
}

// MARK: - Computed Properties

extension CustomSearch {

    var isEmpty: Bool {
        searchTitle == nil &&
        searchAuthorFirstName == nil &&
        searchAuthorLastName == nil &&
        (searchGenres?.isEmpty ?? true) &&
        (searchThemes?.isEmpty ?? true) &&
        (searchDemographics?.isEmpty ?? true)
    }

    var hasFilters: Bool {
        !isEmpty
    }

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

    static let emptySearch: Self = .init(
        searchContains: false
    )

    static let titleSearch: Self = .init(
        searchTitle: "dragon",
        searchContains: true
    )

    static let genreSearch: Self = .init(
        searchGenres: ["Action", "Adventure"],
        searchContains: false
    )

    static let complexSearch: Self = .init(
        searchTitle: "ball",
        searchGenres: ["Action", "Sci-Fi"],
        searchDemographics: ["Shounen"],
        searchContains: true
    )

    static let authorSearch: Self = .init(
        searchAuthorFirstName: "Akira",
        searchAuthorLastName: "Toriyama",
        searchContains: false
    )
}
