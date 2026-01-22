//
//  EmptyCollectionViewModel.swift
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

import SwiftData

/// Default empty implementation for EnvironmentKey
/// This is a non-isolated placeholder that should never be used in production
final class EmptyCollectionViewModel: CollectionViewModelProtocol {

    var errorMessage: String?
    var isLoadingManga: Bool = false
    var loadedManga: Manga?

    func addToCollection(_ manga: Manga) throws {
        fatalError("CollectionViewModel not provided in environment")
    }

    func updateCollection(_ collectionManga: CollectionManga) throws {
        fatalError("CollectionViewModel not provided in environment")
    }

    func removeFromCollection(_ collectionManga: CollectionManga) throws {
        fatalError("CollectionViewModel not provided in environment")
    }

    func isInCollection(mangaId: Int) -> Bool { false }

    func getCollectionManga(mangaId: Int) -> CollectionManga? { nil }

    var totalMangas: Int { 0 }

    var totalVolumesOwned: Int { 0 }

    var completedCount: Int { 0 }

    var readingCount: Int { 0 }

    var averageProgress: Double { 0.0 }

    var completionPercentage: Double { 0.0 }

    func getTopSeriesByVolumes(limit: Int) -> [CollectionManga] { [] }

    func getMostRecentlyAdded(limit: Int) -> [CollectionManga] { [] }

    func getMostRecentlyModified(limit: Int) -> [CollectionManga] { [] }

    func setModelContext(_ modelContext: ModelContext) {
        // No-op: EmptyCollectionViewModel is a placeholder
        // This prevents crashes in previews when CollectionViewModel is not provided
    }

    func clearError() {
        // No-op: EmptyCollectionViewModel is a placeholder
    }

    func loadMangaById(_ id: Int) async {
        // No-op: EmptyCollectionViewModel is a placeholder
    }
}
