//
//  WatchCollectionViewModel.swift
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
import SwiftData
import Observation
import OSLog

// MARK: - Watch Collection ViewModel

@Observable
@MainActor
final class WatchCollectionViewModel {

    // MARK: - Private Properties

    @ObservationIgnored
    private let interactor: WatchCollectionInteractorProtocol

    @ObservationIgnored
    private let logger = Logger.inkuWatch

    // MARK: - Properties

    var allMangas: [WatchMangaItem] = []
    var nowReading: [WatchMangaItem] = []
    var completed: [WatchMangaItem] = []

    var totalMangas: Int { allMangas.count }
    var totalVolumesOwned: Int { allMangas.reduce(0) { $0 + $1.volumesOwned } }
    var completedCount: Int { completed.count }
    var readingCount: Int { nowReading.count }

    var averageProgress: Double {
        let withProgress = allMangas.compactMap { $0.readingProgress }
        guard !withProgress.isEmpty else { return 0 }
        return withProgress.reduce(0, +) / Double(withProgress.count)
    }

    var completionPercentage: Double {
        let withTotal = allMangas.filter { $0.totalVolumes != nil }
        guard !withTotal.isEmpty else { return 0 }
        let complete = withTotal.filter { $0.isComplete }.count
        return Double(complete) / Double(withTotal.count)
    }

    // MARK: - Initializers

    init(sessionManager: WatchSessionManagerProtocol) {
        self.interactor = WatchCollectionInteractor(sessionManager: sessionManager)
    }

    init(interactor: WatchCollectionInteractorProtocol) {
        self.interactor = interactor
    }

    // MARK: - Functions

    func loadMangas(context: ModelContext) {
        do {
            allMangas = try interactor.fetchAll(context: context)
            nowReading = try interactor.fetchReading(context: context)
            completed = try interactor.fetchCompleted(context: context)
        } catch {
            logger.error("Failed to load mangas: \(error.localizedDescription)")
        }
    }

    func configureSession(with container: ModelContainer) {
        interactor.configureSession(with: container)
    }

    func syncFromiPhone() {
        interactor.syncFromiPhone()
    }

    func checkSimulatorSync(context: ModelContext) {
        do {
            try interactor.checkSimulatorSync(context: context)
            loadMangas(context: context)
        } catch {
            logger.error("Simulator sync failed: \(error.localizedDescription)")
        }
    }
}
