//
//  WatchSessionManagerProtocol.swift
//  InkuWatch
//
//  Created by Eduardo Andrade on 12/06/26.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2026 Eduardo Andrade. All rights reserved.
//

import Foundation

// MARK: - Watch Session Manager Protocol

protocol WatchSessionManagerProtocol: AnyObject {

    // MARK: - Properties

    /// Called on `@MainActor` when a sync payload arrives from the iPhone.
    /// The Interactor registers this to own the data-persistence step.
    var onSyncReceived: (([WatchMangaTransferItem]) -> Void)? { get set }

    // MARK: - Functions

    /// Requests a full collection sync from the iOS app.
    func requestFullSync()
}
