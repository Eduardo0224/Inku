//
//  SimulatorSyncBridge.swift
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
//

import Foundation
import SwiftData
import OSLog

// MARK: - Simulator Sync Bridge

enum SimulatorSyncBridge {

    private static let logger = Logger.inkuWatch
    private static let sharedDir = "/tmp/inku-simulator-sync"
    private static let filename = "collection.json"

    // MARK: - Read

    /// Automatically enabled when running in the simulator,
    /// disabled on real devices (relies on WCSession instead).
    #if targetEnvironment(simulator)
    static let isEnabled = true
    #else
    static let isEnabled = false
    #endif

    static func loadTransferItems() -> [WatchMangaTransferItem] {
        guard isEnabled else { return [] }
        let url = URL(fileURLWithPath: sharedDir).appendingPathComponent(filename)
        guard FileManager.default.fileExists(atPath: url.path),
              let data = try? Data(contentsOf: url),
              let items = try? JSONDecoder().decode([WatchMangaTransferItem].self, from: data) else {
            return []
        }
        logger.info("Simulator sync: loaded \(items.count) items from shared file")
        return items
    }
}
