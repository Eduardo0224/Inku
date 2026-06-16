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
import SwiftData
@testable import InkuWatch

// MARK: - Spy Watch Collection Interactor

final class SpyWatchCollectionInteractor: WatchCollectionInteractorProtocol {

    // MARK: - Properties (Spy Tracking)

    private(set) var configureSessionWasCalled = false
    private(set) var syncFromiPhoneWasCalled = false
    private(set) var checkSimulatorSyncWasCalled = false
    private(set) var fetchAllWasCalled = false
    private(set) var fetchReadingWasCalled = false
    private(set) var fetchCompletedWasCalled = false
    private(set) var applyTransferItemsWasCalled = false

    private(set) var lastConfigureSessionContainer: ModelContainer?
    private(set) var lastCheckSimulatorSyncContext: ModelContext?
    private(set) var lastFetchAllContext: ModelContext?
    private(set) var lastFetchReadingContext: ModelContext?
    private(set) var lastFetchCompletedContext: ModelContext?
    private(set) var lastApplyTransferItems: [WatchMangaTransferItem]?
    private(set) var lastApplyTransferItemsContext: ModelContext?

    // MARK: - Properties (Stub Data)

    var allMangasToReturn: [WatchMangaItem] = []
    var readingMangasToReturn: [WatchMangaItem] = []
    var completedMangasToReturn: [WatchMangaItem] = []
    var shouldThrowError = false
    var errorToThrow: Error = NSError(domain: "SpyError", code: 1)

    // MARK: - WatchCollectionInteractorProtocol

    func configureSession(with container: ModelContainer) {
        configureSessionWasCalled = true
        lastConfigureSessionContainer = container
    }

    func syncFromiPhone() {
        syncFromiPhoneWasCalled = true
    }

    func checkSimulatorSync(context: ModelContext) throws {
        checkSimulatorSyncWasCalled = true
        lastCheckSimulatorSyncContext = context
        if shouldThrowError {
            throw errorToThrow
        }
    }

    func fetchAll(context: ModelContext) throws -> [WatchMangaItem] {
        fetchAllWasCalled = true
        lastFetchAllContext = context
        if shouldThrowError {
            throw errorToThrow
        }
        return allMangasToReturn
    }

    func fetchReading(context: ModelContext) throws -> [WatchMangaItem] {
        fetchReadingWasCalled = true
        lastFetchReadingContext = context
        if shouldThrowError {
            throw errorToThrow
        }
        return readingMangasToReturn
    }

    func fetchCompleted(context: ModelContext) throws -> [WatchMangaItem] {
        fetchCompletedWasCalled = true
        lastFetchCompletedContext = context
        if shouldThrowError {
            throw errorToThrow
        }
        return completedMangasToReturn
    }

    func applyTransferItems(
        _ items: [WatchMangaTransferItem],
        context: ModelContext
    ) throws {
        applyTransferItemsWasCalled = true
        lastApplyTransferItems = items
        lastApplyTransferItemsContext = context
        if shouldThrowError {
            throw errorToThrow
        }
    }
}
