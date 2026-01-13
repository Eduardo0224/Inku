//
//  CollectionViewModelProtocol.swift
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

@MainActor
protocol CollectionViewModelProtocol {

    // MARK: - CRUD Operations

    func addToCollection(_ manga: Manga) throws
    func updateCollection(_ collectionManga: CollectionManga) throws
    func removeFromCollection(_ collectionManga: CollectionManga) throws

    // MARK: - Query Operations

    func isInCollection(mangaId: Int) -> Bool
    func getCollectionManga(mangaId: Int) -> CollectionManga?

    // MARK: - Statistics

    func getTotalMangas() -> Int
    func getTotalVolumesOwned() -> Int

    func setModelContext(_ modelContext: ModelContext)
}
