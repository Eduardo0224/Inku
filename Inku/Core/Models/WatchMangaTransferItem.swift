//
//  WatchMangaTransferItem.swift
//  Inku
//
//  Created by Eduardo Andrade on 02/06/26.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2026 Eduardo Andrade. All rights reserved.
//
//  Shared between iOS and watchOS targets for WatchConnectivity transfers.
//

import Foundation

// MARK: - Watch Manga Transfer Item

struct WatchMangaTransferItem: Codable, Sendable {

    let mangaId: Int
    let title: String
    let japaneseTitle: String?
    let score: Double?
    let volumesOwned: Int
    let totalVolumes: Int?
    let currentReadingVolume: Int?
    let hasCompleteCollection: Bool
    let dateAdded: Date
    let coverImageJPEGBase64: String?

    // MARK: - Initializers

    init(from collectionManga: CollectionManga, coverJPEGBase64: String?) {
        self.mangaId = collectionManga.mangaId
        self.title = collectionManga.title
        self.japaneseTitle = collectionManga.japaneseTitle
        self.score = collectionManga.score
        self.volumesOwned = collectionManga.volumesOwnedCount
        self.totalVolumes = collectionManga.totalVolumes
        self.currentReadingVolume = collectionManga.currentReadingVolume
        self.hasCompleteCollection = collectionManga.hasCompleteCollection
        self.dateAdded = collectionManga.dateAdded
        self.coverImageJPEGBase64 = coverJPEGBase64
    }
}
