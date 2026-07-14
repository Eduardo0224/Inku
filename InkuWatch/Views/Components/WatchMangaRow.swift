//
//  WatchMangaRow.swift
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

import SwiftUI
import InkuUI

// MARK: - Watch Manga Row

struct WatchMangaRow: View {

    // MARK: - Properties

    let item: WatchMangaDisplayItem

    // MARK: - Body

    var body: some View {
        HStack(spacing: InkuSpacing.spacing8) {
            coverView
            infoView
        }
        .padding(.vertical, InkuSpacing.spacing4)
    }

    // MARK: - Private Computed Properties

    private var statusText: String {
        if item.isComplete { return L10n.Watch.statusCompleted }
        if item.isCurrentlyReading { return L10n.Watch.statusReading }
        return L10n.Watch.statusInCollection
    }

    // MARK: - Private Views

    private var coverView: some View {
        Group {
            if let data = item.coverImageData,
               let image = PlatformImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Rectangle()
                    .fill(Color.inkuSurfaceSecondary)
                    .overlay {
                        Image(systemName: "book.closed")
                            .font(.caption2)
                            .foregroundStyle(Color.inkuTextTertiary)
                    }
            }
        }
        .frame(width: 40, height: 60)
        .clipShape(RoundedRectangle(cornerRadius: InkuRadius.radius8))
    }

    private var infoView: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(item.title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(Color.inkuText)
                .lineLimit(2)

            if let progress = item.readingProgress {
                ProgressView(value: progress)
                    .tint(.inkuAccent)
                    .scaleEffect(0.8)
            }

            Text(statusText)
                .font(.caption2)
                .foregroundStyle(Color.inkuTextSecondary)
        }
    }
}

// MARK: - Preview

#Preview("Row") {
    List {
        WatchMangaRow(item: .berserk)
            .listRowBackground(
                RoundedRectangle(cornerRadius: InkuRadius.radius12)
                    .fill(Color.inkuSurfaceElevated)
                    .padding(.horizontal, InkuSpacing.spacing4)
            )
    }
    .listStyle(.carousel)
    .background(Color.inkuSurface)
}
