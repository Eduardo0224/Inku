//
//  SearchInteractorProtocol.swift
//  Inku
//
//  Created by Eduardo Andrade on 02/01/26.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2026 Eduardo Andrade. All rights reserved.
//

import Foundation

protocol SearchInteractorProtocol: Sendable {

    // MARK: - Functions

    /// Searches for mangas by title containing the specified text
    /// - Parameters:
    ///   - text: The text to search for in manga titles
    ///   - page: The page number for pagination
    ///   - per: Number of items per page
    /// - Returns: A response containing matching mangas and metadata
    func searchMangasByTitle(_ text: String, page: Int, per: Int) async throws -> MangaListResponse

    /// Searches for authors by name
    /// - Parameter name: The author name to search for
    /// - Returns: An array of authors matching the search term
    func searchAuthorsByName(_ name: String) async throws -> [Author]
}
