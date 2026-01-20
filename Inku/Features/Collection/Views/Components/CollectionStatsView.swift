//
//  CollectionStatsView.swift
//  Inku
//
//  Created by Eduardo Andrade on 08/01/26.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2026 Eduardo Andrade. All rights reserved.
//

import SwiftUI
import InkuUI

struct CollectionStatsView: View {

    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss
    @Environment(\.collectionViewModel) private var viewModel

    // MARK: - States

    @State private var statsDetent: PresentationDetent = .medium

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: InkuSpacing.spacing24) {
                    if statsDetent == .medium {
                        mediumStatsView
                    } else {
                        largeStatsView
                    }
                }
            }
            .background(Color.inkuSurface)
            .navigationTitle(L10n.Collection.Stats.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .symbolVariant(.circle.fill)
                            .foregroundStyle(Color.inkuTextSecondary)
                    }
                }
            }
        }
        .presentationDetents(
            [.medium, .large],
            selection: $statsDetent
        )
    }

    // MARK: - Private Views

    // MARK: Medium Stats (.medium)

    private var mediumStatsView: some View {
        VStack(spacing: InkuSpacing.spacing24) {
            Text(L10n.Collection.Stats.overview)
                .font(.inkuDisplayMedium)
                .foregroundStyle(Color.inkuText)
                .frame(maxWidth: .infinity, alignment: .leading)

            statsGrid {
                basicStatsGroup
                collectionStatusGroup
            }
        }
        .padding(InkuSpacing.spacing16)
    }

    // MARK: Large Stats (.large)

    private var largeStatsView: some View {
        VStack(spacing: InkuSpacing.spacing24) {
            Text(L10n.Collection.Stats.overview)
                .font(.inkuDisplayMedium)
                .foregroundStyle(Color.inkuText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, InkuSpacing.spacing16)

            statsGrid {
                basicStatsGroup
                collectionStatusGroup
                progressStatsGroup
            }
            .padding(.horizontal, InkuSpacing.spacing16)

            let topMangas = viewModel.getTopSeriesByVolumes(limit: 3)
            if topMangas.count >= 3 {
                Text(L10n.Collection.Stats.topSeries)
                    .font(.inkuDisplayMedium)
                    .foregroundStyle(Color.inkuText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, InkuSpacing.spacing16)

                podiumView(mangas: topMangas)
                    .padding(.vertical, InkuSpacing.spacing16)
            }

            Text(L10n.Collection.Stats.recentlyAdded)
                .font(.inkuDisplayMedium)
                .foregroundStyle(Color.inkuText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, InkuSpacing.spacing16)

            let recentlyAdded = viewModel.getMostRecentlyAdded(limit: 6)
            if !recentlyAdded.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: InkuSpacing.spacing16) {
                        ForEach(recentlyAdded) { manga in
                            recentCoverCard(manga: manga)
                        }
                    }
                }
                .contentMargins(InkuSpacing.spacing16, for: .scrollContent)
            }
        }
    }

    // MARK: - Reusable Grid Wrapper

    private func statsGrid<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ],
            spacing: InkuSpacing.spacing16
        ) {
            content()
        }
    }

    // MARK: - Stats Groups

    @ViewBuilder
    private var basicStatsGroup: some View {
        InkuStatCard(
            icon: "books.vertical.fill",
            value: "\(viewModel.totalMangas)",
            label: L10n.Collection.Stats.totalMangas,
            size: .large,
            accentColor: .inkuAccent
        )

        InkuStatCard(
            icon: "book.fill",
            value: "\(viewModel.totalVolumesOwned)",
            label: L10n.Collection.Stats.totalVolumes,
            size: .large,
            accentColor: .inkuAccentStrong
        )
    }

    @ViewBuilder
    private var collectionStatusGroup: some View {
        InkuStatCard(
            icon: "checkmark.circle.fill",
            value: "\(viewModel.completedCount)",
            label: L10n.Collection.Stats.completed,
            size: .large,
            accentColor: .green
        )

        InkuStatCard(
            icon: "book.pages.fill",
            value: "\(viewModel.readingCount)",
            label: L10n.Collection.Stats.reading,
            size: .large,
            accentColor: .blue
        )
    }

    @ViewBuilder
    private var progressStatsGroup: some View {
        InkuStatCard(
            icon: "chart.bar.fill",
            value: viewModel.averageProgress.formatted(
                .percent.precision(.integerAndFractionLength(integer: 1, fraction: 1))
            ),
            label: L10n.Collection.Stats.averageProgress,
            size: .large,
            accentColor: .orange
        )

        InkuStatCard(
            icon: "percent",
            value: viewModel.completionPercentage.formatted(
                .percent.precision(.integerAndFractionLength(integer: 1, fraction: 1))
            ),
            label: L10n.Collection.Stats.completionRate,
            size: .large,
            accentColor: .purple
        )
    }

    // MARK: - Helper Views

    // MARK: Podium View

    private func podiumView(mangas: [CollectionManga]) -> some View {
        ZStack(alignment: .bottom) {
            Color.inkuSurfaceElevated

            if mangas.count > 2 {
                podiumItem(manga: mangas[2], rank: 3, size: .small)
                    .offset(x: 100, y: 10)
                    .zIndex(1)
            }

            if mangas.count > 1 {
                podiumItem(manga: mangas[1], rank: 2, size: .medium)
                    .offset(x: -100, y: 5)
                    .zIndex(2)
            }

            podiumItem(manga: mangas[0], rank: 1, size: .large)
                .zIndex(3)
        }
    }

    private func podiumItem(manga: CollectionManga, rank: Int, size: PodiumSize) -> some View {
        VStack(spacing: InkuSpacing.spacing8) {
            Text(manga.title)
                .font(size.titleFont)
                .bold()
                .foregroundStyle(Color.inkuText)
                .lineLimit(2)
                .truncationMode(.tail)
                .multilineTextAlignment(.center)
                .frame(width: size.coverWidth, height: 40, alignment: .bottom)
                .fixedSize(horizontal: false, vertical: true)

            if let url = manga.coverURL {
                InkuCoverImage(url: url, cornerRadius: InkuRadius.radius12)
                    .frame(width: size.coverWidth, height: size.coverHeight)
                    .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
            } else {
                Rectangle()
                    .fill(Color.inkuSurfaceSecondary)
                    .frame(width: size.coverWidth, height: size.coverHeight)
                    .clipShape(RoundedRectangle(cornerRadius: InkuRadius.radius12))
                    .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
            }

            ZStack {
                Circle()
                    .fill(rankColor(rank))
                    .frame(width: size.badgeSize, height: size.badgeSize)
                    .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)

                Text("\(rank)")
                    .font(size.badgeFont)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.white)
            }
            .padding(InkuSpacing.spacing16)
        }
        .padding(.vertical, InkuSpacing.spacing16)
    }

    // MARK: Podium Size Configuration

    private enum PodiumSize {
        case small, medium, large

        var coverWidth: CGFloat {
            switch self {
            case .small: return 120
            case .medium: return 130
            case .large: return 150
            }
        }

        var coverHeight: CGFloat {
            coverWidth * 1.5
        }

        var badgeSize: CGFloat {
            switch self {
            case .small: return 34
            case .medium: return 38
            case .large: return 44
            }
        }

        var badgeFont: Font {
            switch self {
            case .small: return .inkuBody
            case .medium: return .inkuHeadline
            case .large: return .inkuHeadline
            }
        }

        var titleFont: Font {
            switch self {
            case .small: return .inkuCaption
            case .medium: return .inkuCaption
            case .large: return .inkuBody
            }
        }
    }

    private func recentCoverCard(manga: CollectionManga) -> some View {
        VStack(spacing: InkuSpacing.spacing8) {
            if let url = manga.coverURL {
                InkuCoverImage(url: url, cornerRadius: InkuRadius.radius12)
                    .frame(width: 100, height: 150)
            } else {
                Rectangle()
                    .fill(Color.inkuSurfaceSecondary)
                    .frame(width: 100, height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: InkuRadius.radius12))
            }

            Text(manga.title)
                .font(.inkuCaption)
                .foregroundStyle(Color.inkuText)
                .lineLimit(2)
                .truncationMode(.tail)
                .multilineTextAlignment(.center)
                .frame(width: 100, height: 34, alignment: .top)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(height: 192)
    }

    private func rankColor(_ rank: Int) -> Color {
        switch rank {
        case 1: return .inkuWarning
        case 2: return .inkuTextSecondary
        case 3: return .inkuAccentStrong
        default: return .inkuAccent
        }
    }
}

// MARK: - Previews

#Preview("Collection Stats - Empty") {
    CollectionStatsView()
        .environment(\.collectionViewModel, MockCollectionViewModel.empty)
}

#Preview("Collection Stats - With Data") {
    CollectionStatsView()
        .environment(\.collectionViewModel, MockCollectionViewModel.withData)
}
