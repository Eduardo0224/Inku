//
//  MangaResultsView.swift
//  Inku
//
//  Created by Eduardo Andrade on 04/01/26.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2026 Eduardo Andrade. All rights reserved.
//

import SwiftUI
import InkuUI

struct MangaResultsView: View {

    // MARK: - Properties

    let mangas: [Manga]
    let searchText: String
    let isLoadingMore: Bool
    let onMangaAppear: (Manga) -> Void

    // MARK: - Computed Properties

    private var title: String {
        let count = mangas.count
        let resultWord = count == 1 ? L10n.Search.Results.singular : L10n.Search.Results.plural
        return "\(count) \(resultWord)"
    }

    private var subtitle: String? {
        searchText.isEmpty ? nil : L10n.Search.Results.forQuery(searchText)
    }

    // MARK: - Body

    var body: some View {
        InkuListContainer(
            title: title,
            subtitle: subtitle,
            scrollDismissesKeyboard: .immediately
        ) {
            VStack(spacing: InkuSpacing.spacing16) {
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: InkuSpacing.spacing16), count: 2),
                    spacing: InkuSpacing.spacing16
                ) {
                    ForEach(mangas) { manga in
                        NavigationLink(value: manga) {
                            InkuSearchResultCard(
                                imageURL: manga.coverImageURL,
                                title: manga.displayTitle,
                                subtitle: manga.titleJapanese,
                                badge: manga.genres.first?.genre
                            )
                        }
                        .buttonStyle(.plain)
                        .task {
                            if manga == mangas.last {
                                onMangaAppear(manga)
                            }
                        }
                    }
                }

                if isLoadingMore {
                    InkuLoadingView(message: L10n.Common.loading)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, InkuSpacing.spacing16)
                }
            }
        }
    }
}

// MARK: - Previews

#Preview("Manga Results") {
    NavigationStack {
        MangaResultsView(
            mangas: [.testData, .testData, .testData],
            searchText: "One Piece",
            isLoadingMore: false,
            onMangaAppear: { _ in }
        )
    }
}

#Preview("Manga Results - Loading More") {
    NavigationStack {
        MangaResultsView(
            mangas: [.testData, .testData],
            searchText: "Naruto",
            isLoadingMore: true,
            onMangaAppear: { _ in }
        )
    }
}
