//
//  CornerComplicationView.swift
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

// MARK: - Corner Complication View

struct CornerComplicationView: View {

    // MARK: - Properties

    let entry: WatchWidgetEntry

    // MARK: - Private Properties

    private let readingLabel = L10n.Watch.statusReading
    private let fallbackLabel = L10n.Watch.inkuCollection

    // MARK: - Body

    var body: some View {
        if entry.readingCount > 0 {
            Text("\(entry.readingCount)")
                .font(.title2)
                .foregroundStyle(Color.inkuAccent)
                .containerBackground(Color.inkuSurfaceSecondary, for: .widget)
                .widgetLabel {
                    Text(readingLabel)
                }
        } else {
            Image(systemName: "books.vertical.fill")
                .font(.title3)
                .foregroundStyle(Color.inkuTextSecondary)
                .containerBackground(Color.inkuSurfaceSecondary, for: .widget)
                .widgetLabel {
                    Text(fallbackLabel)
                }
        }
    }
}

// MARK: - Preview

#Preview("Corner - Active", as: .accessoryCorner) {
    InkuWatchWidget()
} timeline: {
    WatchWidgetEntry(
        date: Date(),
        currentlyReading: "One Piece",
        currentChapter: "Vol. 51 / 106",
        readingProgressFraction: 0.48,
        latestCover: nil,
        latestTitle: "Attack on Titan",
        readingCount: 3,
        totalCollectionCount: 47
    )
}

#Preview("Corner - Empty", as: .accessoryCorner) {
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
