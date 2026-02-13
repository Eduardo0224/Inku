//
//  ExtraLargeWidgetView.swift
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

struct ExtraLargeWidgetView: View {

    // MARK: - Properties

    let entry: InkuWidgetEntry

    // MARK: - Computed Properties

    private var mangaCount: Int {
        entry.mangas.count
    }

    private var coverSize: CGSize {
        switch mangaCount {
        case 1:
            return .init(width: 140, height: 210)
        case 2:
            return .init(width: 120, height: 180)
        case 3...4:
            return .init(width: 64, height: 96)
        default:
            return .init(width: 60, height: 90)
        }
    }

    private var gridColumns: Int {
        switch mangaCount {
        case 1:
            return 1
        case 2:
            return 2
        case 3...4:
            return 2
        default:
            return 3
        }
    }

    private var gridSpacing: CGFloat {
        mangaCount >= 5 ? InkuSpacing.spacing8 : InkuSpacing.spacing12
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
        HStack(alignment: .top, spacing: InkuSpacing.spacing16) {
            if let manga = entry.mangas.first,
               let url = manga.coverImageURL {
                WidgetCoverImage(
                    imageData: manga.coverImageData,
                    url: url,
                    cornerRadius: InkuRadius.radius12
                )
                .frame(width: coverSize.width, height: coverSize.height)
                .shadow(color: .black.opacity(0.3), radius: 15)

                VStack(alignment: .leading, spacing: InkuSpacing.spacing12) {
                    mangaTitles(manga)
                    Spacer()
                    mangaDetailInfo(manga)
                    InkuProgressBar(
                        progress: manga.progress ?? 0.0,
                        label: L10n.Collection.Card.progress
                    )
                }
            }
        }
        .padding(InkuSpacing.spacing16)
        .inkuCard()
    }

    private var multiMangaLayout: some View {
        VStack(alignment: .leading, spacing: mangaCount >= 3 ? InkuSpacing.spacing8 : InkuSpacing.spacing12) {
            headerView

            if mangaCount == 2 {
                twoColumnLayout
            } else {
                gridLayout
            }
        }
        .padding(InkuSpacing.spacing12)
    }

    private var headerView: some View {
        HStack {
            Text(L10n.Widget.collection)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(Color.inkuText)

            Spacer()

            Text("\(entry.mangas.count)")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(Color.inkuTextSecondary)
                .padding(.horizontal, InkuSpacing.spacing8)
                .padding(.vertical, InkuSpacing.spacing4)
                .background(Color.inkuSurfaceElevated)
                .clipShape(Capsule())
        }
    }

    private var twoColumnLayout: some View {
        HStack(spacing: InkuSpacing.spacing16) {
            ForEach(entry.mangas.prefix(2)) { manga in
                mangaCard(manga)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(InkuSpacing.spacing12)
        .inkuCard()
    }

    private var gridLayout: some View {
        VStack(spacing: gridSpacing) {
            ForEach(0..<2, id: \.self) { row in
                HStack(spacing: gridSpacing) {
                    ForEach(0..<gridColumns, id: \.self) { col in
                        let index = row * gridColumns + col
                        if index < entry.mangas.count {
                            mangaCard(entry.mangas[index])
                                .frame(maxWidth: .infinity)
                        } else {
                            Color.clear
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
        }
    }

    private func mangaCard(_ manga: WidgetMangaData) -> some View {
        VStack(alignment: .leading, spacing: InkuSpacing.spacing4) {
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

                    mangaCompactInfo(manga)

                    if manga.isComplete {
                        InkuBadge(text: L10n.Collection.Card.complete, style: .accent)
                    }
                }
            }

            if mangaCount <= 4, let progress = manga.progress {
                InkuProgressBar(
                    progress: progress,
                    label: L10n.Collection.Card.progress
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func mangaTitles(_ manga: WidgetMangaData) -> some View {
        VStack(alignment: .leading, spacing: InkuSpacing.spacing2) {
            Text(manga.title)
                .font(mangaCount == 1 ? .inkuBody : .inkuCaption)
                .fontWeight(.semibold)
                .foregroundStyle(Color.inkuText)
                .lineLimit(mangaCount == 1 ? 2 : 1)

            if let japaneseTitle = manga.japaneseTitle {
                Text(japaneseTitle)
                    .font(mangaCount == 1 ? .inkuCaption : .inkuCaptionSmall)
                    .foregroundStyle(Color.inkuTextTertiary)
                    .lineLimit(1)
            }
        }
    }

    private func mangaDetailInfo(_ manga: WidgetMangaData) -> some View {
        VStack(alignment: .leading, spacing: InkuSpacing.spacing8) {
            Label {
                Text("\(manga.volumesOwned)/\(manga.totalVolumes ?? 0)")
                    .font(.inkuCaption)
                    .foregroundStyle(Color.inkuTextSecondary)
            } icon: {
                Image(systemName: "books.vertical")
                    .symbolVariant(.fill)
                    .font(.inkuCaption)
                    .foregroundStyle(Color.inkuAccent)
            }
            .conditionalLabelIconSpacing(InkuSpacing.spacing4)

            if let currentVolume = manga.currentReading {
                Label {
                    Text(L10n.Collection.Card.reading(currentVolume))
                        .font(.inkuCaption)
                        .foregroundStyle(Color.inkuTextSecondary)
                } icon: {
                    Image(systemName: "book.pages")
                        .font(.inkuCaption)
                        .foregroundStyle(Color.inkuAccent)
                }
                .conditionalLabelIconSpacing(InkuSpacing.spacing4)
            }

            if manga.isComplete {
                InkuBadge(text: L10n.Collection.Card.complete, style: .accent)
            }
        }
    }

    private func mangaCompactInfo(_ manga: WidgetMangaData) -> some View {
        VStack(alignment: .leading, spacing: InkuSpacing.spacing2) {
            HStack(spacing: InkuSpacing.spacing4) {
                Image(systemName: "books.vertical")
                    .font(.inkuCaptionSmall)
                    .foregroundStyle(Color.inkuAccent)

                Text("\(manga.volumesOwned)/\(manga.totalVolumes ?? 0)")
                    .font(.inkuCaptionSmall)
                    .foregroundStyle(Color.inkuTextSecondary)
            }

            if let currentVolume = manga.currentReading {
                HStack(spacing: InkuSpacing.spacing4) {
                    Image(systemName: "book.pages")
                        .font(.inkuCaptionSmall)
                        .foregroundStyle(Color.inkuAccent)

                    Text(L10n.Collection.Card.reading(currentVolume))
                        .font(.inkuCaptionSmall)
                        .foregroundStyle(Color.inkuTextSecondary)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("Extra Large - Single Manga", as: .systemExtraLarge) {
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

#Preview("Extra Large - Two Mangas", as: .systemExtraLarge) {
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

#Preview("Extra Large - Four Mangas", as: .systemExtraLarge) {
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

#Preview("Extra Large - Six Mangas", as: .systemExtraLarge) {
    InkuCollectionWidget()
} timeline: {
    let coverURL1 = "https://cdn.myanimelist.net/images/manga/3/258224l.jpg"
    let coverURL2 = "https://cdn.myanimelist.net/images/manga/1/157897l.jpg"
    let coverURL3 = "https://cdn.myanimelist.net/images/manga/5/260006l.jpg"
    let coverURL4 = "https://cdn.myanimelist.net/images/manga/1/171813l.jpg"
    let coverURL5 = "https://cdn.myanimelist.net/images/manga/2/250313l.jpg"
    let coverURL6 = "https://cdn.myanimelist.net/images/manga/3/175970l.jpg"

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
            ),
            WidgetMangaData(
                id: 5,
                title: "Hajime no Ippo",
                japaneseTitle: "はじめの一歩",
                coverURL: coverURL5,
                coverImageData: URL(string: coverURL5).flatMap { try? Data(contentsOf: $0) },
                volumesOwned: 130,
                totalVolumes: 139,
                currentReading: 131,
                isComplete: false
            ),
            WidgetMangaData(
                id: 6,
                title: "Full Moon wo Sagashite",
                japaneseTitle: "満月〈フルムーン〉をさがして",
                coverURL: coverURL6,
                coverImageData: URL(string: coverURL6).flatMap { try? Data(contentsOf: $0) },
                volumesOwned: 7,
                totalVolumes: 7,
                currentReading: nil,
                isComplete: true
            )
        ]
    )
}

#Preview("Extra Large - Empty", as: .systemExtraLarge) {
    InkuCollectionWidget()
} timeline: {
    InkuWidgetEntry(date: .now, mangas: [])
}
