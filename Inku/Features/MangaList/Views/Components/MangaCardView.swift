//
//  MangaCardView.swift
//  Inku
//
//  Created by Eduardo Andrade on 28/01/26.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2026 Eduardo Andrade. All rights reserved.
//

import SwiftUI
import InkuUI

struct MangaCardView: View {

    // MARK: - Properties

    let manga: Manga
    let isLoading: Bool

    // MARK: - Initializers

    init(manga: Manga, isLoading: Bool = false) {
        self.manga = manga
        self.isLoading = isLoading
    }

    // MARK: - Computed Properties

    private var subtitle: String? {
        manga.titleJapanese
    }

    private var genre: String? {
        manga.genres.first?.genre
    }

    private var status: InkuMangaCard.Status? {
        guard let statusString = manga.status else { return nil }

        switch statusString.lowercased() {
        case "publishing", "ongoing":
            return .publishing
        case "finished", "completed":
            return .completed
        case "on_hiatus", "hiatus":
            return .hiatus
        case "discontinued":
            return .discontinued
        default:
            return nil
        }
    }

    // MARK: - Body

    var body: some View {
        InkuMangaCard(
            imageURL: manga.coverImageURL,
            title: manga.displayTitle,
            subtitle: subtitle,
            score: manga.score,
            genre: genre,
            status: status,
            isLoading: isLoading
        )
    }
}

// MARK: - Previews

#Preview(
    "Manga Card View Test Data",
    traits: .sizeThatFitsLayout
) {
    MangaCardView(manga: .testData)
        .frame(width: 160)
        .padding()
        .background(Color.inkuSurface)
}

#Preview(
    "Manga Card View Loading",
    traits: .sizeThatFitsLayout
) {
    MangaCardView(manga: .skeletonData, isLoading: true)
        .frame(width: 160)
        .padding()
        .background(Color.inkuSurface)
}
