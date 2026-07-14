//
//  WatchMangaDisplayItem.swift
//  InkuWatch
//
//  Created by Eduardo Andrade on 10/07/26.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2026 Eduardo Andrade. All rights reserved.
//

import Foundation

// MARK: - Watch Manga Display Item

/// Plain value-type representation of a manga, decoupled from
/// SwiftData's `@Model` infrastructure.
///
/// Views receive this struct so they never depend on `WatchMangaItem`
/// directly. Previews work without a `ModelContainer` because the
/// struct has no SwiftData runtime requirements.
struct WatchMangaDisplayItem: Identifiable, Sendable, Equatable {

    // MARK: - Stored Properties

    let mangaId: Int
    let title: String
    let japaneseTitle: String?
    let coverImageData: Data?
    let score: Double?
    let volumesOwned: Int
    let totalVolumes: Int?
    let currentReadingVolume: Int?
    let hasCompleteCollection: Bool
    let dateAdded: Date

    // MARK: - Identifiable

    var id: Int { mangaId }

    // MARK: - Computed Properties

    var readingProgress: Double? {
        guard let total = totalVolumes, total > 0 else { return nil }
        return Double(volumesOwned) / Double(total)
    }

    var isCurrentlyReading: Bool {
        currentReadingVolume != nil
    }

    var isComplete: Bool {
        guard let total = totalVolumes else { return hasCompleteCollection }
        return hasCompleteCollection || volumesOwned >= total
    }

    // MARK: - Initializers

    init(
        mangaId: Int,
        title: String,
        japaneseTitle: String? = nil,
        coverImageData: Data? = nil,
        score: Double? = nil,
        volumesOwned: Int = 0,
        totalVolumes: Int? = nil,
        currentReadingVolume: Int? = nil,
        hasCompleteCollection: Bool = false,
        dateAdded: Date = Date()
    ) {
        self.mangaId = mangaId
        self.title = title
        self.japaneseTitle = japaneseTitle
        self.coverImageData = coverImageData
        self.score = score
        self.volumesOwned = volumesOwned
        self.totalVolumes = totalVolumes
        self.currentReadingVolume = currentReadingVolume
        self.hasCompleteCollection = hasCompleteCollection
        self.dateAdded = dateAdded
    }
}
