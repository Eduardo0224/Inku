//
//  CollectionManga.swift
//  Inku
//
//  Created by Eduardo Andrade on 08/01/26.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2026 Eduardo Andrade. All rights reserved.
//

import SwiftData
import Foundation

@Model
final class CollectionManga: Identifiable {

    // MARK: - Identifiable

    var id: Int { mangaId }

    // MARK: - Properties

    @Attribute(.unique) var mangaId: Int
    var title: String
    var coverImageURL: String?
    var totalVolumes: Int?

    // MARK: - Collection Data (MVP Requirements)

    /// Número de tomos comprados
    var volumesOwnedCount: Int

    /// Tomo por el que va leyendo
    var currentReadingVolume: Int?

    /// Si tiene o no la colección completa
    var hasCompleteCollection: Bool

    // MARK: - Metadata

    var dateAdded: Date
    var lastModified: Date

    // MARK: - Computed Properties

    var cleanCoverImageURL: String? {
        coverImageURL?.replacingOccurrences(of: "\"", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var coverURL: URL? {
        guard let cleanURL = cleanCoverImageURL else { return nil }
        return URL(string: cleanURL)
    }

    var readingProgress: Double? {
        guard let total = totalVolumes, total > 0 else { return nil }
        return Double(volumesOwnedCount) / Double(total)
    }

    var isCurrentlyReading: Bool {
        currentReadingVolume != nil
    }

    var isComplete: Bool {
        guard let total = totalVolumes else { return hasCompleteCollection }
        return hasCompleteCollection || volumesOwnedCount >= total
    }

    // MARK: - Indexes

    #Index<CollectionManga>(
        [\.dateAdded],
        [\.lastModified],
        [\.title],
        [\.hasCompleteCollection]
    )

    // MARK: - Initializers

    init(
        mangaId: Int,
        title: String,
        coverImageURL: String? = nil,
        totalVolumes: Int? = nil,
        volumesOwnedCount: Int = 0,
        currentReadingVolume: Int? = nil,
        hasCompleteCollection: Bool = false
    ) {
        self.mangaId = mangaId
        self.title = title
        self.coverImageURL = coverImageURL
        self.totalVolumes = totalVolumes
        self.volumesOwnedCount = volumesOwnedCount
        self.currentReadingVolume = currentReadingVolume
        self.hasCompleteCollection = hasCompleteCollection
        self.dateAdded = Date()
        self.lastModified = Date()
    }
}

// MARK: - Extensions

extension CollectionManga {
    /// Helper para crear desde Manga
    convenience init(from manga: Manga) {
        self.init(
            mangaId: manga.id,
            title: manga.title,
            coverImageURL: manga.mainPicture?.replacingOccurrences(of: "\"", with: ""),
            totalVolumes: manga.volumes
        )
    }

    /// Update lastModified
    func updateModifiedDate() {
        self.lastModified = Date()
    }
}

// MARK: - Preview Data

extension [CollectionManga] {
    static var previewData: [CollectionManga] {
        [
            CollectionManga(
                mangaId: 1,
                title: "One Piece",
                coverImageURL: "https://cdn.myanimelist.net/images/manga/3/216460.jpg",
                totalVolumes: 106,
                volumesOwnedCount: 50,
                currentReadingVolume: 51,
                hasCompleteCollection: false
            ),
            CollectionManga(
                mangaId: 2,
                title: "Naruto",
                coverImageURL: "https://cdn.myanimelist.net/images/manga/3/249658.jpg",
                totalVolumes: 72,
                volumesOwnedCount: 72,
                currentReadingVolume: nil,
                hasCompleteCollection: true
            ),
            CollectionManga(
                mangaId: 3,
                title: "Bleach",
                coverImageURL: "https://cdn.myanimelist.net/images/manga/3/180031.jpg",
                totalVolumes: 74,
                volumesOwnedCount: 30,
                currentReadingVolume: 25,
                hasCompleteCollection: false
            ),
            CollectionManga(
                mangaId: 4,
                title: "Death Note",
                coverImageURL: "https://cdn.myanimelist.net/images/manga/2/253119.jpg",
                totalVolumes: 12,
                volumesOwnedCount: 12,
                currentReadingVolume: nil,
                hasCompleteCollection: true
            ),
            CollectionManga(
                mangaId: 5,
                title: "Attack on Titan",
                coverImageURL: "https://cdn.myanimelist.net/images/manga/2/37846.jpg",
                totalVolumes: 34,
                volumesOwnedCount: 20,
                currentReadingVolume: 21,
                hasCompleteCollection: false
            )
        ]
    }
}
