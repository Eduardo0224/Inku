//
//  CollectionTests+ViewModel.swift
//  InkuTests
//
//  Created by Eduardo Andrade on 09/01/26.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2026 Eduardo Andrade. All rights reserved.
//

import Foundation
import Testing
import SwiftData
@testable import Inku

extension CollectionTests {

    @Suite("ViewModel Tests")
    @MainActor
    struct ViewModelTests {

        // MARK: - Subject Under Test

        let sut: CollectionViewModel

        // MARK: - Properties

        let container: ModelContainer
        let modelContext: ModelContext

        // MARK: - Initializers

        init() throws {
            let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
            container = try ModelContainer(
                for: CollectionManga.self,
                configurations: configuration
            )
            modelContext = container.mainContext
            sut = CollectionViewModel()
            sut.setModelContext(modelContext)
        }

        // MARK: - Add To Collection Tests

        @Test("Add manga to collection successfully")
        func addToCollectionSuccess() throws {
            // Given
            let manga = Self.sampleManga
            #expect(sut.isInCollection(mangaId: manga.id) == false)

            // When
            try sut.addToCollection(manga)

            // Then
            #expect(sut.isInCollection(mangaId: manga.id) == true)
            #expect(sut.getTotalMangas() == 1)

            let collectionManga = sut.getCollectionManga(mangaId: manga.id)
            #expect(collectionManga != nil)
            #expect(collectionManga?.title == manga.title)
            #expect(collectionManga?.mangaId == manga.id)
            #expect(collectionManga?.volumesOwnedCount == 0)
            #expect(sut.errorMessage == nil)
        }

        @Test("Add manga to collection throws error if already exists")
        func addToCollectionAlreadyExists() throws {
            // Given
            let manga = Self.sampleManga
            try sut.addToCollection(manga)
            #expect(sut.isInCollection(mangaId: manga.id) == true)

            // When/Then
            #expect(throws: CollectionError.alreadyExists) {
                try sut.addToCollection(manga)
            }
        }

        @Test("Add multiple mangas to collection")
        func addMultipleMangasToCollection() throws {
            // Given
            let manga1 = Self.sampleManga
            let manga2 = Self.sampleManga2

            // When
            try sut.addToCollection(manga1)
            try sut.addToCollection(manga2)

            // Then
            #expect(sut.getTotalMangas() == 2)
            #expect(sut.isInCollection(mangaId: manga1.id) == true)
            #expect(sut.isInCollection(mangaId: manga2.id) == true)
        }

        // MARK: - Update Collection Tests

        @Test("Update collection manga successfully")
        func updateCollectionSuccess() throws {
            // Given
            let manga = Self.sampleManga
            try sut.addToCollection(manga)

            guard let collectionManga = sut.getCollectionManga(mangaId: manga.id) else {
                Issue.record("Collection manga should exist")
                return
            }

            let originalModifiedDate = collectionManga.lastModified

            // Small delay to ensure date changes
            Thread.sleep(forTimeInterval: 0.01)

            // Modify the manga
            collectionManga.volumesOwnedCount = 5
            collectionManga.currentReadingVolume = 3
            collectionManga.hasCompleteCollection = false

            // When
            try sut.updateCollection(collectionManga)

            // Then
            let updatedManga = sut.getCollectionManga(mangaId: manga.id)
            #expect(updatedManga?.volumesOwnedCount == 5)
            #expect(updatedManga?.currentReadingVolume == 3)
            #expect(updatedManga?.hasCompleteCollection == false)
            let lastModified = try #require(updatedManga?.lastModified)
            #expect(lastModified > originalModifiedDate)
            #expect(sut.errorMessage == nil)
        }

        @Test(
            "Update collection manga with different values",
            arguments: [
                .init(volumesOwned: 10, currentReading: 5, complete: false),
                .init(volumesOwned: 72, currentReading: nil, complete: true),
                .init(volumesOwned: 0, currentReading: nil, complete: false),
                .init(volumesOwned: 50, currentReading: 51, complete: false)
            ] as [UpdateCollectionArgument]
        )
        private func updateCollectionWithDifferentValues(argument: UpdateCollectionArgument) throws {
            // Given
            let manga = Self.sampleManga
            try sut.addToCollection(manga)

            guard let collectionManga = sut.getCollectionManga(mangaId: manga.id) else {
                Issue.record("Collection manga should exist")
                return
            }

            collectionManga.volumesOwnedCount = argument.volumesOwned
            collectionManga.currentReadingVolume = argument.currentReading
            collectionManga.hasCompleteCollection = argument.complete

            // When
            try sut.updateCollection(collectionManga)

            // Then
            let updatedManga = sut.getCollectionManga(mangaId: manga.id)
            #expect(updatedManga?.volumesOwnedCount == argument.volumesOwned)
            #expect(updatedManga?.currentReadingVolume == argument.currentReading)
            #expect(updatedManga?.hasCompleteCollection == argument.complete)
        }

        // MARK: - Remove From Collection Tests

        @Test("Remove manga from collection successfully")
        func removeFromCollectionSuccess() throws {
            // Given
            let manga = Self.sampleManga
            try sut.addToCollection(manga)
            #expect(sut.isInCollection(mangaId: manga.id) == true)

            guard let collectionManga = sut.getCollectionManga(mangaId: manga.id) else {
                Issue.record("Collection manga should exist")
                return
            }

            // When
            try sut.removeFromCollection(collectionManga)

            // Then
            #expect(sut.isInCollection(mangaId: manga.id) == false)
            #expect(sut.getTotalMangas() == 0)
            #expect(sut.errorMessage == nil)
        }

        @Test("Remove multiple mangas from collection")
        func removeMultipleMangasFromCollection() throws {
            // Given
            let manga1 = Self.sampleManga
            let manga2 = Self.sampleManga2
            try sut.addToCollection(manga1)
            try sut.addToCollection(manga2)
            #expect(sut.getTotalMangas() == 2)

            guard let collectionManga1 = sut.getCollectionManga(mangaId: manga1.id),
                  let collectionManga2 = sut.getCollectionManga(mangaId: manga2.id) else {
                Issue.record("Collection mangas should exist")
                return
            }

            // When
            try sut.removeFromCollection(collectionManga1)

            // Then
            #expect(sut.getTotalMangas() == 1)
            #expect(sut.isInCollection(mangaId: manga1.id) == false)
            #expect(sut.isInCollection(mangaId: manga2.id) == true)

            // When
            try sut.removeFromCollection(collectionManga2)

            // Then
            #expect(sut.getTotalMangas() == 0)
            #expect(sut.isInCollection(mangaId: manga2.id) == false)
        }

        // MARK: - Query Operations Tests

        @Test("isInCollection returns correct value")
        func isInCollectionReturnsCorrectValue() throws {
            // Given
            let manga = Self.sampleManga

            // When - not in collection
            let notInCollection = sut.isInCollection(mangaId: manga.id)

            // Then
            #expect(notInCollection == false)

            // When - added to collection
            try sut.addToCollection(manga)
            let inCollection = sut.isInCollection(mangaId: manga.id)

            // Then
            #expect(inCollection == true)
        }

        @Test("getCollectionManga returns correct manga")
        func getCollectionMangaReturnsCorrectManga() throws {
            // Given
            let manga1 = Self.sampleManga
            let manga2 = Self.sampleManga2
            try sut.addToCollection(manga1)
            try sut.addToCollection(manga2)

            // When
            let collectionManga1 = sut.getCollectionManga(mangaId: manga1.id)
            let collectionManga2 = sut.getCollectionManga(mangaId: manga2.id)
            let nonExistentManga = sut.getCollectionManga(mangaId: 999)

            // Then
            #expect(collectionManga1?.mangaId == manga1.id)
            #expect(collectionManga1?.title == manga1.title)
            #expect(collectionManga2?.mangaId == manga2.id)
            #expect(collectionManga2?.title == manga2.title)
            #expect(nonExistentManga == nil)
        }

        // MARK: - Statistics Tests

        @Test("getTotalMangas returns correct count")
        func getTotalMangasReturnsCorrectCount() throws {
            // Given/When - empty collection
            #expect(sut.getTotalMangas() == 0)

            // When - add one manga
            try sut.addToCollection(Self.sampleManga)
            #expect(sut.getTotalMangas() == 1)

            // When - add another manga
            try sut.addToCollection(Self.sampleManga2)
            #expect(sut.getTotalMangas() == 2)

            // When - remove one manga
            if let manga = sut.getCollectionManga(mangaId: Self.sampleManga.id) {
                try sut.removeFromCollection(manga)
            }
            #expect(sut.getTotalMangas() == 1)
        }

        @Test("getTotalVolumesOwned returns correct sum")
        func getTotalVolumesOwnedReturnsCorrectSum() throws {
            // Given/When - empty collection
            #expect(sut.getTotalVolumesOwned() == 0)

            // When - add manga with volumes
            try sut.addToCollection(Self.sampleManga)
            if let manga = sut.getCollectionManga(mangaId: Self.sampleManga.id) {
                manga.volumesOwnedCount = 10
                try sut.updateCollection(manga)
            }
            #expect(sut.getTotalVolumesOwned() == 10)

            // When - add another manga with volumes
            try sut.addToCollection(Self.sampleManga2)
            if let manga = sut.getCollectionManga(mangaId: Self.sampleManga2.id) {
                manga.volumesOwnedCount = 25
                try sut.updateCollection(manga)
            }
            #expect(sut.getTotalVolumesOwned() == 35)
        }

        @Test(
            "getTotalVolumesOwned with different volume counts",
            arguments: [
                .init(manga1Volumes: 0, manga2Volumes: 0, expectedTotal: 0),
                .init(manga1Volumes: 10, manga2Volumes: 20, expectedTotal: 30),
                .init(manga1Volumes: 72, manga2Volumes: 34, expectedTotal: 106),
                .init(manga1Volumes: 100, manga2Volumes: 50, expectedTotal: 150)
            ] as [VolumeCountArgument]
        )
        private func getTotalVolumesOwnedWithDifferentCounts(argument: VolumeCountArgument) throws {
            // Given
            try sut.addToCollection(Self.sampleManga)
            try sut.addToCollection(Self.sampleManga2)

            if let manga1 = sut.getCollectionManga(mangaId: Self.sampleManga.id) {
                manga1.volumesOwnedCount = argument.manga1Volumes
                try sut.updateCollection(manga1)
            }

            if let manga2 = sut.getCollectionManga(mangaId: Self.sampleManga2.id) {
                manga2.volumesOwnedCount = argument.manga2Volumes
                try sut.updateCollection(manga2)
            }

            // When
            let total = sut.getTotalVolumesOwned()

            // Then
            #expect(total == argument.expectedTotal)
        }

        // MARK: - Error Handling Tests

        @Test("Add to collection with nil context throws contextNotAvailable error")
        func addToCollectionFailureWithNilContext() throws {
            // Given
            let viewModel = CollectionViewModel()
            // No setModelContext called - context is nil
            let manga = Self.sampleManga

            // When
            var thrownError: Error?
            do {
                try viewModel.addToCollection(manga)
                Issue.record("Expected error to be thrown")
            } catch {
                thrownError = error
            }

            // Then
            #expect(thrownError != nil)
            if let collectionError = thrownError as? CollectionError,
               case .contextNotAvailable = collectionError {
                // Success - correct error type
            } else {
                Issue.record("Expected CollectionError.contextNotAvailable but got \(String(describing: thrownError))")
            }
            #expect(viewModel.errorMessage != nil)
            #expect(viewModel.errorMessage?.localizedCaseInsensitiveContains("context") == true)
        }

        @Test("Update collection with nil context throws contextNotAvailable error")
        func updateCollectionFailureWithNilContext() throws {
            // Given
            let manga = Self.sampleManga
            try sut.addToCollection(manga)

            guard let collectionManga = sut.getCollectionManga(mangaId: manga.id) else {
                Issue.record("Collection manga should exist")
                return
            }

            // Create new ViewModel without context
            let viewModel = CollectionViewModel()

            // When
            var thrownError: Error?
            do {
                try viewModel.updateCollection(collectionManga)
                Issue.record("Expected error to be thrown")
            } catch {
                thrownError = error
            }

            // Then
            #expect(thrownError != nil)
            if let collectionError = thrownError as? CollectionError,
               case .contextNotAvailable = collectionError {
                // Success - correct error type
            } else {
                Issue.record("Expected CollectionError.contextNotAvailable but got \(String(describing: thrownError))")
            }
            #expect(viewModel.errorMessage != nil)
            #expect(viewModel.errorMessage?.localizedCaseInsensitiveContains("context") == true)
        }

        @Test("Remove from collection with nil context throws contextNotAvailable error")
        func removeFromCollectionFailureWithNilContext() throws {
            // Given
            let manga = Self.sampleManga
            try sut.addToCollection(manga)

            guard let collectionManga = sut.getCollectionManga(mangaId: manga.id) else {
                Issue.record("Collection manga should exist")
                return
            }

            // Create new ViewModel without context
            let viewModel = CollectionViewModel()

            // When
            var thrownError: Error?
            do {
                try viewModel.removeFromCollection(collectionManga)
                Issue.record("Expected error to be thrown")
            } catch {
                thrownError = error
            }

            // Then
            #expect(thrownError != nil)
            if let collectionError = thrownError as? CollectionError,
               case .contextNotAvailable = collectionError {
                // Success - correct error type
            } else {
                Issue.record("Expected CollectionError.contextNotAvailable but got \(String(describing: thrownError))")
            }
            #expect(viewModel.errorMessage != nil)
            #expect(viewModel.errorMessage?.localizedCaseInsensitiveContains("context") == true)
        }

        @Test("Add duplicate manga throws alreadyExists error and sets error message")
        func addDuplicateMangaThrowsError() throws {
            // Given
            let manga = Self.sampleManga
            try sut.addToCollection(manga)
            #expect(sut.isInCollection(mangaId: manga.id) == true)
            #expect(sut.errorMessage == nil) // Should be nil after successful add

            // When
            var thrownError: Error?
            do {
                try sut.addToCollection(manga) // Try to add duplicate
                Issue.record("Expected error to be thrown")
            } catch {
                thrownError = error
            }

            // Then
            #expect(thrownError != nil)
            if let collectionError = thrownError as? CollectionError,
               case .alreadyExists = collectionError {
                // Success - correct error type
            } else {
                Issue.record("Expected CollectionError.alreadyExists but got \(String(describing: thrownError))")
            }
            #expect(sut.errorMessage != nil)
            #expect(sut.errorMessage?.localizedCaseInsensitiveContains("already") == true)
        }

        @Test(
            "Error messages are set correctly for different error types",
            arguments: [
                .init(error: CollectionError.contextNotAvailable, containsText: "context"),
                .init(error: CollectionError.alreadyExists, containsText: "already"),
                .init(error: CollectionError.notFound, containsText: "not found")
            ] as [ErrorMessageArgument]
        )
        private func errorMessagesSetCorrectly(argument: ErrorMessageArgument) {
            // Given
            let viewModel = CollectionViewModel()

            // When
            if let errorDescription = argument.error.errorDescription {
                viewModel.errorMessage = errorDescription
            }

            // Then
            #expect(viewModel.errorMessage != nil)
            if let errorMessage = viewModel.errorMessage {
                #expect(errorMessage.localizedCaseInsensitiveContains(argument.containsText))
            }
        }

        @Test("Error message is cleared after successful operations")
        func errorMessageClearedAfterSuccess() throws {
            // Given
            let manga = Self.sampleManga

            // When - trigger an error by not setting context
            do {
                try sut.addToCollection(manga)
                try sut.addToCollection(manga) // Try to add duplicate
            } catch {
                // Expected error - duplicate manga
            }

            // Then - error message should be set
            #expect(sut.errorMessage != nil)

            // When - perform successful operation on different manga
            let manga2 = Self.sampleManga2
            try sut.addToCollection(manga2)

            // Then - error message should be cleared after success
            #expect(sut.errorMessage == nil)
        }

        @Test("clearError clears the error message")
        func clearErrorClearsMessage() throws {
            // Given
            let manga = Self.sampleManga

            // When - trigger an error
            do {
                try sut.addToCollection(manga)
                try sut.addToCollection(manga) // Try to add duplicate
            } catch {
                // Expected error
            }

            // Then - error message should be set
            let errorBeforeClear = sut.errorMessage
            #expect(errorBeforeClear != nil)

            // When - call clearError
            sut.clearError()

            // Then - error message should be nil
            #expect(sut.errorMessage == nil)
        }
    }
}

// MARK: - Test Data

private extension CollectionTests.ViewModelTests {

    static let sampleManga = Manga(
        id: 1,
        title: "One Piece",
        titleEnglish: "One Piece",
        titleJapanese: "ワンピース",
        sypnosis: "A story about pirates and their quest for the ultimate treasure.",
        background: nil,
        mainPicture: "https://cdn.myanimelist.net/images/manga/3/216460.jpg",
        url: nil,
        volumes: 106,
        chapters: nil,
        status: "Publishing",
        score: 9.21,
        startDate: nil,
        endDate: nil,
        authors: [],
        genres: [],
        demographics: [],
        themes: []
    )

    static let sampleManga2 = Manga(
        id: 2,
        title: "Naruto",
        titleEnglish: "Naruto",
        titleJapanese: "ナルト",
        sypnosis: "A story about a young ninja seeking recognition.",
        background: nil,
        mainPicture: "https://cdn.myanimelist.net/images/manga/3/249658.jpg",
        url: nil,
        volumes: 72,
        chapters: nil,
        status: "Finished",
        score: 8.09,
        startDate: nil,
        endDate: nil,
        authors: [],
        genres: [],
        demographics: [],
        themes: []
    )
}

// MARK: - Arguments

private extension CollectionTests.ViewModelTests {

    struct UpdateCollectionArgument: CustomTestStringConvertible {
        let volumesOwned: Int
        let currentReading: Int?
        let complete: Bool

        var testDescription: String {
            "volumes: \(volumesOwned), reading: \(currentReading?.description ?? "nil"), complete: \(complete)"
        }

        init(volumesOwned: Int, currentReading: Int?, complete: Bool) {
            self.volumesOwned = volumesOwned
            self.currentReading = currentReading
            self.complete = complete
        }
    }

    struct VolumeCountArgument: CustomTestStringConvertible {
        let manga1Volumes: Int
        let manga2Volumes: Int
        let expectedTotal: Int

        var testDescription: String {
            "manga1: \(manga1Volumes), manga2: \(manga2Volumes) → total: \(expectedTotal)"
        }

        init(manga1Volumes: Int, manga2Volumes: Int, expectedTotal: Int) {
            self.manga1Volumes = manga1Volumes
            self.manga2Volumes = manga2Volumes
            self.expectedTotal = expectedTotal
        }
    }

    struct ErrorMessageArgument: CustomTestStringConvertible {
        let error: CollectionError
        let containsText: String

        var testDescription: String {
            "\(error) → expects message containing '\(containsText)'"
        }

        init(error: CollectionError, containsText: String) {
            self.error = error
            self.containsText = containsText
        }
    }
}
