//
//  LargeWidgetView.swift
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

struct LargeWidgetView: View {

    // MARK: - Properties

    let entry: InkuWidgetEntry

    // MARK: - Computed Properties

    private var mangaCount: Int {
        entry.mangas.count
    }

    private var coverSize: CGSize {
        switch mangaCount {
        case 1:
            return .init(width: 120, height: 180)
        case 2:
            return .init(width: 80, height: 120)
        case 3:
            return .init(width: 60, height: 90)
        default:
            return .init(width: 40, height: 60)
        }
    }

    private var gridVerticalSpacing: CGFloat {
        mangaCount >= 4 ? InkuSpacing.spacing2 : InkuSpacing.spacing8
    }

    // MARK: - Body

    var body: some View {
        if entry.isEmpty {
            EmptyWidgetView()
        } else if mangaCount == 1 {
            singleMangaLayout
        } else {
            multiMangaLayout
        }
    }

    // MARK: - Private Views

    private var singleMangaLayout: some View {
        HStack(alignment: .top, spacing: InkuSpacing.spacing12) {
            if let manga = entry.mangas.first,
               let url = manga.coverImageURL {
                WidgetCoverImage(
                    imageData: manga.coverImageData,
                    url: url,
                    cornerRadius: InkuRadius.radius8
                )
                .frame(width: coverSize.width, height: coverSize.height)
                .shadow(color: .black.opacity(0.2), radius: 10)

                VStack(alignment: .leading, spacing: InkuSpacing.spacing8) {
                    mangaTitles(manga)

                    Spacer()

                    mangaCollectionInfo(manga)

                    InkuProgressBar(
                        progress: manga.progress ?? 0.0,
                        label: L10n.Collection.Card.progress
                    )
                }
            }
        }
        .padding(InkuSpacing.spacing12)
        .inkuCard()
    }

    private var multiMangaLayout: some View {
        Grid(alignment: .leading, verticalSpacing: gridVerticalSpacing) {
            ForEach(entry.mangas.prefix(4)) { manga in
                GridRow(alignment: .bottom) {
                    mangaRow(manga)
                }
            }
        }
        .padding(InkuSpacing.spacing4)
    }

    private func mangaRow(_ manga: WidgetMangaData) -> some View {
        Group {
            HStack(alignment: .top, spacing: InkuSpacing.spacing8) {
                if let url = manga.coverImageURL {
                    WidgetCoverImage(
                        imageData: manga.coverImageData,
                        url: url,
                        cornerRadius: InkuRadius.radius8
                    )
                    .frame(width: coverSize.width, height: coverSize.height)
                }

                VStack(alignment: .leading, spacing: InkuSpacing.spacing2) {
                    mangaTitles(manga)

                    Spacer(minLength: 0)

                    mangaCollectionInfo(manga)
                }
            }
            .layoutPriority(1)

            InkuProgressBar(
                progress: manga.progress ?? 0.0,
                label: L10n.Collection.Card.progress
            )
            .minimumScaleFactor(0.8)
            .lineLimit(1)
        }
    }

    private func mangaTitles(_ manga: WidgetMangaData) -> some View {
        VStack(alignment: .leading, spacing: InkuSpacing.spacing2) {
            Text(manga.title)
                .font(.inkuCaption)
                .foregroundStyle(Color.inkuText)

            if let japaneseTitle = manga.japaneseTitle {
                Text(japaneseTitle)
                    .font(.inkuCaptionSmall)
                    .foregroundStyle(Color.inkuTextTertiary)
                    .lineLimit(1)
            }
        }
    }

    private func mangaCollectionInfo(_ manga: WidgetMangaData) -> some View {
        VStack(alignment: .leading, spacing: InkuSpacing.spacing2) {
            Label {
                Text("\(manga.volumesOwned)/\(manga.totalVolumes ?? 0)")
                    .font(.inkuCaptionSmall)
                    .foregroundStyle(Color.inkuTextSecondary)
            } icon: {
                Image(systemName: "books.vertical")
                    .font(.inkuCaptionSmall)
                    .foregroundStyle(Color.inkuAccent)
            }
            .conditionalLabelIconSpacing(InkuSpacing.spacing2)
            .lineLimit(1)

            if let currentVolume = manga.currentReading {
                Label {
                    Text(L10n.Collection.Card.reading(currentVolume))
                        .font(.inkuCaptionSmall)
                        .foregroundStyle(Color.inkuTextSecondary)
                } icon: {
                    Image(systemName: "book.pages")
                        .font(.inkuCaptionSmall)
                        .foregroundStyle(Color.inkuAccent)
                }
                .conditionalLabelIconSpacing(InkuSpacing.spacing2)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            }
        }
    }
}

// MARK: - Preview

#Preview("Large Widget - Single Manga", as: .systemLarge) {
    InkuCollectionWidget()
} timeline: {
    let coverURL = "https://cdn.myanimelist.net/images/manga/3/258224l.jpg"

    InkuWidgetEntry(
        date: .now,
        mangas: [
            WidgetMangaData(
                id: 1,
                title: "Monster",
                japaneseTitle: "MONSTER",
                coverURL: coverURL,
                coverImageData: URL(string: coverURL).flatMap { try? Data(contentsOf: $0) },
                volumesOwned: 15,
                totalVolumes: 18,
                currentReading: 16,
                isComplete: false
            )
        ]
    )
}

#Preview("Large Widget - Two Mangas", as: .systemLarge) {
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

#Preview("Large Widget - Three Mangas", as: .systemLarge) {
    InkuCollectionWidget()
} timeline: {
    let coverURL1 = "https://cdn.myanimelist.net/images/manga/3/258224l.jpg"
    let coverURL2 = "https://cdn.myanimelist.net/images/manga/1/157897l.jpg"
    let coverURL3 = "https://cdn.myanimelist.net/images/manga/5/260006l.jpg"

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
            ),
            WidgetMangaData(
                id: 3,
                title: "20th Century Boys",
                japaneseTitle: "20世紀少年",
                coverURL: coverURL3,
                coverImageData: URL(string: coverURL3).flatMap { try? Data(contentsOf: $0) },
                volumesOwned: 22,
                totalVolumes: 22,
                currentReading: nil,
                isComplete: true
            )
        ]
    )
}

#Preview("Large Widget - Four Mangas", as: .systemLarge) {
    InkuCollectionWidget()
} timeline: {
    let coverURL1 = "https://cdn.myanimelist.net/images/manga/3/258224l.jpg"
    let coverURL2 = "https://cdn.myanimelist.net/images/manga/1/157897l.jpg"
    let coverURL3 = "https://cdn.myanimelist.net/images/manga/5/260006l.jpg"
    let coverURL4 = "https://cdn.myanimelist.net/images/manga/1/171813l.jpg"

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
            ),
            WidgetMangaData(
                id: 3,
                title: "20th Century Boys",
                japaneseTitle: "20世紀少年",
                coverURL: coverURL3,
                coverImageData: URL(string: coverURL3).flatMap { try? Data(contentsOf: $0) },
                volumesOwned: 22,
                totalVolumes: 22,
                currentReading: nil,
                isComplete: true
            ),
            WidgetMangaData(
                id: 4,
                title: "Yokohama Kaidashi Kikou",
                japaneseTitle: "ヨコハマ買い出し紀行",
                coverURL: coverURL4,
                coverImageData: URL(string: coverURL4).flatMap { try? Data(contentsOf: $0) },
                volumesOwned: 12,
                totalVolumes: 14,
                currentReading: 13,
                isComplete: false
            )
        ]
    )
}
#Preview("Large Widget - Empty", as: .systemLarge) {
    InkuCollectionWidget()
} timeline: {
    InkuWidgetEntry(date: .now, mangas: [])
}
