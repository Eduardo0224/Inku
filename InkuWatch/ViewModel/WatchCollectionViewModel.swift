//
//  WatchCollectionViewModel.swift
//  InkuWatch
//
//  Created by Eduardo Andrade on 02/06/26.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2026 Eduardo Andrade. All rights reserved.
//

import Foundation
import SwiftData
import Observation
import OSLog
import WidgetKit

// MARK: - Watch Collection ViewModel

@Observable
@MainActor
final class WatchCollectionViewModel {

    // MARK: - Private Properties

    @ObservationIgnored
    private let interactor: WatchCollectionInteractorProtocol

    @ObservationIgnored
    private let logger = Logger.inkuWatch

    @ObservationIgnored
    private var modelContext: ModelContext?

    // MARK: - Properties

    var allMangas: [WatchMangaItem] = []
    var nowReading: [WatchMangaItem] = []
    var completed: [WatchMangaItem] = []
    var errorMessage: String?

    /// Value-type snapshots for views that should not depend on SwiftData.
    var allMangaDisplayItems: [WatchMangaDisplayItem] {
        allMangas.map { $0.displayItem }
    }
    var nowReadingDisplayItems: [WatchMangaDisplayItem] {
        nowReading.map { $0.displayItem }
    }

    var totalMangas: Int { allMangas.count }
    var totalVolumesOwned: Int { allMangas.reduce(0) { $0 + $1.volumesOwned } }
    var completedCount: Int { completed.count }
    var readingCount: Int { nowReading.count }

    var averageProgress: Double {
        let withProgress = allMangas.compactMap { $0.readingProgress }
        guard !withProgress.isEmpty else { return 0 }
        return withProgress.reduce(0, +) / Double(withProgress.count)
    }

    var completionPercentage: Double {
        let withTotal = allMangas.filter { $0.totalVolumes != nil }
        guard !withTotal.isEmpty else { return 0 }
        let complete = withTotal.filter { $0.isComplete }.count
        return Double(complete) / Double(withTotal.count)
    }

    // MARK: - Initializers

    init(
        interactor: WatchCollectionInteractorProtocol = WatchCollectionInteractor(
            sessionManager: WatchSessionManager()
        )
    ) {
        self.interactor = interactor
        setupSyncCallback()
    }

    // MARK: - Private Functions

    private func setupSyncCallback() {
        interactor.onSyncReceived = { [weak self] items in
            self?.handleIncomingSync(items)
        }
    }

    private func handleIncomingSync(_ items: [WatchMangaTransferItem]) {
        guard let context = modelContext else {
            logger.warning("Sync items received but modelContext not set — discarding")
            return
        }
        do {
            try applyTransferItems(items, context: context)
            logger.info("Sync applied from iPhone: \(items.count) items")
            WidgetCenter.shared.reloadAllTimelines()
            loadMangas(context: context)
        } catch {
            errorMessage = error.localizedDescription
            logger.error("Sync from iPhone failed: \(error.localizedDescription)")
        }
    }

    private func fetchAll(context: ModelContext) throws -> [WatchMangaItem] {
        let descriptor = FetchDescriptor<WatchMangaItem>(
            sortBy: [SortDescriptor(\.title)]
        )
        return try context.fetch(descriptor)
    }

    private func fetchReading(context: ModelContext) throws -> [WatchMangaItem] {
        let descriptor = FetchDescriptor<WatchMangaItem>(
            predicate: #Predicate { $0.currentReadingVolume != nil },
            sortBy: [SortDescriptor(\.lastSynced, order: .reverse)]
        )
        return try context.fetch(descriptor)
    }

    private func fetchCompleted(context: ModelContext) throws -> [WatchMangaItem] {
        let descriptor = FetchDescriptor<WatchMangaItem>(
            predicate: #Predicate { $0.hasCompleteCollection == true },
            sortBy: [SortDescriptor(\.title)]
        )
        return try context.fetch(descriptor)
    }

    private func applyTransferItems(
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

    // MARK: - Functions

    func setModelContext(_ modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func startReceivingSync() {
        interactor.startReceivingSync()
    }

    func loadMangas(context: ModelContext) {
        do {
            allMangas = try fetchAll(context: context)
            nowReading = try fetchReading(context: context)
            completed = try fetchCompleted(context: context)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
            logger.error("Failed to load mangas: \(error.localizedDescription)")
        }
    }

    func syncFromiPhone() {
        interactor.syncFromiPhone()
    }

    func clearError() {
        errorMessage = nil
    }

    func checkSimulatorSync(context: ModelContext) {
        let items = interactor.loadSimulatorTransferItems()
        guard !items.isEmpty else { return }
        do {
            try applyTransferItems(items, context: context)
            logger.info("Simulator sync applied: \(items.count) items")
            WidgetCenter.shared.reloadAllTimelines()
            loadMangas(context: context)
        } catch {
            errorMessage = error.localizedDescription
            logger.error("Simulator sync failed: \(error.localizedDescription)")
        }
    }
}
