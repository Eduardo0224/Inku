//
//  WatchCollectionInteractorProtocol.swift
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

// MARK: - Watch Collection Interactor Protocol

/// Business-logic contract for the watchOS collection feature.
///
/// The Interactor is **non-isolated** (no `@MainActor`) — it owns no UI state.
/// Members that touch `@MainActor` APIs (WCSession) are explicitly annotated
/// so the compiler enforces correct usage.
protocol WatchCollectionInteractorProtocol: AnyObject {

    // MARK: - Callbacks

    /// Set by the ViewModel to receive incoming WCSession sync payloads.
    /// The Interactor bridges `WatchSessionManager.onSyncReceived` here.
    @MainActor var onSyncReceived: (([WatchMangaTransferItem]) -> Void)? { get set }

    // MARK: - Functions

    /// Wires the WCSession → Interactor → ViewModel callback chain.
    @MainActor func startReceivingSync()

    /// Requests a full collection sync from the iOS companion app.
    @MainActor func syncFromiPhone()

    /// Reads transfer items written by the iOS simulator (debug-only).
    /// Returns an empty array on real devices.
    func loadSimulatorTransferItems() -> [WatchMangaTransferItem]
}
