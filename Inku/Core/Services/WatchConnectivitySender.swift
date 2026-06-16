//
//  WatchConnectivitySender.swift
//  Inku
//
//  Created by Eduardo Andrade on 02/06/26.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2026 Eduardo Andrade. All rights reserved.
import Foundation
import WatchConnectivity
import SwiftData
import OSLog
internal import UIKit

// MARK: - Watch Connectivity Sender

@MainActor
@Observable
final class WatchConnectivitySender: WatchConnectivitySenderProtocol {

    // MARK: - Private Properties

    private let logger = Logger.inkuWatch
    private let sessionDelegate = SessionDelegate()

    // MARK: - Properties

    /// Called on `@MainActor` when the watch requests a full sync.
    /// The owner (CollectionViewModel) sets this to trigger data delivery.
    var onFullSyncRequested: (() async -> Void)?

    private(set) var isWatchReachable = false

    // MARK: - Initializers

    init() {
        sessionDelegate.owner = self
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        session.delegate = sessionDelegate
        session.activate()
    }

    // MARK: - Functions

    func sendCollection(_ mangas: [CollectionManga]) async {
        let items = await buildTransferItems(from: mangas)

        SimulatorSyncWriter.exportCollection(items)

        guard WCSession.default.isReachable else {
            logger.info("Watch not reachable — sync deferred (simulator file exported)")
            return
        }

        guard let data = try? JSONEncoder().encode(items),
              let json = String(data: data, encoding: .utf8) else {
            logger.error("Failed to encode transfer items")
            return
        }

        WCSession.default.sendMessage(
            ["action": "syncCollection", "items": json],
            replyHandler: { _ in
                Task { @MainActor [weak self] in
                    self?.logger.info("Collection sent to watch: \(items.count) items")
                }
            },
            errorHandler: { error in
                Task { @MainActor [weak self] in
                    self?.logger.error("Send failed: \(error.localizedDescription)")
                }
            }
        )
    }

    // MARK: - Fileprivate (called by SessionDelegate)

    fileprivate func handleActivation(reachable: Bool) {
        isWatchReachable = reachable
    }

    fileprivate func handleReachabilityChange(reachable: Bool) {
        isWatchReachable = reachable
    }

    fileprivate func handleFullSyncRequest() {
        logger.info("Watch requested full sync — forwarding to owner")
        Task { [weak self] in
            await self?.onFullSyncRequested?()
        }
    }

    fileprivate func logActivationError(_ error: Error) {
        logger.error("WCSession activation failed: \(error.localizedDescription)")
    }

    fileprivate func logActivationSuccess() {
        logger.info("WCSession activated")
    }

    // MARK: - Private Functions

    private func buildTransferItems(from mangas: [CollectionManga]) async -> [WatchMangaTransferItem] {
        var items: [WatchMangaTransferItem] = []

        for manga in mangas {
            let coverBase64 = await coverImageJPEGBase64(for: manga)
            items.append(WatchMangaTransferItem(
                from: manga,
                coverJPEGBase64: coverBase64
            ))
        }

        return items
    }

    private func coverImageJPEGBase64(for manga: CollectionManga) async -> String? {
        guard let url = manga.coverURL else { return nil }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else { return nil }

            let maxDimension: CGFloat = 200
            let size = image.size
            let scale = min(maxDimension / max(size.width, size.height), 1.0)

            let resized: UIImage
            if scale < 1.0 {
                let target = CGSize(
                    width: (size.width * scale).rounded(),
                    height: (size.height * scale).rounded()
                )
                let format = UIGraphicsImageRendererFormat()
                format.scale = 1
                let renderer = UIGraphicsImageRenderer(size: target, format: format)
                resized = renderer.image { _ in
                    image.draw(in: CGRect(origin: .zero, size: target))
                }
            } else {
                resized = image
            }

            return resized.jpegData(compressionQuality: 0.7)?.base64EncodedString()
        } catch {
            logger.error("Cover download failed for \(manga.title): \(error.localizedDescription)")
            return nil
        }
    }
}

// MARK: - Session Delegate (non-isolated)

private final class SessionDelegate: NSObject, WCSessionDelegate, @unchecked Sendable {

    weak var owner: WatchConnectivitySender?

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        let reachable = session.isReachable
        Task { @MainActor [weak self] in
            guard let self, let owner = self.owner else { return }
            if let error {
                owner.logActivationError(error)
            } else {
                owner.logActivationSuccess()
            }
            owner.handleActivation(reachable: reachable)
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {}

    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        let reachable = session.isReachable
        Task { @MainActor [weak self] in
            self?.owner?.handleReachabilityChange(reachable: reachable)
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        guard let action = message["action"] as? String,
              action == "requestFullSync" else { return }

        Task { @MainActor [weak self] in
            self?.owner?.handleFullSyncRequest()
        }
    }
}
