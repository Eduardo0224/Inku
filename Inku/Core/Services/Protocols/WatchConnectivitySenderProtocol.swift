//
//  WatchConnectivitySenderProtocol.swift
//  Inku
//
//  Created by Eduardo Andrade on 16/06/26.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2026 Eduardo Andrade. All rights reserved.
//

import Foundation

// MARK: - Watch Connectivity Sender Protocol

@MainActor
protocol WatchConnectivitySenderProtocol: AnyObject {

    // MARK: - Properties

    /// Called on `@MainActor` when the watch requests a full sync.
    var onFullSyncRequested: (() async -> Void)? { get set }

    var isWatchReachable: Bool { get }

    // MARK: - Functions

    /// Sends the collection to the watch via WCSession and exports to simulator.
    func sendCollection(_ mangas: [CollectionManga]) async
}
