//
//  CollectionViewModel.swift
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

import Foundation
import SwiftData
import Observation

@Observable
@MainActor
final class CollectionViewModel: CollectionViewModelProtocol {

    // MARK: - Properties

    @ObservationIgnored
    private var modelContext: ModelContext?

    var errorMessage: String?

    // MARK: - CRUD Operations

    func addToCollection(_ manga: Manga) throws {
        guard let modelContext else {
            let error = CollectionError.contextNotAvailable
            handleError(error)
            throw error
        }

        guard !isInCollection(mangaId: manga.id) else {
            let error = CollectionError.alreadyExists
            handleError(error)
            throw error
        }

        let collectionManga = CollectionManga(from: manga)
        modelContext.insert(collectionManga)

        do {
            if modelContext.hasChanges {
                try modelContext.save()
                errorMessage = nil // Clear error on success
            }
        } catch {
            let collectionError = CollectionError.saveFailed(error)
            handleError(collectionError)
            throw collectionError
        }
    }

    func updateCollection(_ collectionManga: CollectionManga) throws {
        guard let modelContext else {
            let error = CollectionError.contextNotAvailable
            handleError(error)
            throw error
        }

        collectionManga.updateModifiedDate()

        do {
            if modelContext.hasChanges {
                try modelContext.save()
                errorMessage = nil // Clear error on success
            }
        } catch {
            let collectionError = CollectionError.updateFailed(error)
            handleError(collectionError)
            throw collectionError
        }
    }

    func removeFromCollection(_ collectionManga: CollectionManga) throws {
        guard let modelContext else {
            let error = CollectionError.contextNotAvailable
            handleError(error)
            throw error
        }

        modelContext.delete(collectionManga)

        do {
            if modelContext.hasChanges {
                try modelContext.save()
                errorMessage = nil // Clear error on success
            }
        } catch {
            let collectionError = CollectionError.deleteFailed(error)
            handleError(collectionError)
            throw collectionError
        }
    }

    // MARK: - Query Operations

    func isInCollection(mangaId: Int) -> Bool {
        getCollectionManga(mangaId: mangaId) != nil
    }

    func getCollectionManga(mangaId: Int) -> CollectionManga? {
        let predicate = #Predicate<CollectionManga> { manga in
            manga.mangaId == mangaId
        }

        let descriptor = FetchDescriptor<CollectionManga>(predicate: predicate)

        return try? modelContext?.fetch(descriptor).first
    }

    // MARK: - Statistics

    func getTotalMangas() -> Int {
        let descriptor = FetchDescriptor<CollectionManga>()
        return (try? modelContext?.fetchCount(descriptor)) ?? 0
    }

    func getTotalVolumesOwned() -> Int {
        let descriptor = FetchDescriptor<CollectionManga>()
        let mangas = (try? modelContext?.fetch(descriptor)) ?? []
        return mangas.reduce(0) { $0 + $1.volumesOwnedCount }
    }

    // MARK: - Functions

    func setModelContext(_ modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func clearError() {
        errorMessage = nil
    }

    // MARK: - Private Functions

    private func handleError(_ error: Error) {
        if let collectionError = error as? CollectionError {
            errorMessage = collectionError.errorDescription
        } else {
            errorMessage = L10n.Error.generic
        }
    }
}

// MARK: - CollectionError

enum CollectionError: LocalizedError, Equatable {
    case contextNotAvailable
    case alreadyExists
    case notFound
    case saveFailed(Error)
    case updateFailed(Error)
    case deleteFailed(Error)

    var errorDescription: String? {
        switch self {
        case .contextNotAvailable:
            return L10n.Collection.Error.contextNotAvailable
        case .alreadyExists:
            return L10n.Collection.Error.alreadyExists
        case .notFound:
            return L10n.Collection.Error.notFound
        case .saveFailed(let error):
            return "\(L10n.Collection.Error.saveFailed): \(error.localizedDescription)"
        case .updateFailed(let error):
            return "\(L10n.Collection.Error.updateFailed): \(error.localizedDescription)"
        case .deleteFailed(let error):
            return "\(L10n.Collection.Error.deleteFailed): \(error.localizedDescription)"
        }
    }

    static func ==(lhs: CollectionError, rhs: CollectionError) -> Bool {
        switch (lhs, rhs) {
        case (.contextNotAvailable, .contextNotAvailable):
            return true
        case (.alreadyExists, .alreadyExists):
            return true
        case (.notFound, .notFound):
            return true
        case (.saveFailed(_), .saveFailed(_)):
            return true
        case (.updateFailed(_), .updateFailed(_)):
            return true
        case (.deleteFailed(_), .deleteFailed(_)):
            return true
        default:
            return false
        }
    }
}
