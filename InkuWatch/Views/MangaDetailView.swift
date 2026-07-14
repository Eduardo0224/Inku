//
//  MangaDetailView.swift
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

// MARK: - Manga Detail View

struct MangaDetailView: View {

    // MARK: - Properties

    let item: WatchMangaDisplayItem

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .top) {
            backgroundImageView

            ScrollView {
                VStack(spacing: InkuSpacing.spacing12) {
                    coverSection
                    infoSection
                    progressSection
                }
                .padding(.horizontal, InkuSpacing.spacing12)
                .padding(.top, InkuSpacing.spacing16)
            }
        }
        .navigationTitle(item.title)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.inkuSurface)
    }

    // MARK: - Private Views

    private var backgroundImageView: some View {
        Group {
            if let image = coverImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .blur(radius: 25)
            } else {
                Color.inkuSurface
            }
        }
        .frame(height: 160)
        .clipped()
        .overlay {
            Rectangle()
                .fill(.thinMaterial)
        }
        .overlay(alignment: .bottom) {
            LinearGradient(
                gradient: Gradient(
                    colors: [.clear, Color.inkuSurface]
                ),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 60)
        }
        .ignoresSafeArea(edges: .top)
        .ignoresSafeArea(edges: .horizontal)
    }

    private var coverSection: some View {
        Group {
            if let image = coverImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 120, maxHeight: 180)
                    .clipShape(RoundedRectangle(cornerRadius: InkuRadius.radius8))
                    .shadow(color: .black.opacity(0.3), radius: 8, y: 4)
            } else {
                RoundedRectangle(cornerRadius: InkuRadius.radius8)
                    .fill(.quaternary)
                    .frame(width: 120, height: 180)
                    .overlay {
                        Image(systemName: "book.closed")
                            .font(.title)
                            .foregroundStyle(.secondary)
                    }
            }
        }
    }

    private var infoSection: some View {
        VStack(spacing: InkuSpacing.spacing4) {
            if let japanese = item.japaneseTitle {
                Text(japanese)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            if let score = item.score {
                HStack(spacing: InkuSpacing.spacing4) {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundColor(.yellow)

                    Text(score.formatted(.number.precision(.fractionLength(1))))
                        .font(.caption)
                }
            }

            Text(statusText)
                .font(.caption2)
                .foregroundStyle(Color.inkuAccentStrong)
        }
    }

    private var progressSection: some View {
        VStack(spacing: InkuSpacing.spacing8) {
            if let progress = item.readingProgress {
                VStack(spacing: InkuSpacing.spacing4) {
                    HStack {
                        Text(L10n.Watch.progress)
                            .font(.caption)
                        Spacer()
                        Text("\(item.volumesOwned) / \(item.totalVolumes ?? 0)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }

                    ProgressView(value: progress)
                        .tint(.inkuAccent)
                }
            }

            if let current = item.currentReadingVolume {
                HStack {
                    Text(L10n.Watch.currentVolume)
                        .font(.caption)
                    Spacer()
                    Text(L10n.Watch.volumeFormat(current))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: - Private Properties

    private var statusText: String {
        if item.isComplete { return L10n.Watch.statusCompleted }
        if item.isCurrentlyReading { return L10n.Watch.statusReading }
        return L10n.Watch.statusInCollection
    }

    private var coverImage: PlatformImage? {
        guard let data = item.coverImageData else { return nil }
        return PlatformImage(data: data)
    }
}

// MARK: - Preview

#Preview("Detail with cover") {
    MangaDetailView(item: .berserk)
}

#Preview("Detail without cover") {
    MangaDetailView(
        item: WatchMangaDisplayItem(
            mangaId: 99,
            title: "Unknown Manga",
            volumesOwned: 5,
            totalVolumes: 10,
            currentReadingVolume: 6,
            hasCompleteCollection: false,
            dateAdded: Date()
        )
    )
}
