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
import OSLog

// MARK: - Watch Session Manager

@MainActor
final class WatchSessionManager: WatchSessionManagerProtocol {

    // MARK: - Private Properties

    private let logger = Logger.inkuWatch
    private let sessionDelegate = SessionDelegate()

    // MARK: - Properties

    /// Called on `@MainActor` when a sync payload arrives from the iPhone.
    /// The Interactor registers this to own the data-persistence step.
    var onSyncReceived: (([WatchMangaTransferItem]) -> Void)?

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

    /// Requests a full sync from the iOS app.
    func requestFullSync() {
        guard WCSession.default.isReachable else {
            logger.info("iPhone not reachable — using cached data")
            return
        }
        isSyncing = true
        WCSession.default.sendMessage(
            ["action": "requestFullSync"],
            replyHandler: { [weak self] _ in
                Task { @MainActor in
                    guard let self else { return }
                    self.isSyncing = false
                    self.logger.info("Full sync requested successfully")
                }
            },
            errorHandler: { [weak self] error in
                Task { @MainActor in
                    guard let self else { return }
                    self.logger.error("Full sync request failed: \(error.localizedDescription)")
                    self.isSyncing = false
                }
            }
        )
    }

    /// Forwards incoming sync items to the registered callback (the Interactor).
    func handleSync(_ items: [WatchMangaTransferItem]) {
        lastSyncDate = Date()
        isSyncing = false
        logger.info("Sync received: \(items.count) items — forwarding to interactor")
        onSyncReceived?(items)
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
            handleSyncPayload(message)
        default:
            break
        }
    }

    /// Receives larger payloads sent via `transferUserInfo` (no ~100KB limit).
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any]) {
        guard let action = userInfo["action"] as? String else { return }

        switch action {
        case "syncCollection":
            handleSyncPayload(userInfo)
        default:
            break
        }
    }

    // MARK: - Private Helpers

    private func handleSyncPayload(_ payload: [String: Any]) {
        guard let raw = payload["items"] as? String,
              let data = raw.data(using: .utf8),
              let items = try? JSONDecoder().decode(
                [WatchMangaTransferItem].self,
                from: data
              ) else { return }

        Task { @MainActor [weak self] in
            self?.owner?.handleSync(items)
        }
    }
}
