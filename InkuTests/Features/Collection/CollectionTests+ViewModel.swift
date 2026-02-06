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
            #expect(sut.totalMangas == 1)

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
            #expect(sut.totalMangas == 2)
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
            #expect(sut.totalMangas == 0)
            #expect(sut.errorMessage == nil)
        }

        @Test("Remove multiple mangas from collection")
        func removeMultipleMangasFromCollection() throws {
            // Given
            let manga1 = Self.sampleManga
            let manga2 = Self.sampleManga2
            try sut.addToCollection(manga1)
            try sut.addToCollection(manga2)
            #expect(sut.totalMangas == 2)

            guard let collectionManga1 = sut.getCollectionManga(mangaId: manga1.id),
                  let collectionManga2 = sut.getCollectionManga(mangaId: manga2.id) else {
                Issue.record("Collection mangas should exist")
                return
            }

            // When
            try sut.removeFromCollection(collectionManga1)

            // Then
            #expect(sut.totalMangas == 1)
            #expect(sut.isInCollection(mangaId: manga1.id) == false)
            #expect(sut.isInCollection(mangaId: manga2.id) == true)

            // When
            try sut.removeFromCollection(collectionManga2)

            // Then
            #expect(sut.totalMangas == 0)
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

        @Test("totalMangas returns correct count")
        func totalMangasReturnsCorrectCount() throws {
            // Given/When - empty collection
            #expect(sut.totalMangas == 0)

            // When - add one manga
            try sut.addToCollection(Self.sampleManga)
            #expect(sut.totalMangas == 1)

            // When - add another manga
            try sut.addToCollection(Self.sampleManga2)
            #expect(sut.totalMangas == 2)

            // When - remove one manga
            if let manga = sut.getCollectionManga(mangaId: Self.sampleManga.id) {
                try sut.removeFromCollection(manga)
            }
            #expect(sut.totalMangas == 1)
        }

        @Test("totalVolumesOwned returns correct sum")
        func totalVolumesOwnedReturnsCorrectSum() throws {
            // Given/When - empty collection
            #expect(sut.totalVolumesOwned == 0)

            // When - add manga with volumes
            try sut.addToCollection(Self.sampleManga)
            if let manga = sut.getCollectionManga(mangaId: Self.sampleManga.id) {
                manga.volumesOwnedCount = 10
                try sut.updateCollection(manga)
            }
            #expect(sut.totalVolumesOwned == 10)

            // When - add another manga with volumes
            try sut.addToCollection(Self.sampleManga2)
            if let manga = sut.getCollectionManga(mangaId: Self.sampleManga2.id) {
                manga.volumesOwnedCount = 25
                try sut.updateCollection(manga)
            }
            #expect(sut.totalVolumesOwned == 35)
        }

        @Test(
            "totalVolumesOwned with different volume counts",
            arguments: [
                .init(manga1Volumes: 0, manga2Volumes: 0, expectedTotal: 0),
                .init(manga1Volumes: 10, manga2Volumes: 20, expectedTotal: 30),
                .init(manga1Volumes: 72, manga2Volumes: 34, expectedTotal: 106),
                .init(manga1Volumes: 100, manga2Volumes: 50, expectedTotal: 150)
            ] as [VolumeCountArgument]
        )
        private func totalVolumesOwnedWithDifferentCounts(argument: VolumeCountArgument) throws {
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
            let total = sut.totalVolumesOwned

            // Then
            #expect(total == argument.expectedTotal)
        }

        @Test("completedCount returns correct count")
        func completedCountReturnsCorrectCount() throws {
            // Given/When - empty collection
            #expect(sut.completedCount == 0)

            // When - add manga that is not complete
            try sut.addToCollection(Self.sampleManga)
            if let manga = sut.getCollectionManga(mangaId: Self.sampleManga.id) {
                manga.volumesOwnedCount = 10
                manga.hasCompleteCollection = false
                try sut.updateCollection(manga)
            }
            #expect(sut.completedCount == 0)

            // When - mark as complete
            if let manga = sut.getCollectionManga(mangaId: Self.sampleManga.id) {
                manga.hasCompleteCollection = true
                try sut.updateCollection(manga)
            }
            #expect(sut.completedCount == 1)

            // When - add another complete manga
            try sut.addToCollection(Self.sampleManga2)
            if let manga = sut.getCollectionManga(mangaId: Self.sampleManga2.id) {
                manga.volumesOwnedCount = 72
                manga.hasCompleteCollection = true
                try sut.updateCollection(manga)
            }
            #expect(sut.completedCount == 2)
        }

        @Test("readingCount returns correct count")
        func readingCountReturnsCorrectCount() throws {
            // Given/When - empty collection
            #expect(sut.readingCount == 0)

            // When - add manga without current reading volume
            try sut.addToCollection(Self.sampleManga)
            #expect(sut.readingCount == 0)

            // When - set current reading volume
            if let manga = sut.getCollectionManga(mangaId: Self.sampleManga.id) {
                manga.currentReadingVolume = 25
                try sut.updateCollection(manga)
            }
            #expect(sut.readingCount == 1)

            // When - add another manga that is being read
            try sut.addToCollection(Self.sampleManga2)
            if let manga = sut.getCollectionManga(mangaId: Self.sampleManga2.id) {
                manga.currentReadingVolume = 50
                try sut.updateCollection(manga)
            }
            #expect(sut.readingCount == 2)

            // When - remove reading status from one manga
            if let manga = sut.getCollectionManga(mangaId: Self.sampleManga.id) {
                manga.currentReadingVolume = nil
                try sut.updateCollection(manga)
            }
            #expect(sut.readingCount == 1)
        }

        @Test("averageProgress returns correct value")
        func averageProgressReturnsCorrectValue() throws {
            // Given/When - empty collection
            #expect(sut.averageProgress == 0.0)

            // When - add manga with no total volumes (progress is nil)
            try sut.addToCollection(Self.sampleManga)
            if let manga = sut.getCollectionManga(mangaId: Self.sampleManga.id) {
                manga.totalVolumes = nil
                manga.volumesOwnedCount = 10
                try sut.updateCollection(manga)
            }
            #expect(sut.averageProgress == 0.0)

            // When - set total volumes (now has progress)
            if let manga = sut.getCollectionManga(mangaId: Self.sampleManga.id) {
                manga.totalVolumes = 100
                manga.volumesOwnedCount = 50
                try sut.updateCollection(manga)
            }
            #expect(sut.averageProgress == 0.5) // 50/100 = 0.5

            // When - add another manga with different progress
            try sut.addToCollection(Self.sampleManga2)
            if let manga = sut.getCollectionManga(mangaId: Self.sampleManga2.id) {
                manga.totalVolumes = 72
                manga.volumesOwnedCount = 72
                try sut.updateCollection(manga)
            }
            // Average: (0.5 + 1.0) / 2 = 0.75
            #expect(sut.averageProgress == 0.75)
        }

        @Test(
            "averageProgress with different values",
            arguments: [
                .init(manga1Progress: (owned: 25, total: 100), manga2Progress: (owned: 50, total: 100), expectedAverage: 0.375),
                .init(manga1Progress: (owned: 10, total: 20), manga2Progress: (owned: 30, total: 60), expectedAverage: 0.5),
                .init(manga1Progress: (owned: 100, total: 100), manga2Progress: (owned: 100, total: 100), expectedAverage: 1.0),
                .init(manga1Progress: (owned: 0, total: 50), manga2Progress: (owned: 25, total: 50), expectedAverage: 0.25)
            ] as [AverageProgressArgument]
        )
        private func averageProgressWithDifferentValues(argument: AverageProgressArgument) throws {
            // Given
            try sut.addToCollection(Self.sampleManga)
            try sut.addToCollection(Self.sampleManga2)

            if let manga1 = sut.getCollectionManga(mangaId: Self.sampleManga.id) {
                manga1.totalVolumes = argument.manga1Progress.total
                manga1.volumesOwnedCount = argument.manga1Progress.owned
                try sut.updateCollection(manga1)
            }

            if let manga2 = sut.getCollectionManga(mangaId: Self.sampleManga2.id) {
                manga2.totalVolumes = argument.manga2Progress.total
                manga2.volumesOwnedCount = argument.manga2Progress.owned
                try sut.updateCollection(manga2)
            }

            // When
            let average = sut.averageProgress

            // Then
            #expect(abs(average - argument.expectedAverage) < 0.001)
        }

        @Test("completionPercentage returns correct value")
        func completionPercentageReturnsCorrectValue() throws {
            // Given/When - empty collection
            #expect(sut.completionPercentage == 0.0)

            // When - add one manga (not complete)
            try sut.addToCollection(Self.sampleManga)
            #expect(sut.completionPercentage == 0.0) // 0/1 = 0.0

            // When - mark as complete
            if let manga = sut.getCollectionManga(mangaId: Self.sampleManga.id) {
                manga.hasCompleteCollection = true
                try sut.updateCollection(manga)
            }
            #expect(sut.completionPercentage == 1.0) // 1/1 = 1.0

            // When - add another manga (not complete)
            try sut.addToCollection(Self.sampleManga2)
            #expect(sut.completionPercentage == 0.5) // 1/2 = 0.5

            // When - mark second manga as complete
            if let manga = sut.getCollectionManga(mangaId: Self.sampleManga2.id) {
                manga.hasCompleteCollection = true
                try sut.updateCollection(manga)
            }
            #expect(sut.completionPercentage == 1.0) // 2/2 = 1.0
        }

        @Test("getTopSeriesByVolumes returns correct mangas in order")
        func getTopSeriesByVolumesReturnsCorrectOrder() throws {
            // Given - add multiple mangas with different volume counts
            let manga1 = Self.sampleManga
            let manga2 = Self.sampleManga2
            let manga3 = Manga(
                id: 3,
                title: "Attack on Titan",
                titleEnglish: "Attack on Titan",
                titleJapanese: "進撃の巨人",
                sypnosis: "Humanity fights against titans.",
                background: nil,
                mainPicture: "https://cdn.myanimelist.net/images/manga/2/37846.jpg",
                url: nil,
                volumes: 34,
                chapters: nil,
                status: "Finished",
                score: 8.54,
                startDate: nil,
                endDate: nil,
                authors: [],
                genres: [],
                demographics: [],
                themes: []
            )

            try sut.addToCollection(manga1)
            try sut.addToCollection(manga2)
            try sut.addToCollection(manga3)

            // Set different volume counts
            if let m1 = sut.getCollectionManga(mangaId: manga1.id) {
                m1.volumesOwnedCount = 50
                try sut.updateCollection(m1)
            }
            if let m2 = sut.getCollectionManga(mangaId: manga2.id) {
                m2.volumesOwnedCount = 72
                try sut.updateCollection(m2)
            }
            if let m3 = sut.getCollectionManga(mangaId: manga3.id) {
                m3.volumesOwnedCount = 34
                try sut.updateCollection(m3)
            }

            // When
            let topSeries = sut.getTopSeriesByVolumes(limit: 3)

            // Then
            #expect(topSeries.count == 3)
            #expect(topSeries[0].mangaId == manga2.id) // 72 volumes
            #expect(topSeries[1].mangaId == manga1.id) // 50 volumes
            #expect(topSeries[2].mangaId == manga3.id) // 34 volumes
        }

        @Test("getTopSeriesByVolumes respects limit")
        func getTopSeriesByVolumesRespectsLimit() throws {
            // Given - add 3 mangas
            try sut.addToCollection(Self.sampleManga)
            try sut.addToCollection(Self.sampleManga2)

            // When - request only 1
            let topSeries = sut.getTopSeriesByVolumes(limit: 1)

            // Then
            #expect(topSeries.count == 1)
        }

        @Test("getMostRecentlyAdded returns correct mangas in order")
        func getMostRecentlyAddedReturnsCorrectOrder() throws {
            // Given - add mangas with delays to ensure different dateAdded
            try sut.addToCollection(Self.sampleManga)
            Thread.sleep(forTimeInterval: 0.01)

            try sut.addToCollection(Self.sampleManga2)
            Thread.sleep(forTimeInterval: 0.01)

            let manga3 = Manga(
                id: 3,
                title: "Death Note",
                titleEnglish: "Death Note",
                titleJapanese: "デスノート",
                sypnosis: "A notebook that kills.",
                background: nil,
                mainPicture: "https://cdn.myanimelist.net/images/manga/2/253119.jpg",
                url: nil,
                volumes: 12,
                chapters: nil,
                status: "Finished",
                score: 8.71,
                startDate: nil,
                endDate: nil,
                authors: [],
                genres: [],
                demographics: [],
                themes: []
            )
            try sut.addToCollection(manga3)

            // When
            let recentlyAdded = sut.getMostRecentlyAdded(limit: 3)

            // Then
            #expect(recentlyAdded.count == 3)
            #expect(recentlyAdded[0].mangaId == manga3.id) // Most recent
            #expect(recentlyAdded[1].mangaId == Self.sampleManga2.id)
            #expect(recentlyAdded[2].mangaId == Self.sampleManga.id) // Oldest
        }

        @Test("getMostRecentlyAdded respects limit")
        func getMostRecentlyAddedRespectsLimit() throws {
            // Given
            try sut.addToCollection(Self.sampleManga)
            try sut.addToCollection(Self.sampleManga2)

            // When
            let recentlyAdded = sut.getMostRecentlyAdded(limit: 1)

            // Then
            #expect(recentlyAdded.count == 1)
            #expect(recentlyAdded[0].mangaId == Self.sampleManga2.id) // Most recent
        }

        @Test("getMostRecentlyModified returns correct mangas in order")
        func getMostRecentlyModifiedReturnsCorrectOrder() throws {
            // Given - add mangas
            try sut.addToCollection(Self.sampleManga)
            try sut.addToCollection(Self.sampleManga2)

            // When - modify first manga
            Thread.sleep(forTimeInterval: 0.01)
            if let manga1 = sut.getCollectionManga(mangaId: Self.sampleManga.id) {
                manga1.volumesOwnedCount = 10
                try sut.updateCollection(manga1)
            }

            Thread.sleep(forTimeInterval: 0.01)
            if let manga2 = sut.getCollectionManga(mangaId: Self.sampleManga2.id) {
                manga2.volumesOwnedCount = 20
                try sut.updateCollection(manga2)
            }

            // When
            let recentlyModified = sut.getMostRecentlyModified(limit: 2)

            // Then
            #expect(recentlyModified.count == 2)
            #expect(recentlyModified[0].mangaId == Self.sampleManga2.id) // Most recently modified
            #expect(recentlyModified[1].mangaId == Self.sampleManga.id)
        }

        @Test("getMostRecentlyModified respects limit")
        func getMostRecentlyModifiedRespectsLimit() throws {
            // Given
            try sut.addToCollection(Self.sampleManga)
            try sut.addToCollection(Self.sampleManga2)

            if let manga = sut.getCollectionManga(mangaId: Self.sampleManga.id) {
                manga.volumesOwnedCount = 10
                try sut.updateCollection(manga)
            }

            // When
            let recentlyModified = sut.getMostRecentlyModified(limit: 1)

            // Then
            #expect(recentlyModified.count == 1)
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
            #expect(viewModel.errorMessage == CollectionError.contextNotAvailable.errorDescription)
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
            #expect(viewModel.errorMessage == CollectionError.contextNotAvailable.errorDescription)
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
            #expect(viewModel.errorMessage == CollectionError.contextNotAvailable.errorDescription)
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
            // Verify error message matches the expected localized error description
            #expect(sut.errorMessage == CollectionError.alreadyExists.errorDescription)
        }

        @Test(
            "Error messages are set correctly for different error types",
            arguments: [
                CollectionError.contextNotAvailable,
                CollectionError.alreadyExists,
                CollectionError.notFound
            ]
        )
        private func errorMessagesSetCorrectly(error: CollectionError) {
            // Given
            let viewModel = CollectionViewModel()

            // When
            if let errorDescription = error.errorDescription {
                viewModel.errorMessage = errorDescription
            }

            // Then
            #expect(viewModel.errorMessage != nil)
            #expect(viewModel.errorMessage == error.errorDescription)
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

        // MARK: - Cloud Sync Tests

        @Test("Add cloud mangas to local - new mangas")
        func addCloudMangasToLocalNew() throws {
            // Given
            try sut.addCloudMangasToLocal([Self.cloudManga1])
            #expect(sut.totalMangas == 1)
            // When
            let addedManga = sut.getCollectionManga(mangaId: Manga.testData.id)
            // Then
            #expect(addedManga != nil)
            #expect(addedManga?.volumesOwnedCount == 3)
        }

        @Test("Add cloud mangas to local - update existing")
        func addCloudMangasToLocalUpdate() throws {
            // Given
            let manga: Manga = .testData
            try sut.addToCollection(manga)
            let localManga = sut.getCollectionManga(mangaId: manga.id)
            #expect(localManga?.volumesOwnedCount == 0)
            try sut.addCloudMangasToLocal([Self.cloudManga(basedOn: manga)])
            #expect(sut.totalMangas == 1)
            // When
            let updatedManga = sut.getCollectionManga(mangaId: manga.id)
            // Then
            #expect(updatedManga?.volumesOwnedCount == 5)
            #expect(updatedManga?.currentReadingVolume == 5)
            #expect(updatedManga?.hasCompleteCollection == true)
        }

        @Test("Get all local mangas returns correct count")
        func getAllLocalMangas() throws {
            // Given
            try sut.addToCollection(.testData)
            try sut.addToCollection(.emptyData)
            // When
            let localMangas = try sut.getAllLocalMangas()
            // Then
            #expect(localMangas.count == 2)
        }

        @Test("Get local manga IDs returns correct set")
        func getLocalMangaIds() throws {
            // Given
            try sut.addToCollection(.testData)
            try sut.addToCollection(.emptyData)
            // When
            let ids = try sut.getLocalMangaIds()
            // Then
            #expect(ids.count == 2)
            #expect(ids.contains(Manga.testData.id))
            #expect(ids.contains(Manga.emptyData.id))
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

    static let cloudManga1 = CloudCollectionManga(
        id: "cloud_1",
        manga: .testData,
        user: .init(id: "user_1"),
        completeCollection: false,
        volumesOwned: [1, 2, 3],
        readingVolume: 3
    )

    static func cloudManga(basedOn manga: Manga) -> CloudCollectionManga {
        .init(
            id: "cloud_1",
            manga: manga,
            user: CloudCollectionManga.UserInfo(id: "user_1"),
            completeCollection: true,
            volumesOwned: [1, 2, 3, 4, 5],
            readingVolume: 5
        )
    }
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

    struct AverageProgressArgument: CustomTestStringConvertible {
        let manga1Progress: (owned: Int, total: Int)
        let manga2Progress: (owned: Int, total: Int)
        let expectedAverage: Double

        var testDescription: String {
            "manga1: \(manga1Progress.owned)/\(manga1Progress.total), manga2: \(manga2Progress.owned)/\(manga2Progress.total) → avg: \(expectedAverage)"
        }

        init(manga1Progress: (owned: Int, total: Int), manga2Progress: (owned: Int, total: Int), expectedAverage: Double) {
            self.manga1Progress = manga1Progress
            self.manga2Progress = manga2Progress
            self.expectedAverage = expectedAverage
        }
    }
}
