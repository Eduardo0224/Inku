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
@testable import InkuWatch

extension WatchCollectionTests {

    @Suite("Interactor Tests")
    @MainActor
    struct InteractorTests {

        // MARK: - Subject Under Test

        let sut: WatchCollectionInteractor

        // MARK: - Spies

        let spySessionManager: SpyWatchSessionManager

        // MARK: - Initializers

        init() {
            spySessionManager = SpyWatchSessionManager()
            sut = WatchCollectionInteractor(sessionManager: spySessionManager)
        }

        // MARK: - Start Receiving Sync Tests

        @Test("startReceivingSync wires onSyncReceived callback chain")
        func startReceivingSyncWiresCallback() {
            // Given/When
            sut.startReceivingSync()

            // Then — WCSession → Interactor → ViewModel chain is wired
            #expect(spySessionManager.onSyncReceived != nil,
                    "Interactor should register onSyncReceived on sessionManager")
        }

        // MARK: - Sync From iPhone Tests

        @Test("syncFromiPhone delegates to session manager")
        func syncFromiPhoneDelegates() {
            // Given/When
            sut.syncFromiPhone()

            // Then
            #expect(spySessionManager.requestFullSyncWasCalled)
        }

        // MARK: - Callback Forwarding Tests

        @Test("onSyncReceived is forwarded from sessionManager to interactor callback")
        func onSyncReceivedForwarding() {
            // Given
            sut.startReceivingSync()
            let item = WatchMangaTransferItem(
                mangaId: 1,
                title: "Berserk",
                volumesOwned: 41,
                totalVolumes: 41,
                hasCompleteCollection: true
            )

            var receivedItems: [WatchMangaTransferItem]?
            sut.onSyncReceived = { items in
                receivedItems = items
            }

            // When — simulate WCSession delivering items
            spySessionManager.simulateIncomingSync([item])

            // Then
            #expect(receivedItems?.count == 1)
            #expect(receivedItems?.first?.title == "Berserk")
        }

        // MARK: - Load Simulator Transfer Items Tests

        @Test("loadSimulatorTransferItems returns without crashing")
        func loadSimulatorTransferItemsDoesNotCrash() {
            // Given/When — reads from /tmp, returns empty on CI/device
            let items = sut.loadSimulatorTransferItems()

            // Then — method should succeed (content depends on environment)
            #expect(items.count >= 0)
        }
    }
}
