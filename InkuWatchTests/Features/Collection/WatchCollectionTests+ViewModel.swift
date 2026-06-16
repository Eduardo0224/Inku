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

        @Test("loadMangas populates all arrays successfully")
        func loadMangasSuccess() throws {
            // Given
            let sampleManga = WatchMangaItem(
                mangaId: 1,
                title: "Berserk",
                volumesOwned: 41,
                totalVolumes: 41,
                currentReadingVolume: nil,
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

            spyInteractor.allMangasToReturn = [sampleManga, readingManga]
            spyInteractor.readingMangasToReturn = [readingManga]
            spyInteractor.completedMangasToReturn = [sampleManga]

            // When
            sut.loadMangas(context: modelContext)

            // Then
            #expect(spyInteractor.fetchAllWasCalled)
            #expect(spyInteractor.fetchReadingWasCalled)
            #expect(spyInteractor.fetchCompletedWasCalled)
            #expect(sut.allMangas.count == 2)
            #expect(sut.nowReading.count == 1)
            #expect(sut.completed.count == 1)
        }

        @Test("loadMangas handles empty collection")
        func loadMangasEmpty() {
            // Given
            spyInteractor.allMangasToReturn = []
            spyInteractor.readingMangasToReturn = []
            spyInteractor.completedMangasToReturn = []

            // When
            sut.loadMangas(context: modelContext)

            // Then
            #expect(sut.allMangas.isEmpty)
            #expect(sut.nowReading.isEmpty)
            #expect(sut.completed.isEmpty)
        }

        // MARK: - Configure Session Tests

        @Test("configureSession delegates to interactor")
        func configureSessionDelegatesToInteractor() {
            // Given
            let container = self.container

            // When
            sut.configureSession(with: container)

            // Then
            #expect(spyInteractor.configureSessionWasCalled)
            #expect(spyInteractor.lastConfigureSessionContainer === container)
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

        @Test("checkSimulatorSync succeeds and reloads mangas")
        func checkSimulatorSyncSuccess() throws {
            // Given
            let sampleManga = WatchMangaItem(
                mangaId: 1,
                title: "Naruto",
                volumesOwned: 72,
                totalVolumes: 72,
                hasCompleteCollection: true
            )
            spyInteractor.allMangasToReturn = [sampleManga]

            // When
            sut.checkSimulatorSync(context: modelContext)

            // Then
            #expect(spyInteractor.checkSimulatorSyncWasCalled)
            #expect(spyInteractor.lastCheckSimulatorSyncContext === modelContext)
            #expect(spyInteractor.fetchAllWasCalled)
        }

        // MARK: - Statistics Tests

        @Test("totalMangas returns correct count after load")
        func totalMangasAfterLoad() {
            // Given
            let mangas = [
                WatchMangaItem(mangaId: 1, title: "A"),
                WatchMangaItem(mangaId: 2, title: "B"),
                WatchMangaItem(mangaId: 3, title: "C"),
            ]
            spyInteractor.allMangasToReturn = mangas

            // When
            sut.loadMangas(context: modelContext)

            // Then
            #expect(sut.totalMangas == 3)
        }

        @Test("totalVolumesOwned sums correctly")
        func totalVolumesOwnedSum() {
            // Given
            let m1 = WatchMangaItem(mangaId: 1, title: "A", volumesOwned: 10)
            let m2 = WatchMangaItem(mangaId: 2, title: "B", volumesOwned: 25)
            let m3 = WatchMangaItem(mangaId: 3, title: "C", volumesOwned: 50)
            spyInteractor.allMangasToReturn = [m1, m2, m3]

            // When
            sut.loadMangas(context: modelContext)

            // Then
            #expect(sut.totalVolumesOwned == 85)
        }

        @Test("completedCount returns correct number")
        func completedCountCorrect() {
            // Given
            let complete = WatchMangaItem(
                mangaId: 1,
                title: "A",
                volumesOwned: 10,
                totalVolumes: 10,
                hasCompleteCollection: true
            )
            spyInteractor.completedMangasToReturn = [complete]

            // When
            sut.loadMangas(context: modelContext)

            // Then
            #expect(sut.completedCount == 1)
        }

        @Test("readingCount returns correct number")
        func readingCountCorrect() {
            // Given
            let reading = WatchMangaItem(
                mangaId: 1,
                title: "A",
                currentReadingVolume: 51
            )
            spyInteractor.readingMangasToReturn = [reading]

            // When
            sut.loadMangas(context: modelContext)

            // Then
            #expect(sut.readingCount == 1)
        }

        @Test("averageProgress computes correctly")
        func averageProgressComputesCorrectly() {
            // Given
            let m1 = WatchMangaItem(mangaId: 1, title: "A", volumesOwned: 50, totalVolumes: 100)
            let m2 = WatchMangaItem(mangaId: 2, title: "B", volumesOwned: 72, totalVolumes: 72)
            spyInteractor.allMangasToReturn = [m1, m2]

            // When
            sut.loadMangas(context: modelContext)

            // Then
            // m1: 50/100 = 0.5, m2: 72/72 = 1.0, avg: 0.75
            #expect(sut.averageProgress == 0.75)
        }

        @Test("completionPercentage computes correctly")
        func completionPercentageComputesCorrectly() {
            // Given
            let complete = WatchMangaItem(
                mangaId: 1,
                title: "A",
                volumesOwned: 41,
                totalVolumes: 41,
                hasCompleteCollection: true
            )
            let incomplete = WatchMangaItem(
                mangaId: 2,
                title: "B",
                volumesOwned: 50,
                totalVolumes: 106,
                hasCompleteCollection: false
            )
            spyInteractor.allMangasToReturn = [complete, incomplete]

            // When
            sut.loadMangas(context: modelContext)

            // Then
            // 1/2 = 0.5
            #expect(sut.completionPercentage == 0.5)
        }

        // MARK: - Error Handling Tests

        @Test("loadMangas sets errorMessage on fetch failure")
        func loadMangasSetsErrorMessageOnFailure() {
            // Given
            spyInteractor.shouldThrowError = true

            // When
            sut.loadMangas(context: modelContext)

            // Then
            #expect(sut.errorMessage != nil)
            #expect(spyInteractor.fetchAllWasCalled)
        }

        @Test("loadMangas clears errorMessage on success")
        func loadMangasClearsErrorMessageOnSuccess() {
            // Given — first trigger an error
            spyInteractor.shouldThrowError = true
            sut.loadMangas(context: modelContext)
            #expect(sut.errorMessage != nil)

            // When — then succeed
            spyInteractor.shouldThrowError = false
            spyInteractor.allMangasToReturn = [
                WatchMangaItem(mangaId: 1, title: "A"),
            ]
            sut.loadMangas(context: modelContext)

            // Then
            #expect(sut.errorMessage == nil)
        }

        @Test("checkSimulatorSync sets errorMessage on failure")
        func checkSimulatorSyncSetsErrorMessageOnFailure() {
            // Given
            spyInteractor.shouldThrowError = true

            // When
            sut.checkSimulatorSync(context: modelContext)

            // Then
            #expect(sut.errorMessage != nil)
            #expect(spyInteractor.checkSimulatorSyncWasCalled)
        }

        @Test("checkSimulatorSync clears errorMessage on success")
        func checkSimulatorSyncClearsErrorMessageOnSuccess() {
            // Given — first trigger an error
            spyInteractor.shouldThrowError = true
            sut.checkSimulatorSync(context: modelContext)
            #expect(sut.errorMessage != nil)

            // When — then succeed
            spyInteractor.shouldThrowError = false
            sut.checkSimulatorSync(context: modelContext)

            // Then
            #expect(sut.errorMessage == nil)
        }

        @Test("clearError sets errorMessage to nil")
        func clearErrorClearsMessage() {
            // Given
            spyInteractor.shouldThrowError = true
            sut.loadMangas(context: modelContext)
            #expect(sut.errorMessage != nil)

            // When
            sut.clearError()

            // Then
            #expect(sut.errorMessage == nil)
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
