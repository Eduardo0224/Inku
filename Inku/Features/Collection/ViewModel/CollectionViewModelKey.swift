//
//  CollectionViewModelKey.swift
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

import SwiftUI
import SwiftData

// MARK: - EmptyCollectionViewModel

/// Default empty implementation for EnvironmentKey
/// This is a non-isolated placeholder that should never be used in production
private final class EmptyCollectionViewModel: CollectionViewModelProtocol {

    var errorMessage: String?

    func addToCollection(_ manga: Manga) throws {
        fatalError("CollectionViewModel not provided in environment")
    }

    func updateCollection(_ collectionManga: CollectionManga) throws {
        fatalError("CollectionViewModel not provided in environment")
    }

    func removeFromCollection(_ collectionManga: CollectionManga) throws {
        fatalError("CollectionViewModel not provided in environment")
    }

    func isInCollection(mangaId: Int) -> Bool {
        return false
    }

    func getCollectionManga(mangaId: Int) -> CollectionManga? {
        return nil
    }

    func getTotalMangas() -> Int {
        return 0
    }

    func getTotalVolumesOwned() -> Int {
        return 0
    }

    func setModelContext(_ modelContext: ModelContext) {
        fatalError("CollectionViewModel not provided in environment")
    }
}

// MARK: - CollectionViewModelKey

private struct CollectionViewModelKey: EnvironmentKey {
    nonisolated(unsafe) static let defaultValue: any CollectionViewModelProtocol = EmptyCollectionViewModel()
}

// MARK: - EnvironmentValues Extension

extension EnvironmentValues {
    var collectionViewModel: any CollectionViewModelProtocol {
        get { self[CollectionViewModelKey.self] }
        set { self[CollectionViewModelKey.self] = newValue }
    }
}
