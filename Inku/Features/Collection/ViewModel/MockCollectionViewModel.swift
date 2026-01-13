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

    func getTotalMangas() -> Int {
        mangas.count
    }

    func getTotalVolumesOwned() -> Int {
        totalVolumes > 0 ? totalVolumes : mangas.reduce(0) { $0 + $1.volumesOwnedCount }
    }

    // MARK: - Functions

    func setModelContext(_ modelContext: ModelContext) { }
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
