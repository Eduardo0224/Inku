//
//  EmptyWidgetView.swift
//  Inku
//
//  Created by Eduardo Andrade on 10/02/26.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2026 Eduardo Andrade. All rights reserved.

import SwiftUI
import WidgetKit
import InkuUI

struct EmptyWidgetView: View {

    // MARK: - Environment

    @Environment(\.widgetFamily) private var widgetFamily

    // MARK: - Body

    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            smallEmptyView
        case .systemMedium, .systemLarge:
            regularEmptyView
        case .systemExtraLarge:
            extraLargeEmptyView
        default:
            regularEmptyView
        }
    }

    // MARK: - Private Views

    private var smallEmptyView: some View {
        VStack(spacing: InkuSpacing.spacing12) {
            Image(systemName: "books.vertical")
                .font(.system(size: 40))
                .foregroundStyle(Color.inkuAccent)

            Text(L10n.Widget.emptyTitleCompact)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundStyle(Color.inkuText)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var regularEmptyView: some View {
        VStack(spacing: InkuSpacing.spacing12) {
            Image(systemName: "books.vertical")
                .font(.system(size: 40))
                .foregroundStyle(Color.inkuAccent)

            VStack(spacing: InkuSpacing.spacing4) {
                Text(L10n.Widget.emptyTitle)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.inkuText)

                Text(L10n.Widget.emptyMessage)
                    .font(.caption)
                    .foregroundStyle(Color.inkuTextSecondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var extraLargeEmptyView: some View {
        VStack(spacing: InkuSpacing.spacing16) {
            Image(systemName: "books.vertical")
                .font(.system(size: 60))
                .foregroundStyle(Color.inkuAccent)
                .symbolEffect(.pulse)

            VStack(spacing: InkuSpacing.spacing8) {
                Text(L10n.Widget.emptyTitle)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.inkuText)

                Text(L10n.Widget.emptyMessage)
                    .font(.subheadline)
                    .foregroundStyle(Color.inkuTextSecondary)

                Text(L10n.Widget.emptyHint)
                    .font(.caption)
                    .foregroundStyle(Color.inkuTextTertiary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Preview

#Preview("Empty Small", as: .systemSmall) {
    InkuCollectionWidget()
} timeline: {
    InkuWidgetEntry(date: .now, mangas: [])
}

#Preview("Empty Medium", as: .systemMedium) {
    InkuCollectionWidget()
} timeline: {
    InkuWidgetEntry(date: .now, mangas: [])
}

#Preview("Empty Large", as: .systemLarge) {
    InkuCollectionWidget()
} timeline: {
    InkuWidgetEntry(date: .now, mangas: [])
}

#Preview("Empty Extra Large", as: .systemExtraLarge) {
    InkuCollectionWidget()
} timeline: {
    InkuWidgetEntry(date: .now, mangas: [])
}
