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

    /// Searches for mangas by title containing the specified text (with pagination)
    /// - Parameters:
    ///   - text: The text to search for in manga titles
    ///   - page: The page number for pagination
    ///   - per: Number of items per page
    /// - Returns: A response containing matching mangas and metadata
    func searchMangasContains(_ text: String, page: Int, per: Int) async throws -> MangaListResponse

    /// Searches for mangas by title beginning with the specified text (no pagination)
    /// - Parameter text: The text that manga titles should begin with
    /// - Returns: An array of mangas whose titles begin with the search text
    func searchMangasBeginsWith(_ text: String) async throws -> [Manga]

    /// Searches for authors by name
    /// - Parameter name: The author name to search for
    /// - Returns: An array of authors matching the search term
    func searchAuthorsByName(_ name: String) async throws -> [Author]
}
