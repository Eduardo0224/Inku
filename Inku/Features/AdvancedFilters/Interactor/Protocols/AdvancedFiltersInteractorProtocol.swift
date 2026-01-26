//
//  AdvancedFiltersInteractorProtocol.swift
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

/// Protocol defining business logic for Advanced Filters feature.
///
/// This interactor handles multi-criteria manga search using the `POST /search/manga` endpoint.
protocol AdvancedFiltersInteractorProtocol: Sendable {

    // MARK: - Custom Search

    /// Performs a multi-criteria search for mangas.
    ///
    /// - Parameters:
    ///   - search: CustomSearch object with filter criteria
    ///   - page: Page number (starting from 1)
    ///   - per: Number of items per page
    /// - Returns: MangaListResponse with filtered data and pagination metadata
    /// - Throws: NetworkError if request fails
    ///
    /// **API**: `POST /search/manga`
    ///
    /// **Example**:
    /// ```swift
    /// let search = CustomSearch(
    ///     searchTitle: "dragon",
    ///     searchGenres: ["Action"],
    ///     searchContains: true
    /// )
    /// let response = try await interactor.searchMangas(search, page: 1, per: 20)
    /// ```
    func searchMangas(_ search: CustomSearch, page: Int, per: Int) async throws -> MangaListResponse

    // MARK: - Filter Options

    /// Fetches all available genres for filtering.
    /// - Returns: Array of genre names (strings)
    func fetchGenres() async throws -> [String]

    /// Fetches all available demographics for filtering.
    /// - Returns: Array of demographic names (strings)
    func fetchDemographics() async throws -> [String]

    /// Fetches all available themes for filtering.
    /// - Returns: Array of theme names (strings)
    func fetchThemes() async throws -> [String]
}
