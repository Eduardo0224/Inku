//
//  WatchMangaItem.swift
//  InkuWatch
//
//  Created by Eduardo Andrade on 02/06/26.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2026 Eduardo Andrade. All rights reserved.
//

import Foundation
import SwiftData

// MARK: - Watch Manga Item

@Model
final class WatchMangaItem {

    // MARK: - Properties

    @Attribute(.unique) var mangaId: Int
    var title: String
    var japaneseTitle: String?
    var coverImageData: Data?
    var score: Double?
    var volumesOwned: Int
    var totalVolumes: Int?
    var currentReadingVolume: Int?
    var hasCompleteCollection: Bool
    var dateAdded: Date
    var lastSynced: Date

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
        self.lastSynced = Date()
    }

    // MARK: - Functions

    func apply(_ item: WatchMangaTransferItem) {
        title = item.title
        japaneseTitle = item.japaneseTitle
        score = item.score
        volumesOwned = item.volumesOwned
        totalVolumes = item.totalVolumes
        currentReadingVolume = item.currentReadingVolume
        hasCompleteCollection = item.hasCompleteCollection
        dateAdded = item.dateAdded
        lastSynced = Date()

        if let base64 = item.coverImageJPEGBase64,
           let data = Data(base64Encoded: base64) {
            coverImageData = data
        }
    }

    // MARK: - Display Mapping

    /// Converts this `@Model` instance into a plain value-type
    /// for use in views that should not depend on SwiftData.
    var displayItem: WatchMangaDisplayItem {
        WatchMangaDisplayItem(
            mangaId: mangaId,
            title: title,
            japaneseTitle: japaneseTitle,
            coverImageData: coverImageData,
            score: score,
            volumesOwned: volumesOwned,
            totalVolumes: totalVolumes,
            currentReadingVolume: currentReadingVolume,
            hasCompleteCollection: hasCompleteCollection,
            dateAdded: dateAdded
        )
    }
}
