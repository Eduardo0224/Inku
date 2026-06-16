//
//  WatchCollectionInteractorProtocol.swift
//  InkuWatch
//
//  Created by Eduardo Andrade on 10/06/26.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2026 Eduardo Andrade. All rights reserved.
//

import Foundation
import SwiftData

// MARK: - Watch Collection Interactor Protocol

protocol WatchCollectionInteractorProtocol {

    // MARK: - Functions

    func configureSession(with container: ModelContainer)
    func syncFromiPhone()
    func checkSimulatorSync(context: ModelContext) throws

    func fetchAll(context: ModelContext) throws -> [WatchMangaItem]
    func fetchReading(context: ModelContext) throws -> [WatchMangaItem]
    func fetchCompleted(context: ModelContext) throws -> [WatchMangaItem]
    func applyTransferItems(_ items: [WatchMangaTransferItem], context: ModelContext) throws
}
