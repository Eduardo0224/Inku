//
//  SmallWidgetView.swift
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

struct SmallWidgetView: View {

    // MARK: - Properties

    let entry: InkuWidgetEntry

    // MARK: - Computed Properties

    private var coverSize: CGSize {
        .init(width: 70, height: 100)
    }

    // MARK: - Body

    var body: some View {
        if entry.isEmpty {
            EmptyWidgetView()
        } else if let manga = entry.mangas.first {
            contentView(for: manga)
        }
    }

    // MARK: - Private Views

    private func contentView(for manga: WidgetMangaData) -> some View {
        VStack(spacing: InkuSpacing.spacing8) {
            coverImage(for: manga)
            mangaTitle(manga.title)
        }
        .padding(.vertical, InkuSpacing.spacing12)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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

    private func mangaTitle(_ title: String) -> some View {
        Text(title)
            .font(.inkuBody)
            .fontWeight(.semibold)
            .foregroundStyle(Color.inkuText)
            .multilineTextAlignment(.center)
            .lineLimit(2)
    }
}

// MARK: - Preview

#Preview("Small Widget - With Data", as: .systemSmall) {
    InkuCollectionWidget()
} timeline: {
    let coverURL = "https://cdn.myanimelist.net/images/manga/1/171813l.jpg"

    InkuWidgetEntry(
        date: .now,
        mangas: [
            WidgetMangaData(
                id: 4,
                title: "Yokohama Kaidashi Kikou",
                japaneseTitle: "ヨコハマ買い出し紀行",
                coverURL: coverURL,
                coverImageData: URL(string: coverURL).flatMap { try? Data(contentsOf: $0) },
                volumesOwned: 12,
                totalVolumes: 14,
                currentReading: 13,
                isComplete: false
            )
        ]
    )
}
#Preview("Small Widget - Empty", as: .systemSmall) {
    InkuCollectionWidget()
} timeline: {
    InkuWidgetEntry(date: .now, mangas: [])
}
