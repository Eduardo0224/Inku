//
//  CollectionInteractorProtocol.swift
//  Inku
//
//  Created by Eduardo Andrade on 20/01/26.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2026 Eduardo Andrade. All rights reserved.
//

import Foundation

protocol CollectionInteractorProtocol: Sendable {

    // MARK: - Functions

    /// Fetches detailed manga information by its ID
    /// - Parameter id: The manga ID to fetch
    /// - Returns: A manga object with complete information
    func getMangaById(_ id: Int) async throws -> Manga
}
