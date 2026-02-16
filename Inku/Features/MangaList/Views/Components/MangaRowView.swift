//
//  MangaRowView.swift
//  Inku
//
//  Created by Eduardo Andrade on 23/12/25.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2025 Eduardo Andrade. All rights reserved.
//

import SwiftUI
import InkuUI

struct MangaRowView: View {

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

    private var genres: [String] {
        Array(manga.genres.prefix(3).map(\.genre))
    }

    private var status: InkuMangaRow.Status? {
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
        InkuMangaRow(
            imageURL: manga.coverImageURL,
            title: manga.displayTitle,
            subtitle: subtitle,
            score: manga.score,
            genres: genres,
            status: status,
            isLoading: isLoading
        )
        #if os(visionOS)
        .hoverEffectDisabled()
        #endif
    }
}

// MARK: - Previews

#Preview(
    "Manga Row View Test Data",
    traits: .sizeThatFitsLayout
) {
    MangaRowView(manga: .testData)
        .padding()
        .background(Color.inkuSurface)
}
