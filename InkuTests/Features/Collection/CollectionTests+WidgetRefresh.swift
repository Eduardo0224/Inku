//
//  CollectionTests+WidgetRefresh.swift
//  InkuTests
//
//  Created by Eduardo Andrade on 12/02/26.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2026 Eduardo Andrade. All rights reserved.

import Foundation
import Testing
import SwiftData
@testable import Inku

extension CollectionTests {

    @Suite("Widget Refresh Tests")
    @MainActor
    struct WidgetRefreshTests {

        // MARK: - Subject Under Test

        let sut: CollectionViewModel
        let spyWidgetCenter: SpyWidgetCenter

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
            spyWidgetCenter = SpyWidgetCenter()
            sut = CollectionViewModel(
                interactor: MockCollectionInteractor(),
                widgetCenter: spyWidgetCenter
            )
            sut.setModelContext(modelContext)
        }

        // MARK: - Add Tests

        @Test("Refreshes widgets when adding manga to collection")
        func refreshesWidgetsOnAdd() throws {
            // Given
            #expect(spyWidgetCenter.refreshInkuWidgetsWasCalled == false)
            // When
            try sut.addToCollection(.testData)
            // Then
            #expect(spyWidgetCenter.refreshInkuWidgetsWasCalled == true)
        }

        @Test("Does not refresh widgets when adding duplicate manga")
        func doesNotRefreshWidgetsOnDuplicateAdd() throws {
            // Given
            try sut.addToCollection(.testData)
            spyWidgetCenter.reset()
            #expect(spyWidgetCenter.refreshInkuWidgetsWasCalled == false)
            // When/Then - should throw error and not refresh widgets
            #expect(throws: CollectionError.alreadyExists) {
                try sut.addToCollection(.testData)
            }
            #expect(spyWidgetCenter.refreshInkuWidgetsWasCalled == false)
        }

        // MARK: - Update Tests

        @Test("Refreshes widgets when updating manga in collection")
        func refreshesWidgetsOnUpdate() throws {
            // Given
            try sut.addToCollection(.testData)
            spyWidgetCenter.reset()

            guard let collectionManga = sut.getCollectionManga(mangaId: Manga.testData.id) else {
                Issue.record("Collection manga should exist")
                return
            }

            collectionManga.volumesOwnedCount = 10
            #expect(spyWidgetCenter.refreshInkuWidgetsWasCalled == false)
            // When
            try sut.updateCollection(collectionManga)
            // Then
            #expect(spyWidgetCenter.refreshInkuWidgetsWasCalled == true)
        }

        // MARK: - Remove Tests

        @Test("Refreshes widgets when removing manga from collection")
        func refreshesWidgetsOnRemove() throws {
            // Given
            try sut.addToCollection(.testData)
            spyWidgetCenter.reset()

            guard let collectionManga = sut.getCollectionManga(mangaId: Manga.testData.id) else {
                Issue.record("Collection manga should exist")
                return
            }

            #expect(spyWidgetCenter.refreshInkuWidgetsWasCalled == false)
            // When
            try sut.removeFromCollection(collectionManga)
            // Then
            #expect(spyWidgetCenter.refreshInkuWidgetsWasCalled == true)
        }

        // MARK: - Cloud Sync Tests

        @Test("Refreshes widgets when syncing cloud mangas to local")
        func refreshesWidgetsOnCloudSync() throws {
            // Given
            #expect(spyWidgetCenter.refreshInkuWidgetsWasCalled == false)
            // When
            try sut.addCloudMangasToLocal([Self.sampleCloudManga])
            // Then
            #expect(spyWidgetCenter.refreshInkuWidgetsWasCalled == true)
        }

        @Test("Refreshes widgets when syncing multiple cloud mangas")
        func refreshesWidgetsOnMultipleCloudSync() throws {
            // Given
            #expect(spyWidgetCenter.refreshInkuWidgetsWasCalled == false)
            // When
            try sut.addCloudMangasToLocal([Self.sampleCloudManga, Self.sampleCloudManga2])
            // Then
            #expect(spyWidgetCenter.refreshInkuWidgetsWasCalled == true)
        }

        // MARK: - Comprehensive Tests

        @Test("Refreshes widgets correctly through complete CRUD lifecycle")
        func refreshesWidgetsThroughCRUDLifecycle() throws {
            // Given
            spyWidgetCenter.reset()
            // When - Add
            try sut.addToCollection(.testData)
            #expect(spyWidgetCenter.refreshInkuWidgetsWasCalled == true)
            // Reset and Update
            spyWidgetCenter.reset()
            if let collectionManga = sut.getCollectionManga(mangaId: Manga.testData.id) {
                collectionManga.volumesOwnedCount = 25
                try sut.updateCollection(collectionManga)
            }
            #expect(spyWidgetCenter.refreshInkuWidgetsWasCalled == true)
            // Reset and Another Update
            spyWidgetCenter.reset()
            if let collectionManga = sut.getCollectionManga(mangaId: Manga.testData.id) {
                collectionManga.currentReadingVolume = 10
                try sut.updateCollection(collectionManga)
            }
            #expect(spyWidgetCenter.refreshInkuWidgetsWasCalled == true)
            // Reset and Remove
            spyWidgetCenter.reset()
            if let collectionManga = sut.getCollectionManga(mangaId: Manga.testData.id) {
                try sut.removeFromCollection(collectionManga)
            }
            #expect(spyWidgetCenter.refreshInkuWidgetsWasCalled == true)
        }
    }
}

// MARK: - Test Data

private extension CollectionTests.WidgetRefreshTests {

    static var sampleManga2: Manga {
        .init(
            id: 2,
            title: "One Piece",
            titleEnglish: "One Piece",
            titleJapanese: "ワンピース",
            sypnosis: "Pirates adventure",
            background: nil,
            mainPicture: "https://example.com/onepiece.jpg",
            url: nil,
            volumes: 105,
            chapters: nil,
            status: "Publishing",
            score: 9.0,
            startDate: nil,
            endDate: nil,
            authors: [],
            genres: [],
            demographics: [],
            themes: []
        )
    }

    static var sampleCloudManga: CloudCollectionManga {
        .init(
            id: "1",
            manga: .testData,
            user: CloudCollectionManga.UserInfo(id: "user1"),
            completeCollection: false,
            volumesOwned: [1, 2, 3],
            readingVolume: 3
        )
    }

    static var sampleCloudManga2: CloudCollectionManga {
        .init(
            id: "2",
            manga: sampleManga2,
            user: CloudCollectionManga.UserInfo(id: "user1"),
            completeCollection: false,
            volumesOwned: [1, 2, 3, 4, 5],
            readingVolume: 5
        )
    }
}
