//
//  MangaGridView.swift
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

struct MangaGridView: View {

    // MARK: - Environment

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    // MARK: - Properties

    let mangas: [Manga]
    let isLoadingMore: Bool
    let onMangaAppear: (Manga) -> Void

    // MARK: - Computed Properties

    private func columnCount(for width: CGFloat) -> Int {
        if horizontalSizeClass == .regular {
            return width > 1000 ? 5 : 4
        }

        return 2
    }

    // MARK: - Body

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                LazyVGrid(
                    columns: Array(
                        repeating: GridItem(.flexible(), spacing: InkuSpacing.spacing16),
                        count: columnCount(for: geometry.size.width)
                    ),
                    spacing: InkuSpacing.spacing16
                ) {
                    ForEach(mangas) { manga in
                        NavigationLink(value: manga) {
                            MangaCardView(manga: manga)
                        }
                        .buttonStyle(.plain)
                        .task {
                            if manga == mangas.last {
                                onMangaAppear(manga)
                            }
                        }
                    }
                }
                .padding(.horizontal, InkuSpacing.spacing16)

                if isLoadingMore {
                    InkuLoadingView(message: L10n.Common.loading)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, InkuSpacing.spacing16)
                }
            }
            .scrollDismissesKeyboard(.immediately)
        }
        .background(Color.inkuSurface)
    }
}

// MARK: - Previews

#Preview("Manga Grid View") {
    NavigationStack {
        MangaGridView(
            mangas: [.testData, .testData, .testData, .testData],
            isLoadingMore: false,
            onMangaAppear: { _ in }
        )
    }
}

#Preview("Manga Grid View - Loading More") {
    NavigationStack {
        MangaGridView(
            mangas: [.testData, .testData],
            isLoadingMore: true,
            onMangaAppear: { _ in }
        )
    }
}
