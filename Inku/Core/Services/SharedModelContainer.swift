//
//  SharedModelContainer.swift
//  Inku
//
//  Created by Eduardo Andrade on 10/02/26.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2026 Eduardo Andrade. All rights reserved.

import SwiftData
import Foundation
import os

/// Shared model container configuration for use across app and widget extension
enum SharedModelContainer {

    // MARK: - Properties

    /// App Group identifier for shared container access
    static let appGroupIdentifier = "group.com.sdp26.inku"

    /// SQLite database filename
    private static let databaseFilename = "Inku.sqlite"

    /// Shared ModelContainer instance (singleton, nil if creation fails)
    static let shared: ModelContainer? = {
        let schema = Schema([CollectionManga.self])
        let modelConfiguration = createModelConfiguration(for: schema)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            Logger.core.error("Could not create ModelContainer: \(error)")
            return nil
        }
    }()

    // MARK: - Private Functions

    /// Creates the appropriate ModelConfiguration for the current platform
    private static func createModelConfiguration(for schema: Schema) -> ModelConfiguration {
        #if os(iOS) || targetEnvironment(macCatalyst)
        createIOSConfiguration(for: schema)
        #elseif os(macOS)
        createMacOSConfiguration(for: schema)
        #elseif os(visionOS)
        createVisionOSConfiguration(for: schema)
        #else
        createDefaultConfiguration(for: schema)
        #endif
    }

    /// Creates ModelConfiguration for iOS/Catalyst with App Group support
    private static func createIOSConfiguration(for schema: Schema) -> ModelConfiguration {
        if let storeURL = appGroupStoreURL() {
            return createConfiguration(for: schema, at: storeURL)
        }
        return createDefaultConfiguration(for: schema)
    }

    /// Creates ModelConfiguration for macOS with App Group and Application Support fallback
    private static func createMacOSConfiguration(for schema: Schema) -> ModelConfiguration {
        if let storeURL = appGroupStoreURL() {
            return createConfiguration(for: schema, at: storeURL)
        }

        if let storeURL = applicationSupportStoreURL() {
            return createConfiguration(for: schema, at: storeURL)
        }

        return createDefaultConfiguration(for: schema)
    }

    /// Creates ModelConfiguration for visionOS with App Group support
    private static func createVisionOSConfiguration(for schema: Schema) -> ModelConfiguration {
        if let storeURL = appGroupStoreURL() {
            return createConfiguration(for: schema, at: storeURL)
        }
        return createDefaultConfiguration(for: schema)
    }

    /// Returns the App Group container URL with database filename
    private static func appGroupStoreURL() -> URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier)?
            .appendingPathComponent(databaseFilename)
    }

    /// Returns the Application Support directory URL with database filename (macOS)
    private static func applicationSupportStoreURL() -> URL? {
        guard let appSupportURL = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first else {
            return nil
        }

        let bundleID = Bundle.main.bundleIdentifier ?? "com.sdp26.inku"
        let appDirectory = appSupportURL.appendingPathComponent(bundleID, isDirectory: true)

        // Create directory if it doesn't exist
        try? FileManager.default.createDirectory(
            at: appDirectory,
            withIntermediateDirectories: true
        )

        return appDirectory.appendingPathComponent(databaseFilename)
    }

    /// Creates a ModelConfiguration with a specific store URL
    private static func createConfiguration(
        for schema: Schema,
        at storeURL: URL
    ) -> ModelConfiguration {
        .init(
            schema: schema,
            url: storeURL,
            cloudKitDatabase: .none
        )
    }

    /// Creates a default in-memory ModelConfiguration
    private static func createDefaultConfiguration(for schema: Schema) -> ModelConfiguration {
        .init(schema: schema, isStoredInMemoryOnly: false)
    }
}
