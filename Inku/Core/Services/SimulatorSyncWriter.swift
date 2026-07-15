//
//  SimulatorSyncWriter.swift
//  Inku
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
import OSLog

// MARK: - Simulator Sync Writer

enum SimulatorSyncWriter {

    private static let logger = Logger.inkuWatch
    private static let sharedDir = "/tmp/inku-simulator-sync"
    private static let filename = "collection.json"

    // MARK: - Write

    static func exportCollection(_ items: [WatchMangaTransferItem]) {
        #if !targetEnvironment(simulator)
        return
        #endif
        guard !items.isEmpty else { return }

        let dirURL = URL(fileURLWithPath: sharedDir)
        try? FileManager.default.createDirectory(at: dirURL, withIntermediateDirectories: true)

        guard let data = try? JSONEncoder().encode(items) else {
            logger.error("Failed to encode collection for simulator sync")
            return
        }

        let fileURL = dirURL.appendingPathComponent(filename)
        try? data.write(to: fileURL, options: .atomic)
        logger.info("Simulator sync: exported \(items.count) items with covers")
    }
}
