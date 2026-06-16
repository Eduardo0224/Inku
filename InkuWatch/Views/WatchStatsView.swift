//
//  WatchStatsView.swift
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

import SwiftUI
import InkuUI

// MARK: - Stat Item

private struct StatItem: Identifiable {
    let id = UUID()
    let icon: String
    let value: String
    let label: String
    let accentColor: Color
}

// MARK: - Watch Stats View

struct WatchStatsView: View {

    // MARK: - Properties

    let data: WatchStatsData

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: InkuSpacing.spacing12) {
                ForEach(stats) { stat in
                    InkuStatCard(
                        icon: stat.icon,
                        value: stat.value,
                        label: stat.label,
                        size: .compact,
                        accentColor: stat.accentColor
                    )
                }
            }
            .padding(.horizontal, InkuSpacing.spacing4)
            .padding(.vertical, InkuSpacing.spacing12)
        }
        .navigationTitle(L10n.Collection.Stats.title)
        .background(Color.inkuSurface)
    }

    // MARK: - Private Functions

    private var stats: [StatItem] {
        [
            StatItem(
                icon: "books.vertical.fill",
                value: "\(data.totalMangas)",
                label: L10n.Collection.Stats.totalMangas,
                accentColor: .inkuAccent
            ),
            StatItem(
                icon: "book.fill",
                value: "\(data.totalVolumesOwned)",
                label: L10n.Collection.Stats.totalVolumes,
                accentColor: .inkuAccentStrong
            ),
            StatItem(
                icon: "checkmark.circle.fill",
                value: "\(data.completedCount)",
                label: L10n.Collection.Stats.completed,
                accentColor: .green
            ),
            StatItem(
                icon: "book.pages.fill",
                value: "\(data.readingCount)",
                label: L10n.Collection.Stats.reading,
                accentColor: .blue
            ),
            StatItem(
                icon: "chart.bar.fill",
                value: data.averageProgress.formatted(
                    .percent.precision(.integerAndFractionLength(integer: 1, fraction: 1))
                ),
                label: L10n.Collection.Stats.averageProgress,
                accentColor: .orange
            ),
            StatItem(
                icon: "percent",
                value: data.completionPercentage.formatted(
                    .percent.precision(.integerAndFractionLength(integer: 1, fraction: 1))
                ),
                label: L10n.Collection.Stats.completionRate,
                accentColor: .purple
            ),
        ]
    }
}

// MARK: - Preview

#Preview("Stats") {
    NavigationStack {
        WatchStatsView(
            data: WatchStatsData(
                totalMangas: 42,
                totalVolumesOwned: 520,
                completedCount: 15,
                readingCount: 8,
                averageProgress: 0.65,
                completionPercentage: 0.36
            )
        )
    }
}
