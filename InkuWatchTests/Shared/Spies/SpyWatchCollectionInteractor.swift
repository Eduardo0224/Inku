//
//  SpyWatchCollectionInteractor.swift
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
@testable import InkuWatch

// MARK: - Spy Watch Collection Interactor

@MainActor
final class SpyWatchCollectionInteractor: WatchCollectionInteractorProtocol {

    // MARK: - Properties (Spy Tracking)

    private(set) var startReceivingSyncWasCalled = false
    private(set) var syncFromiPhoneWasCalled = false
    private(set) var loadSimulatorTransferItemsWasCalled = false

    // MARK: - Properties (Stub Data)

    @MainActor var onSyncReceived: (([WatchMangaTransferItem]) -> Void)?

    var simulatorItemsToReturn: [WatchMangaTransferItem] = []
    var shouldThrowError = false
    var errorToThrow: Error = NSError(domain: "SpyError", code: 1)

    // MARK: - WatchCollectionInteractorProtocol

    @MainActor
    func startReceivingSync() {
        startReceivingSyncWasCalled = true
    }

    @MainActor
    func syncFromiPhone() {
        syncFromiPhoneWasCalled = true
    }

    func loadSimulatorTransferItems() -> [WatchMangaTransferItem] {
        loadSimulatorTransferItemsWasCalled = true
        return simulatorItemsToReturn
    }

    func reset() {
        startReceivingSyncWasCalled = false
        syncFromiPhoneWasCalled = false
        loadSimulatorTransferItemsWasCalled = false
        simulatorItemsToReturn = []
        shouldThrowError = false
    }
}
