//
//  WatchCollectionInteractor.swift
//  InkuWatch
//
//  Created by Eduardo Andrade on 10/06/26.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2026 Eduardo Andrade. All rights reserved.
//

import Foundation
import OSLog

// MARK: - Watch Collection Interactor

/// Non-isolated business logic for the watchOS collection.
///
/// SwiftData operations live in `WatchCollectionViewModel` (`@MainActor`),
/// following the same pattern as the iOS `CollectionInteractor`.
final class WatchCollectionInteractor: WatchCollectionInteractorProtocol {

    // MARK: - Private Properties

    private let logger = Logger.inkuWatch
    private let sessionManager: WatchSessionManagerProtocol

    // MARK: - Properties

    /// Bridging callback — set by the ViewModel during `configureSession`.
    @MainActor var onSyncReceived: (([WatchMangaTransferItem]) -> Void)?

    // MARK: - Initializers

    init(sessionManager: WatchSessionManagerProtocol) {
        self.sessionManager = sessionManager
    }

    // MARK: - Private Functions

    /// Forwards incoming WCSession items to the ViewModel's callback.
    /// Called on `@MainActor` by `WatchSessionManager`.
    @MainActor
    private func handleIncomingSync(_ items: [WatchMangaTransferItem]) {
        logger.info("Sync received from iPhone: \(items.count) items — forwarding to ViewModel")
        onSyncReceived?(items)
    }

    // MARK: - Functions

    @MainActor
    func startReceivingSync() {
        // Wire WCSession → Interactor → ViewModel callback chain.
        sessionManager.onSyncReceived = { [weak self] items in
            self?.handleIncomingSync(items)
        }
    }

    @MainActor
    func syncFromiPhone() {
        sessionManager.requestFullSync()
    }

    func loadSimulatorTransferItems() -> [WatchMangaTransferItem] {
        SimulatorSyncBridge.loadTransferItems()
    }
}
