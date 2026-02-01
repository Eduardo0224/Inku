//
//  CreateCollectionMangaRequest.swift
//  Inku
//
//  Created by Eduardo Andrade on 31/01/26.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2025 Eduardo Andrade. All rights reserved.
//

import Foundation

/// Request body for POST /collection/manga
struct CreateCollectionMangaRequest: Sendable {

    // MARK: - Properties

    let manga: Int
    let completeCollection: Bool
    let volumesOwned: [Int]
    let readingVolume: Int?

    // MARK: - Initializers

    init(from collectionManga: CollectionManga) {
        self.manga = collectionManga.mangaId
        self.completeCollection = collectionManga.hasCompleteCollection

        // Convert volumesOwnedCount to array [1, 2, 3, ..., count]
        self.volumesOwned = collectionManga.volumesOwnedCount > 0
            ? Array(1...collectionManga.volumesOwnedCount)
            : []

        self.readingVolume = collectionManga.currentReadingVolume
    }
}

// MARK: - Codable

extension CreateCollectionMangaRequest: Codable {

    enum CodingKeys: String, CodingKey {
        case manga
        case completeCollection
        case volumesOwned
        case readingVolume
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(manga, forKey: .manga)
        try container.encode(completeCollection, forKey: .completeCollection)
        try container.encode(volumesOwned, forKey: .volumesOwned)
        // Always encode readingVolume, even if nil (as null)
        try container.encode(readingVolume, forKey: .readingVolume)
    }
}
