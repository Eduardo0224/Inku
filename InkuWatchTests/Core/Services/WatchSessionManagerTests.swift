//
//  WatchSessionManagerTests.swift
//  InkuWatchTests
//
//  Created by Eduardo Andrade on 17/06/26.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2026 Eduardo Andrade. All rights reserved.
//

import Foundation
import Testing
@testable import InkuWatch

@Suite("WatchSessionManager Tests")
@MainActor
struct WatchSessionManagerTests {

    // MARK: - Subject Under Test

    let sut = WatchSessionManager()

    // MARK: - Initial State Tests

    @Test("Initial state has nil lastSyncDate and isSyncing false")
    func initialStateIsCorrect() {
        #expect(sut.lastSyncDate == nil)
        #expect(sut.isSyncing == false)
    }

    // MARK: - OnSyncReceived Callback Tests

    @Test("handleSync calls onSyncReceived with correct items")
    func handleSyncCallsCallback() {
        // Given
        var receivedItems: [WatchMangaTransferItem]?
        sut.onSyncReceived = { items in
            receivedItems = items
        }
        let item = WatchMangaTransferItem(
            mangaId: 1,
            title: "Berserk",
            volumesOwned: 41,
            totalVolumes: 41,
            hasCompleteCollection: true
        )

        // When
        sut.handleSync([item])

        // Then
        #expect(receivedItems != nil)
        #expect(receivedItems?.count == 1)
        #expect(receivedItems?.first?.title == "Berserk")
    }

    @Test("handleSync updates lastSyncDate")
    func handleSyncUpdatesLastSyncDate() {
        // Given
        let item = WatchMangaTransferItem(mangaId: 1, title: "Test")

        // When
        sut.handleSync([item])

        // Then
        #expect(sut.lastSyncDate != nil)
    }

    @Test("handleSync sets isSyncing to false")
    func handleSyncSetsIsSyncingFalse() {
        // Given
        let item = WatchMangaTransferItem(mangaId: 1, title: "Test")

        // When
        sut.handleSync([item])

        // Then
        #expect(sut.isSyncing == false)
    }

    @Test("handleSync with empty array calls callback with empty items")
    func handleSyncEmptyArray() {
        // Given
        var receivedItems: [WatchMangaTransferItem]?
        sut.onSyncReceived = { items in
            receivedItems = items
        }

        // When
        sut.handleSync([])

        // Then
        #expect(receivedItems != nil)
        #expect(receivedItems?.isEmpty == true)
    }

    @Test("handleSync with multiple items preserves order")
    func handleSyncMultipleItems() {
        // Given
        var receivedItems: [WatchMangaTransferItem]?
        sut.onSyncReceived = { items in
            receivedItems = items
        }
        let items = [
            WatchMangaTransferItem(mangaId: 1, title: "A"),
            WatchMangaTransferItem(mangaId: 2, title: "B"),
            WatchMangaTransferItem(mangaId: 3, title: "C"),
        ]

        // When
        sut.handleSync(items)

        // Then
        #expect(receivedItems?.count == 3)
        #expect(receivedItems?.map(\.title) == ["A", "B", "C"])
    }

    // MARK: - OnSyncReceived Nil Safety

    @Test("handleSync does not crash when onSyncReceived is nil")
    func handleSyncWithNilCallbackDoesNotCrash() {
        // Given — onSyncReceived is nil (default)

        // When/Then — should not crash
        sut.handleSync([WatchMangaTransferItem(mangaId: 1, title: "Test")])
        #expect(sut.lastSyncDate != nil)
    }
}
