//
//  MangaListResponse.swift
//  Inku
//
//  Created by Eduardo Andrade on 22/12/25.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2025 Eduardo Andrade. All rights reserved.
//

import Foundation

struct MangaListResponse: Codable, Sendable {

    // MARK: - Properties

    let data: [Manga]
    let metadata: PaginationMetadata
}

// MARK: - Test Data

extension MangaListResponse {

    static let testData: Self = .init(
        data: [],
        metadata: .testData
    )
}
