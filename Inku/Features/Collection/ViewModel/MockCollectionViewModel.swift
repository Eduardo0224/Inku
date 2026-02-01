//
//  MockCollectionViewModel.swift
//  Inku
//
//  Created by Eduardo Andrade on 13/01/26.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2026 Eduardo Andrade. All rights reserved.
//

import Foundation
import SwiftData
import Observation

@Observable
@MainActor
final class MockCollectionViewModel: CollectionViewModelProtocol {

    // MARK: - Properties

    var errorMessage: String?
    var isLoadingManga: Bool = false
    var loadedManga: Manga?

    // MARK: - Mock Data

    private var mangas: [CollectionManga] = []
    private var totalVolumes: Int = 0

    // MARK: - Initializers

    init(mangas: [CollectionManga] = [], totalVolumes: Int = 0) {
        self.mangas = mangas
        self.totalVolumes = totalVolumes
    }

    // MARK: - CRUD Operations

    func addToCollection(_ manga: Manga) throws {
        guard !isInCollection(mangaId: manga.id) else {
            throw CollectionError.alreadyExists
        }

        let collectionManga = CollectionManga(from: manga)
        mangas.append(collectionManga)
    }

    func updateCollection(_ collectionManga: CollectionManga) throws {
        collectionManga.updateModifiedDate()
    }

    func removeFromCollection(_ collectionManga: CollectionManga) throws {
        mangas.removeAll { $0.mangaId == collectionManga.mangaId }
    }

    // MARK: - Query Operations

    func isInCollection(mangaId: Int) -> Bool {
        mangas.contains { $0.mangaId == mangaId }
    }

    func getCollectionManga(mangaId: Int) -> CollectionManga? {
        mangas.first { $0.mangaId == mangaId }
    }

    // MARK: - Statistics

    var totalMangas: Int {
        mangas.count
    }

    var totalVolumesOwned: Int {
        totalVolumes > 0 ? totalVolumes : mangas.reduce(0) { $0 + $1.volumesOwnedCount }
    }

    var completedCount: Int {
        mangas.filter { $0.isComplete }.count
    }

    var readingCount: Int {
        mangas.filter { $0.isCurrentlyReading }.count
    }

    var averageProgress: Double {
        let validProgresses = mangas.compactMap { $0.readingProgress }
        guard !validProgresses.isEmpty else {
            return 0.0
        }

        return validProgresses.reduce(0.0, +) / Double(validProgresses.count)
    }

    var completionPercentage: Double {
        let total = totalMangas
        guard total > 0 else {
            return 0.0
        }

        let completed = completedCount
        return Double(completed) / Double(total)
    }

    func getTopSeriesByVolumes(limit: Int) -> [CollectionManga] {
        Array(mangas.sorted { $0.volumesOwnedCount > $1.volumesOwnedCount }.prefix(limit))
    }

    func getMostRecentlyAdded(limit: Int) -> [CollectionManga] {
        Array(mangas.sorted { $0.dateAdded > $1.dateAdded }.prefix(limit))
    }

    func getMostRecentlyModified(limit: Int) -> [CollectionManga] {
        Array(mangas.sorted { $0.lastModified > $1.lastModified }.prefix(limit))
    }

    // MARK: - Manga Loading

    func loadMangaById(_ id: Int) async {
        isLoadingManga = true
        loadedManga = .testData
        isLoadingManga = false
    }

    // MARK: - Functions

    func setModelContext(_ modelContext: ModelContext) { }

    func clearError() {
        errorMessage = nil
    }

    // MARK: - Cloud Sync

    func getAllLocalMangas() throws -> [CollectionManga] {
        mangas
    }

    func addCloudMangasToLocal(_ cloudMangas: [CloudCollectionManga]) throws {
        // Mock implementation: Add cloud mangas that aren't already in local
        let localMangaIds = Set(mangas.map { $0.mangaId })
        let mangasToAdd = cloudMangas.filter { !localMangaIds.contains($0.manga.id) }

        for cloudManga in mangasToAdd {
            let collectionManga = CollectionManga(
                mangaId: cloudManga.manga.id,
                title: cloudManga.manga.title,
                coverImageURL: cloudManga.manga.mainPicture,
                totalVolumes: cloudManga.manga.volumes,
                volumesOwnedCount: cloudManga.volumesOwned.count,
                currentReadingVolume: cloudManga.readingVolume,
                hasCompleteCollection: cloudManga.completeCollection
            )
            mangas.append(collectionManga)
        }
    }

    func getLocalMangaIds() throws -> Set<Int> {
        Set(mangas.map { $0.mangaId })
    }
}

// MARK: - Preview Helpers

extension MockCollectionViewModel {

    static var empty: MockCollectionViewModel {
        MockCollectionViewModel(mangas: [], totalVolumes: 0)
    }

    static var withData: MockCollectionViewModel {
        MockCollectionViewModel(
            mangas: .previewData,
            totalVolumes: 234
        )
    }
}
