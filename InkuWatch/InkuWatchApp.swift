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

    private let modelContainer: ModelContainer?

    // MARK: - Body

    var body: some Scene {
        WindowGroup {
            if let modelContainer {
                WatchRootView()
                    .modelContainer(modelContainer)
            } else {
                ContentUnavailableView(
                    L10n.Error.title,
                    systemImage: "exclamationmark.triangle",
                    description: Text(L10n.Error.generic)
                )
            }
        }
    }

    // MARK: - Initializers

    init() {
        self.modelContainer = Self.makeModelContainer()
    }

    // MARK: - Model Container Factory

    private static func makeModelContainer() -> ModelContainer? {
        let schema = Schema([WatchMangaItem.self])
        let storeConfig = WatchStoreConfiguration.makeConfiguration()
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

        // Attempt 3: both failed — show error UI instead of crashing
        logger.error("Persistent store unavailable — showing error UI")
        return nil
    }
}
