//
//  CircularComplicationView.swift
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

// MARK: - Circular Complication View

struct CircularComplicationView: View {

    // MARK: - Properties

    let entry: WatchWidgetEntry

    // MARK: - Body

    var body: some View {
        if let fraction = entry.readingProgressFraction {
            Gauge(value: fraction, in: 0...1) {
                Image(systemName: "book.closed.fill")
            } currentValueLabel: {
                Text("\(entry.readingCount)")
            }
            .gaugeStyle(.accessoryCircularCapacity)
            .containerBackground(Color.inkuSurfaceSecondary, for: .widget)
        } else {
            Image(systemName: "book.closed.fill")
                .font(.title3)
                .foregroundStyle(Color.inkuTextSecondary)
                .containerBackground(Color.inkuSurfaceSecondary, for: .widget)
        }
    }
}

// MARK: - Preview

#Preview("Circular - With Progress", as: .accessoryCircular) {
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

#Preview("Circular - Empty", as: .accessoryCircular) {
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
