//
//  InkuWatchApp.swift
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

import SwiftUI
import SwiftData
import OSLog

// MARK: - Inku Watch App

@main
struct InkuWatchApp: App {

    // MARK: - Private Properties

    private let container: ModelContainer

    // MARK: - Body

    var body: some Scene {
        WindowGroup {
            WatchRootView()
        }
        .modelContainer(container)
    }

    // MARK: - Initializers

    init() {
        self.container = Self.makeModelContainer()
        seedInitialData()
    }

    // MARK: - Model Container Factory

    private static func makeModelContainer() -> ModelContainer {
        let schema = Schema([WatchMangaItem.self])
        let storeConfig = ModelConfiguration(
            "InkuWatch",
            cloudKitDatabase: .none
        )
        let logger = Logger.inkuWatch

        // Attempt 1: open existing store
        if let container = try? ModelContainer(for: schema, configurations: [storeConfig]) {
            return container
        }

        // Attempt 2: schema mismatch — delete old store and retry
        logger.warning("Store open failed (likely schema change), recreating…")
        try? FileManager.default.removeItem(at: storeConfig.url)
        if let container = try? ModelContainer(for: schema, configurations: [storeConfig]) {
            return container
        }

        // Attempt 3: in-memory fallback (guaranteed for a valid schema)
        logger.error("Persistent store unavailable, falling back to in-memory")
        let memConfig = ModelConfiguration(isStoredInMemoryOnly: true)
        guard let container = try? ModelContainer(for: schema, configurations: [memConfig]) else {
            // Truly unrecoverable: schema definition itself is broken.
            preconditionFailure("InkuWatch: Cannot create ModelContainer — schema is invalid.")
        }
        return container
    }

    // MARK: - Seeding

    private func seedInitialData() {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<WatchMangaItem>()
        guard (try? context.fetch(descriptor).count) == 0 else { return }

        let synced = SimulatorSyncBridge.loadTransferItems()
        for item in synced {
            let manga = WatchMangaItem(
                mangaId: item.mangaId,
                title: item.title
            )
            manga.apply(item)
            context.insert(manga)
        }

        if !synced.isEmpty {
            try? context.save()
        }
    }
}
