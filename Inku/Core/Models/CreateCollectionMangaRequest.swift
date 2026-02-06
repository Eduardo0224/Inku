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

struct CreateCollectionMangaRequest: Codable, Sendable {

    // MARK: - Properties

    let manga: Int
    let completeCollection: Bool
    let volumesOwned: [Int]
    let readingVolume: Int?

    // MARK: - Initializers

    init(from collectionManga: CollectionManga) {
        self.manga = collectionManga.mangaId
        self.completeCollection = collectionManga.hasCompleteCollection
        self.volumesOwned = collectionManga.volumesOwnedCount > 0
            ? Array(1...collectionManga.volumesOwnedCount)
            : []
        self.readingVolume = collectionManga.currentReadingVolume
    }
}
