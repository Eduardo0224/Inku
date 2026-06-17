//
//  WatchStoreConfiguration.swift
//  InkuWatch
//
//  Created by Eduardo Andrade on 17/06/26.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2026 Eduardo Andrade. All rights reserved.
//

import Foundation
import SwiftData

// MARK: - Watch Store Configuration

/// Shared store configuration used by both the InkuWatch app and
/// the InkuWatchWidget extension so they read/write the same SQLite file
/// via the App Group container.
enum WatchStoreConfiguration {

    /// App Group identifier — must match the entitlements of both targets.
    private static let appGroup = "group.com.sdp26.inku"

    /// SQLite file name inside the App Group container.
    private static let storeName = "InkuWatch.sqlite"

    // MARK: - Store URL

    /// Explicit App Group URL so the widget extension and main app
    /// share the same persistent store.
    static var storeURL: URL {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroup)!
            .appendingPathComponent(storeName)
    }

    // MARK: - Model Configuration

    static func makeConfiguration() -> ModelConfiguration {
        ModelConfiguration(
            "InkuWatch",
            url: storeURL,
            cloudKitDatabase: .none
        )
    }
}
