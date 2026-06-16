//
//  WatchStatsData.swift
//  InkuWatch
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

// MARK: - Watch Stats Data

/// Value-type snapshot of the collection statistics, derived from
/// `WatchCollectionViewModel` computed properties.
///
/// Using a plain struct keeps child views decoupled from the ViewModel
/// while still benefiting from `@Observable` reactivity — when the
/// parent recomputes this struct, SwiftUI re-renders the stats view.
struct WatchStatsData: Equatable {
    let totalMangas: Int
    let totalVolumesOwned: Int
    let completedCount: Int
    let readingCount: Int
    let averageProgress: Double
    let completionPercentage: Double
}
