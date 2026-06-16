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
import SwiftData
import OSLog
import WidgetKit

// MARK: - Watch Collection Interactor

final class WatchCollectionInteractor: WatchCollectionInteractorProtocol {

    // MARK: - Private Properties

    private let logger = Logger.inkuWatch
    private let sessionManager: WatchSessionManagerProtocol
    private var modelContainer: ModelContainer?

    // MARK: - Initializers

    init(sessionManager: WatchSessionManagerProtocol) {
        self.sessionManager = sessionManager
        sessionManager.onSyncReceived = { [weak self] items in
            self?.handleSync(items)
        }
    }

    // MARK: - Session Configuration

    func configureSession(with container: ModelContainer) {
        modelContainer = container
    }

    func syncFromiPhone() {
        sessionManager.requestFullSync()
    }

    // MARK: - Simulator Sync

    func checkSimulatorSync(context: ModelContext) throws {
        let items = SimulatorSyncBridge.loadTransferItems()
        guard !items.isEmpty else { return }
        try applyTransferItems(items, context: context)
        logger.info("Simulator sync applied: \(items.count) items")
        WidgetCenter.shared.reloadAllTimelines()
    }

    // MARK: - Fetch Functions

    func fetchAll(context: ModelContext) throws -> [WatchMangaItem] {
        let descriptor = FetchDescriptor<WatchMangaItem>(
            sortBy: [SortDescriptor(\.title)]
        )
        return try context.fetch(descriptor)
    }

    func fetchReading(context: ModelContext) throws -> [WatchMangaItem] {
        let descriptor = FetchDescriptor<WatchMangaItem>(
            predicate: #Predicate { $0.currentReadingVolume != nil },
            sortBy: [SortDescriptor(\.lastSynced, order: .reverse)]
        )
        return try context.fetch(descriptor)
    }

    func fetchCompleted(context: ModelContext) throws -> [WatchMangaItem] {
        let descriptor = FetchDescriptor<WatchMangaItem>(
            predicate: #Predicate { $0.hasCompleteCollection == true },
            sortBy: [SortDescriptor(\.title)]
        )
        return try context.fetch(descriptor)
    }

    // MARK: - Transfer Items

    func applyTransferItems(
        _ items: [WatchMangaTransferItem],
        context: ModelContext
    ) throws {
        let receivedIds = Set(items.map(\.mangaId))

        for item in items {
            let descriptor = FetchDescriptor<WatchMangaItem>(
                predicate: #Predicate { $0.mangaId == item.mangaId }
            )
            if let existing = try? context.fetch(descriptor).first {
                existing.apply(item)
            } else {
                let newItem = WatchMangaItem(
                    mangaId: item.mangaId,
                    title: item.title
                )
                newItem.apply(item)
                context.insert(newItem)
            }
        }

        let allDescriptor = FetchDescriptor<WatchMangaItem>()
        if let all = try? context.fetch(allDescriptor) {
            for manga in all where !receivedIds.contains(manga.mangaId) {
                context.delete(manga)
            }
        }

        try context.save()
    }

    // MARK: - Private Functions

    /// Handles incoming sync from WCSession via the sessionManager callback.
    /// Called on `@MainActor` by `WatchSessionManager`.
    private func handleSync(_ items: [WatchMangaTransferItem]) {
        guard let context = modelContainer?.mainContext else { return }
        do {
            try applyTransferItems(items, context: context)
            logger.info("Sync applied from iPhone: \(items.count) items")
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            logger.error("Sync from iPhone failed: \(error.localizedDescription)")
        }
    }
}
