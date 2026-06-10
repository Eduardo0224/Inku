//
//  WatchSessionManager.swift
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
import WatchConnectivity
import SwiftData
import OSLog

// MARK: - Watch Session Manager

@MainActor
@Observable
final class WatchSessionManager {

    // MARK: - Private Properties

    private let logger = Logger.inkuWatch
    private var modelContainer: ModelContainer?
    private let sessionDelegate = SessionDelegate()

    // MARK: - Properties

    private(set) var isSyncing = false
    private(set) var lastSyncDate: Date?

    // MARK: - Initializers

    init() {
        sessionDelegate.owner = self
        guard WCSession.isSupported() else {
            logger.warning("WatchConnectivity not supported on this device")
            return
        }
        let session = WCSession.default
        session.delegate = sessionDelegate
        session.activate()
    }

    // MARK: - Functions

    func setModelContainer(_ container: ModelContainer) {
        self.modelContainer = container
    }

    /// Requests a full sync from the iOS app.
    func requestFullSync() {
        guard WCSession.default.isReachable else {
            logger.info("iPhone not reachable — using cached data")
            return
        }
        isSyncing = true
        WCSession.default.sendMessage(
            ["action": "requestFullSync"],
            replyHandler: { _ in
                Task { @MainActor [weak self] in
                    self?.logger.info("Full sync requested successfully")
                }
            },
            errorHandler: { error in
                Task { @MainActor [weak self] in
                    self?.logger.error("Full sync request failed: \(error.localizedDescription)")
                    self?.isSyncing = false
                }
            }
        )
    }

    // MARK: - Fileprivate (called by SessionDelegate)

    fileprivate func handleSync(_ items: [WatchMangaTransferItem]) {
        guard let context = modelContainer?.mainContext else { return }

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
        lastSyncDate = Date()
        isSyncing = false
        logger.info("Sync completed: \(items.count) items")
    }

    fileprivate func handleActivationError(_ error: Error) {
        logger.error("WCSession activation failed: \(error.localizedDescription)")
    }

    fileprivate func handleActivationSuccess() {
        logger.info("WCSession activated")
    }
}

// MARK: - Session Delegate (non-isolated)

/// Receives WCSession callbacks on WCSession's private serial queue
/// and forwards state changes to the @MainActor owner via Task.
///
/// @unchecked Sendable is safe here because:
/// 1. WCSession serializes all delegate callbacks on its own queue
/// 2. The only mutable reference (`owner`) is a weak var — atomically
///    managed by the Objective-C runtime
/// 3. All access to `owner`'s state is performed inside
///    `Task { @MainActor }` closures
private final class SessionDelegate: NSObject, WCSessionDelegate, @unchecked Sendable {

    weak var owner: WatchSessionManager?

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        Task { @MainActor [weak self] in
            guard let self, let owner = self.owner else { return }
            if let error {
                owner.handleActivationError(error)
            } else {
                owner.handleActivationSuccess()
            }
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        guard let action = message["action"] as? String else { return }

        switch action {
        case "syncCollection":
            guard let raw = message["items"] as? String,
                  let data = raw.data(using: .utf8),
                  let items = try? JSONDecoder().decode(
                    [WatchMangaTransferItem].self,
                    from: data
                  ) else { return }

            Task { @MainActor [weak self] in
                self?.owner?.handleSync(items)
            }

        default:
            break
        }
    }
}
