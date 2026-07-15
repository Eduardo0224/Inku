//
//  RectangularComplicationView.swift
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
import InkuUI

// MARK: - Rectangular Complication View

struct RectangularComplicationView: View {

    // MARK: - Properties

    let entry: WatchWidgetEntry

    // MARK: - Private Properties

    private let noActiveReading = L10n.Watch.noActiveReading

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            if let title = entry.currentlyReading {
                Text(title)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .widgetAccentable()
            }

            if let chapter = entry.currentChapter {
                Text(chapter)
                    .font(.caption2)
                    .foregroundStyle(Color.inkuTextSecondary)
            }

            if entry.currentlyReading == nil {
                Text(noActiveReading)
                    .font(.caption2)
                    .foregroundStyle(Color.inkuTextSecondary)
            }
        }
        .containerBackground(Color.inkuSurfaceSecondary, for: .widget)
    }
}

// MARK: - Preview

#Preview("Rectangular - Active", as: .accessoryRectangular) {
    InkuWatchWidget()
} timeline: {
    WatchWidgetEntry(
        date: Date(),
        currentlyReading: "One Piece",
        currentChapter: "Vol. 51 / 106",
        readingProgressFraction: 0.48,
        latestCover: nil,
        latestTitle: "One Piece",
        readingCount: 3,
        totalCollectionCount: 47
    )
}

#Preview("Rectangular - Empty", as: .accessoryRectangular) {
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
