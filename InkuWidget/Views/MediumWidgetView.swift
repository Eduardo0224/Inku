//
//  MediumWidgetView.swift
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

struct MediumWidgetView: View {

    // MARK: - Properties

    let entry: InkuWidgetEntry

    // MARK: - Computed Properties

    private var coverSize: CGSize {
        .init(width: 80, height: 105)
    }

    // MARK: - Body

    var body: some View {
        if entry.isEmpty {
            EmptyWidgetView()
        } else {
            contentView
        }
    }

    // MARK: - Private Views

    private var contentView: some View {
        HStack(spacing: InkuSpacing.spacing8) {
            ForEach(entry.mangas.prefix(2)) { manga in
                mangaCard(manga)
            }
        }
        .padding(InkuSpacing.spacing2)
    }

    private func mangaCard(_ manga: WidgetMangaData) -> some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: InkuSpacing.spacing8) {
                coverImage(for: manga)

                mangaInfo(manga)
            }
            .frame(maxWidth: .infinity)
            Spacer(minLength: 8)
            progressSection(for: manga)
        }
    }

    @ViewBuilder
    private func coverImage(for manga: WidgetMangaData) -> some View {
        if let url = manga.coverImageURL {
            WidgetCoverImage(
                imageData: manga.coverImageData,
                url: url,
                cornerRadius: InkuRadius.radius8
            )
            .frame(width: coverSize.width, height: coverSize.height)
            .shadow(color: .black.opacity(0.2), radius: 8)
        }
    }

    private func mangaInfo(_ manga: WidgetMangaData) -> some View {
        VStack(alignment: .leading, spacing: InkuSpacing.spacing4) {
            mangaTitles(manga)
            Spacer()
            volumeCount(manga)
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func mangaTitles(_ manga: WidgetMangaData) -> some View {
        VStack(alignment: .leading, spacing: InkuSpacing.spacing2) {
            Text(manga.title)
                .font(.inkuBodySmall)
                .fontWeight(.semibold)
                .foregroundStyle(Color.inkuText)
                .lineLimit(2)

            if let japaneseTitle = manga.japaneseTitle {
                Text(japaneseTitle)
                    .font(.inkuCaptionSmall)
                    .foregroundStyle(Color.inkuTextTertiary)
                    .lineLimit(1)
            }
        }
    }

    private func volumeCount(_ manga: WidgetMangaData) -> some View {
        Text("\(manga.volumesOwned)/\(manga.totalVolumes ?? 0)")
            .font(.inkuCaptionSmall)
            .foregroundStyle(Color.inkuTextSecondary)
    }

    @ViewBuilder
    private func progressSection(for manga: WidgetMangaData) -> some View {
        if let progress = manga.progress {
            InkuProgressBar(
                progress: progress,
                showPercentage: false
            )
        } else {
            volumeBadge(manga.volumesOwned)
        }
    }

    private func volumeBadge(_ count: Int) -> some View {
        let volumeLabel = count == 1 
            ? L10n.Collection.Card.volumeSingular 
            : L10n.Collection.Card.volumePlural
        
        return Text("\(count) \(volumeLabel)")
            .font(.caption2)
            .foregroundStyle(Color.inkuTextSecondary)
            .padding(InkuSpacing.spacing2)
            .padding(.horizontal, InkuSpacing.spacing4)
            .background(
                Capsule(style: .continuous)
                    .fill(Color.inkuAccentSoft)
            )
            .shadow(color: .black.opacity(0.1), radius: 10)
    }
}

// MARK: - Preview

#Preview("Medium Widget - Single Manga", as: .systemMedium) {
    InkuCollectionWidget()
} timeline: {
    let coverURL = "https://cdn.myanimelist.net/images/manga/5/260006l.jpg"

    InkuWidgetEntry(
        date: .now,
        mangas: [
            WidgetMangaData(
                id: 3,
                title: "20th Century Boys",
                japaneseTitle: "20世紀少年",
                coverURL: coverURL,
                coverImageData: URL(string: coverURL).flatMap { try? Data(contentsOf: $0) },
                volumesOwned: 22,
                totalVolumes: 22,
                currentReading: nil,
                isComplete: true
            )
        ]
    )
}

#Preview("Medium Widget - Two Mangas", as: .systemMedium) {
    InkuCollectionWidget()
} timeline: {
    let coverURL1 = "https://cdn.myanimelist.net/images/manga/3/258224l.jpg"
    let coverURL2 = "https://cdn.myanimelist.net/images/manga/1/157897l.jpg"

    InkuWidgetEntry(
        date: .now,
        mangas: [
            WidgetMangaData(
                id: 1,
                title: "Monster",
                japaneseTitle: "MONSTER",
                coverURL: coverURL1,
                coverImageData: URL(string: coverURL1).flatMap { try? Data(contentsOf: $0) },
                volumesOwned: 15,
                totalVolumes: 18,
                currentReading: 16,
                isComplete: false
            ),
            WidgetMangaData(
                id: 2,
                title: "Berserk",
                japaneseTitle: "ベルセルク",
                coverURL: coverURL2,
                coverImageData: URL(string: coverURL2).flatMap { try? Data(contentsOf: $0) },
                volumesOwned: 40,
                totalVolumes: 41,
                currentReading: nil,
                isComplete: false
            )
        ]
    )
}

#Preview("Medium Widget - Empty", as: .systemMedium) {
    InkuCollectionWidget()
} timeline: {
    InkuWidgetEntry(date: .now, mangas: [])
}
