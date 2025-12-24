//
//  MangaListInteractorProtocol.swift
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

protocol MangaListInteractorProtocol: Sendable {

    // MARK: - Manga Fetching

    /// Fetches a paginated list of mangas
    /// - Parameters:
    ///   - page: Page number (starting from 1)
    ///   - per: Number of items per page
    /// - Returns: MangaListResponse with data and pagination metadata
    func fetchMangas(page: Int, per: Int) async throws -> MangaListResponse

    /// Fetches mangas filtered by genre
    /// - Parameters:
    ///   - genre: Genre ID to filter by
    ///   - page: Page number (starting from 1)
    ///   - per: Number of items per page
    /// - Returns: MangaListResponse with filtered data
    func fetchMangasByGenre(_ genre: String, page: Int, per: Int) async throws -> MangaListResponse

    /// Fetches mangas filtered by demographic
    /// - Parameters:
    ///   - demographic: Demographic ID to filter by
    ///   - page: Page number (starting from 1)
    ///   - per: Number of items per page
    /// - Returns: MangaListResponse with filtered data
    func fetchMangasByDemographic(_ demographic: String, page: Int, per: Int) async throws -> MangaListResponse

    /// Fetches mangas filtered by theme
    /// - Parameters:
    ///   - theme: Theme ID to filter by
    ///   - page: Page number (starting from 1)
    ///   - per: Number of items per page
    /// - Returns: MangaListResponse with filtered data
    func fetchMangasByTheme(_ theme: String, page: Int, per: Int) async throws -> MangaListResponse

    // MARK: - Filter Options Fetching

    /// Fetches all available genres
    /// - Returns: Array of Genre objects
    func fetchGenres() async throws -> [String]

    /// Fetches all available demographics
    /// - Returns: Array of Demographic objects
    func fetchDemographics() async throws -> [String]

    /// Fetches all available themes
    /// - Returns: Array of Theme objects
    func fetchThemes() async throws -> [String]
}
