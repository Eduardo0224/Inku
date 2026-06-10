//
//  InlineComplicationView.swift
//  InkuWatchWidget
//
//  Created by Eduardo Andrade on 02/06/26.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2026 Eduardo Andrade. All rights reserved.
//

import SwiftUI
import WidgetKit

// MARK: - Inline Complication View

struct InlineComplicationView: View {

    // MARK: - Properties

    let entry: WatchWidgetEntry

    // MARK: - Private Properties

    private let fallbackLabel = L10n.Watch.inkuCollection

    // MARK: - Body

    var body: some View {
        if entry.totalCollectionCount > 0 {
            ViewThatFits {
                Text(L10n.Watch.complicationInlineSummary(
                    reading: entry.readingCount,
                    total: entry.totalCollectionCount
                ))
                Text("\(entry.readingCount) / \(entry.totalCollectionCount) 📚")
                Text("📚 \(entry.totalCollectionCount)")
            }
        } else {
            Text(fallbackLabel)
        }
    }
}

// MARK: - Preview

#Preview("Inline - Active", as: .accessoryInline) {
    InkuWatchWidget()
} timeline: {
    WatchWidgetEntry(
        date: Date(),
        currentlyReading: "Death Note",
        currentChapter: "Vol. 12 / 12",
        readingProgressFraction: 1.0,
        latestCover: nil,
        latestTitle: "Death Note",
        readingCount: 2,
        totalCollectionCount: 12
    )
}

#Preview("Inline - Empty", as: .accessoryInline) {
    InkuWatchWidget()
} timeline: {
    WatchWidgetEntry(
        date: Date(),
        currentlyReading: nil,
        currentChapter: nil,
        readingProgressFraction: nil,
        latestCover: nil,
        latestTitle: nil,
        readingCount: 0,
        totalCollectionCount: 0
    )
}
