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

// MARK: - Watch Collection ViewModel

@Observable
@MainActor
final class WatchCollectionViewModel {

    // MARK: - Private Properties

    @ObservationIgnored
    private let sessionManager: WatchSessionManager

    // MARK: - Properties

    var allMangas: [WatchMangaItem] = []
    var nowReading: [WatchMangaItem] = []
    var completed: [WatchMangaItem] = []

    // MARK: - Initializers

    init(sessionManager: WatchSessionManager? = nil) {
        self.sessionManager = sessionManager ?? WatchSessionManager()
    }

    // MARK: - Functions

    func loadMangas(context: ModelContext) {
        let allDescriptor = FetchDescriptor<WatchMangaItem>(
            sortBy: [SortDescriptor(\.dateAdded, order: .reverse)]
        )
        let readingDescriptor = FetchDescriptor<WatchMangaItem>(
            predicate: #Predicate { $0.currentReadingVolume != nil },
            sortBy: [SortDescriptor(\.dateAdded, order: .reverse)]
        )
        let completeDescriptor = FetchDescriptor<WatchMangaItem>(
            predicate: #Predicate { $0.hasCompleteCollection == true },
            sortBy: [SortDescriptor(\.dateAdded, order: .reverse)]
        )

        allMangas = (try? context.fetch(allDescriptor)) ?? []
        nowReading = (try? context.fetch(readingDescriptor)) ?? []
        completed = (try? context.fetch(completeDescriptor)) ?? []
    }

    // MARK: - Configuration

    func configureSession(with container: ModelContainer) {
        sessionManager.setModelContainer(container)
    }

    // MARK: - Stats

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

    // MARK: - Sync

    func syncFromiPhone() {
        sessionManager.requestFullSync()
    }

    func checkSimulatorSync(context: ModelContext) {
        let items = SimulatorSyncBridge.loadTransferItems()
        guard !items.isEmpty else { return }

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

        try? context.save()
        loadMangas(context: context)
    }
}
