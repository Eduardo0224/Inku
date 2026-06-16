//
//  WatchCollectionTests+Interactor.swift
//  InkuWatchTests
//
//  Created by Eduardo Andrade on 16/06/26.
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
@testable import InkuWatch

extension WatchCollectionTests {

    @Suite("Interactor Tests")
    struct InteractorTests {

        // MARK: - Subject Under Test

        let sut: WatchCollectionInteractor

        // MARK: - Spies

        let spySessionManager: SpyWatchSessionManager

        // MARK: - Properties

        let container: ModelContainer
        let modelContext: ModelContext

        // MARK: - Initializers

        init() throws {
            spySessionManager = SpyWatchSessionManager()
            sut = WatchCollectionInteractor(sessionManager: spySessionManager)
            let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
            container = try ModelContainer(
                for: WatchMangaItem.self,
                configurations: configuration
            )
            modelContext = container.mainContext
        }

        // MARK: - Session Configuration Tests

        @Test("configureSession stores model container")
        func configureSessionStoresContainer() throws {
            // Given
            let container = self.container

            // When
            sut.configureSession(with: container)

            // Then
            // Verify by triggering a sync — if container was stored, it won't crash
            let item = WatchMangaTransferItem(
                mangaId: 1,
                title: "Berserk",
                japaneseTitle: nil,
                score: 9.4,
                volumesOwned: 41,
                totalVolumes: 41,
                currentReadingVolume: nil,
                hasCompleteCollection: true,
                dateAdded: Date(),
                coverImageJPEGBase64: nil
            )
            // This should succeed because container is now set
            let items = [item]
            try sut.applyTransferItems(items, context: modelContext)

            // Verify it was applied by checking fetchAll
            let all = try sut.fetchAll(context: modelContext)
            #expect(all.count == 1)
            #expect(all.first?.title == "Berserk")
        }

        // MARK: - Sync From iPhone Tests

        @Test("syncFromiPhone delegates to session manager")
        func syncFromiPhoneDelegates() {
            // Given/When
            sut.syncFromiPhone()

            // Then
            #expect(spySessionManager.requestFullSyncWasCalled)
        }

        // MARK: - Registering Sync Callback Tests

        @Test("onSyncReceived callback is registered at init")
        func onSyncReceivedRegistered() {
            // Given/When — sut created in init()

            // Then
            #expect(spySessionManager.onSyncReceived != nil)
        }

        // MARK: - Fetch All Tests

        @Test("fetchAll returns empty array for empty database")
        func fetchAllEmpty() throws {
            // Given/When
            let result = try sut.fetchAll(context: modelContext)

            // Then
            #expect(result.isEmpty)
        }

        @Test("fetchAll returns sorted mangas")
        func fetchAllSorted() throws {
            // Given
            let m1 = WatchMangaItem(mangaId: 2, title: "Naruto")
            let m2 = WatchMangaItem(mangaId: 1, title: "Berserk")
            modelContext.insert(m1)
            modelContext.insert(m2)
            try modelContext.save()

            // When
            let result = try sut.fetchAll(context: modelContext)

            // Then
            #expect(result.count == 2)
            #expect(result[0].title == "Berserk")
            #expect(result[1].title == "Naruto")
        }

        // MARK: - Fetch Reading Tests

        @Test("fetchReading returns only mangas with currentReadingVolume")
        func fetchReadingFiltersCorrectly() throws {
            // Given
            let reading = WatchMangaItem(
                mangaId: 1,
                title: "One Piece",
                currentReadingVolume: 51
            )
            let notReading = WatchMangaItem(
                mangaId: 2,
                title: "Berserk",
                currentReadingVolume: nil
            )
            modelContext.insert(reading)
            modelContext.insert(notReading)
            try modelContext.save()

            // When
            let result = try sut.fetchReading(context: modelContext)

            // Then
            #expect(result.count == 1)
            #expect(result.first?.title == "One Piece")
        }

        // MARK: - Fetch Completed Tests

        @Test("fetchCompleted returns only complete collections")
        func fetchCompletedFiltersCorrectly() throws {
            // Given
            let complete = WatchMangaItem(
                mangaId: 1,
                title: "Naruto",
                volumesOwned: 72,
                totalVolumes: 72,
                hasCompleteCollection: true
            )
            let incomplete = WatchMangaItem(
                mangaId: 2,
                title: "One Piece",
                volumesOwned: 50,
                totalVolumes: 106,
                hasCompleteCollection: false
            )
            modelContext.insert(complete)
            modelContext.insert(incomplete)
            try modelContext.save()

            // When
            let result = try sut.fetchCompleted(context: modelContext)

            // Then
            #expect(result.count == 1)
            #expect(result.first?.title == "Naruto")
        }

        // MARK: - Apply Transfer Items Tests

        @Test("applyTransferItems inserts new items")
        func applyTransferItemsInserts() throws {
            // Given
            let item = WatchMangaTransferItem(
                mangaId: 1,
                title: "Berserk",
                japaneseTitle: "ベルセルク",
                score: 9.4,
                volumesOwned: 41,
                totalVolumes: 41,
                currentReadingVolume: nil,
                hasCompleteCollection: true,
                dateAdded: Date(),
                coverImageJPEGBase64: nil
            )

            // When
            try sut.applyTransferItems([item], context: modelContext)

            // Then
            let all = try sut.fetchAll(context: modelContext)
            #expect(all.count == 1)
            #expect(all.first?.title == "Berserk")
            #expect(all.first?.score == 9.4)
            #expect(all.first?.volumesOwned == 41)
        }

        @Test("applyTransferItems updates existing items")
        func applyTransferItemsUpdates() throws {
            // Given — existing item
            let existing = WatchMangaItem(mangaId: 1, title: "Old Title", volumesOwned: 5)
            modelContext.insert(existing)
            try modelContext.save()

            // When — transfer item with same mangaId
            let updated = WatchMangaTransferItem(
                mangaId: 1,
                title: "Berserk",
                japaneseTitle: nil,
                score: 9.4,
                volumesOwned: 41,
                totalVolumes: 41,
                currentReadingVolume: nil,
                hasCompleteCollection: true,
                dateAdded: Date(),
                coverImageJPEGBase64: nil
            )
            try sut.applyTransferItems([updated], context: modelContext)

            // Then
            let all = try sut.fetchAll(context: modelContext)
            #expect(all.count == 1)
            #expect(all.first?.title == "Berserk")
            #expect(all.first?.volumesOwned == 41)
        }

        @Test("applyTransferItems removes items not in transfer set")
        func applyTransferItemsRemovesStale() throws {
            // Given — existing items
            let m1 = WatchMangaItem(mangaId: 1, title: "Keep")
            let m2 = WatchMangaItem(mangaId: 2, title: "Delete")
            modelContext.insert(m1)
            modelContext.insert(m2)
            try modelContext.save()
            #expect(try sut.fetchAll(context: modelContext).count == 2)

            // When — transfer only contains mangaId 1
            let item = WatchMangaTransferItem(
                mangaId: 1,
                title: "Keep",
                japaneseTitle: nil,
                score: nil,
                volumesOwned: 10,
                totalVolumes: nil,
                currentReadingVolume: nil,
                hasCompleteCollection: false,
                dateAdded: Date(),
                coverImageJPEGBase64: nil
            )
            try sut.applyTransferItems([item], context: modelContext)

            // Then
            let all = try sut.fetchAll(context: modelContext)
            #expect(all.count == 1)
            #expect(all.first?.title == "Keep")
        }
    }
}
