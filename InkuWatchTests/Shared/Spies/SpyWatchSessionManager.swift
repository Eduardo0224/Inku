//
//  SpyWatchSessionManager.swift
//  InkuWatchTests
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
@testable import InkuWatch

// MARK: - Spy Watch Session Manager

final class SpyWatchSessionManager: WatchSessionManagerProtocol {

    // MARK: - Properties (Spy Tracking)

    private(set) var requestFullSyncWasCalled = false

    // MARK: - Properties (Stub Data)

    var onSyncReceived: (([WatchMangaTransferItem]) -> Void)?

    // MARK: - WatchSessionManagerProtocol

    func requestFullSync() {
        requestFullSyncWasCalled = true
    }
}
