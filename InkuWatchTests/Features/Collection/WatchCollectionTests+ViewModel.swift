//
//  WatchCollectionTests+ViewModel.swift
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

    @Suite("ViewModel Tests")
    @MainActor
    struct ViewModelTests {

        // MARK: - Subject Under Test

        let sut: WatchCollectionViewModel

        // MARK: - Spies

        let spyInteractor: SpyWatchCollectionInteractor
        let spySessionManager: SpyWatchSessionManager

        // MARK: - Properties

        let container: ModelContainer
        let modelContext: ModelContext

        // MARK: - Initializers

        init() throws {
            spySessionManager = SpyWatchSessionManager()
            spyInteractor = SpyWatchCollectionInteractor()
            let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
            container = try ModelContainer(
                for: WatchMangaItem.self,
                configurations: configuration
            )
            modelContext = container.mainContext
            sut = WatchCollectionViewModel(interactor: spyInteractor)
            sut.setModelContext(modelContext)
        }

        // MARK: - Initialization Tests

        @Test("ViewModel initializes with correct initial state")
        func initialStateIsCorrect() {
            // Given/When — sut created in init()

            // Then
            #expect(sut.allMangas.isEmpty)
            #expect(sut.nowReading.isEmpty)
            #expect(sut.completed.isEmpty)
            #expect(sut.totalMangas == 0)
            #expect(sut.totalVolumesOwned == 0)
            #expect(sut.completedCount == 0)
            #expect(sut.readingCount == 0)
            #expect(sut.averageProgress == 0.0)
            #expect(sut.completionPercentage == 0.0)
        }

        // MARK: - Load Mangas Tests

        @Test("loadMangas populates all arrays from SwiftData")
        func loadMangasSuccess() throws {
            // Given — insert data directly into in-memory store
            let sampleManga = WatchMangaItem(
                mangaId: 1,
                title: "Berserk",
                volumesOwned: 41,
                totalVolumes: 41,
                hasCompleteCollection: true
            )
            let readingManga = WatchMangaItem(
                mangaId: 2,
                title: "One Piece",
                volumesOwned: 50,
                totalVolumes: 106,
                currentReadingVolume: 51,
                hasCompleteCollection: false
            )
            modelContext.insert(sampleManga)
            modelContext.insert(readingManga)
            try modelContext.save()

            // When
            sut.loadMangas(context: modelContext)

            // Then
            #expect(sut.allMangas.count == 2)
            #expect(sut.nowReading.count == 1)
            #expect(sut.completed.count == 1)
            #expect(sut.nowReading.first?.title == "One Piece")
            #expect(sut.completed.first?.title == "Berserk")
        }

        @Test("loadMangas handles empty collection")
        func loadMangasEmpty() {
            // Given — nothing inserted

            // When
            sut.loadMangas(context: modelContext)

            // Then
            #expect(sut.allMangas.isEmpty)
            #expect(sut.nowReading.isEmpty)
            #expect(sut.completed.isEmpty)
        }

        // MARK: - Configure Session Tests

        @Test("startReceivingSync delegates to interactor")
        func startReceivingSyncDelegatesToInteractor() {
            // Given/When
            sut.startReceivingSync()

            // Then
            #expect(spyInteractor.startReceivingSyncWasCalled)
        }

        // MARK: - Sync From iPhone Tests

        @Test("syncFromiPhone delegates to interactor")
        func syncFromiPhoneDelegatesToInteractor() {
            // Given/When
            sut.syncFromiPhone()

            // Then
            #expect(spyInteractor.syncFromiPhoneWasCalled)
        }

        // MARK: - Check Simulator Sync Tests

        @Test("checkSimulatorSync applies items and reloads mangas")
        func checkSimulatorSyncSuccess() throws {
            // Given
            let item = WatchMangaTransferItem(
                mangaId: 1,
                title: "Naruto",
                volumesOwned: 72,
                totalVolumes: 72,
                hasCompleteCollection: true
            )
            spyInteractor.simulatorItemsToReturn = [item]

            // When
            sut.checkSimulatorSync(context: modelContext)

            // Then
            #expect(spyInteractor.loadSimulatorTransferItemsWasCalled)
            #expect(sut.allMangas.count == 1)
            #expect(sut.allMangas.first?.title == "Naruto")
            #expect(sut.completed.count == 1)
        }

        @Test("checkSimulatorSync does nothing when no items returned")
        func checkSimulatorSyncEmpty() throws {
            // Given
            spyInteractor.simulatorItemsToReturn = []

            // When
            sut.checkSimulatorSync(context: modelContext)

            // Then
            #expect(spyInteractor.loadSimulatorTransferItemsWasCalled)
            #expect(sut.allMangas.isEmpty)
        }

        // MARK: - Statistics Tests

        @Test("totalMangas returns correct count after load")
        func totalMangasAfterLoad() throws {
            // Given
            let mangas = (1...3).map { i in
                WatchMangaItem(mangaId: i, title: "Manga \(i)")
            }
            for m in mangas { modelContext.insert(m) }
            try modelContext.save()

            // When
            sut.loadMangas(context: modelContext)

            // Then
            #expect(sut.totalMangas == 3)
        }

        @Test("totalVolumesOwned sums correctly")
        func totalVolumesOwnedSum() throws {
            // Given
            modelContext.insert(WatchMangaItem(mangaId: 1, title: "A", volumesOwned: 10))
            modelContext.insert(WatchMangaItem(mangaId: 2, title: "B", volumesOwned: 25))
            modelContext.insert(WatchMangaItem(mangaId: 3, title: "C", volumesOwned: 50))
            try modelContext.save()

            // When
            sut.loadMangas(context: modelContext)

            // Then
            #expect(sut.totalVolumesOwned == 85)
        }

        @Test("completedCount returns correct number")
        func completedCountCorrect() throws {
            // Given
            modelContext.insert(WatchMangaItem(
                mangaId: 1, title: "A",
                volumesOwned: 10, totalVolumes: 10,
                hasCompleteCollection: true
            ))
            try modelContext.save()

            // When
            sut.loadMangas(context: modelContext)

            // Then
            #expect(sut.completedCount == 1)
        }

        @Test("readingCount returns correct number")
        func readingCountCorrect() throws {
            // Given
            modelContext.insert(WatchMangaItem(
                mangaId: 1, title: "A",
                currentReadingVolume: 51
            ))
            try modelContext.save()

            // When
            sut.loadMangas(context: modelContext)

            // Then
            #expect(sut.readingCount == 1)
        }

        @Test("averageProgress computes correctly")
        func averageProgressComputesCorrectly() throws {
            // Given
            modelContext.insert(WatchMangaItem(
                mangaId: 1, title: "A",
                volumesOwned: 50, totalVolumes: 100
            ))
            modelContext.insert(WatchMangaItem(
                mangaId: 2, title: "B",
                volumesOwned: 72, totalVolumes: 72
            ))
            try modelContext.save()

            // When
            sut.loadMangas(context: modelContext)

            // Then
            // m1: 50/100 = 0.5, m2: 72/72 = 1.0, avg: 0.75
            #expect(sut.averageProgress == 0.75)
        }

        @Test("completionPercentage computes correctly")
        func completionPercentageComputesCorrectly() throws {
            // Given
            modelContext.insert(WatchMangaItem(
                mangaId: 1, title: "A",
                volumesOwned: 41, totalVolumes: 41,
                hasCompleteCollection: true
            ))
            modelContext.insert(WatchMangaItem(
                mangaId: 2, title: "B",
                volumesOwned: 50, totalVolumes: 106,
                hasCompleteCollection: false
            ))
            try modelContext.save()

            // When
            sut.loadMangas(context: modelContext)

            // Then
            // 1/2 = 0.5
            #expect(sut.completionPercentage == 0.5)
        }

        // MARK: - Error Handling Tests

        @Test("clearError sets errorMessage to nil")
        func clearErrorClearsMessage() {
            // Given — no error initially
            #expect(sut.errorMessage == nil)

            // When
            sut.clearError()

            // Then
            #expect(sut.errorMessage == nil)
        }

        // MARK: - Incoming Sync Tests

        @Test("incoming sync callback is wired at init")
        func onSyncReceivedIsWired() {
            // Given/When — sut created in init()

            // Then — the ViewModel should have registered its callback
            #expect(spyInteractor.onSyncReceived != nil,
                    "ViewModel should register onSyncReceived on interactor")
        }

        @Test("incoming sync applies items and reloads UI")
        func incomingSyncAppliesAndReloads() throws {
            // Given
            let item = WatchMangaTransferItem(
                mangaId: 1,
                title: "Berserk",
                volumesOwned: 41,
                totalVolumes: 41,
                hasCompleteCollection: true
            )

            // When — simulate the Interactor calling the ViewModel's callback
            spyInteractor.onSyncReceived?([item])

            // Then — data should be persisted and arrays updated
            #expect(sut.allMangas.count == 1)
            #expect(sut.allMangas.first?.title == "Berserk")
            #expect(sut.completed.count == 1)
        }
    }
}

// MARK: - Test Data

private extension WatchCollectionTests.ViewModelTests {

    static let sampleManga = WatchMangaItem(
        mangaId: 1,
        title: "One Piece",
        japaneseTitle: "ワンピース",
        score: 9.21,
        volumesOwned: 50,
        totalVolumes: 106,
        currentReadingVolume: 51,
        hasCompleteCollection: false
    )

    static let sampleTransferItem = WatchMangaTransferItem(
        mangaId: 1,
        title: "One Piece",
        japaneseTitle: "ワンピース",
        score: 9.21,
        volumesOwned: 50,
        totalVolumes: 106,
        currentReadingVolume: 51,
        hasCompleteCollection: false,
        dateAdded: Date(),
        coverImageJPEGBase64: nil
    )
}
