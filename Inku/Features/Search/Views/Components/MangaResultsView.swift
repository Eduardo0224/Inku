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

    // MARK: - Environment

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    // MARK: - Properties

    let mangas: [Manga]
    let searchText: String
    let isLoadingMore: Bool
    @Binding var mangaSearchMode: MangaSearchMode
    let onMangaAppear: (Manga) -> Void

    // MARK: - Computed Properties

    private func columnCount(for width: CGFloat) -> Int {
        if horizontalSizeClass == .regular {
            return width > 1000 ? 5 : 4
        }
        return 2
    }

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
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    VStack(alignment: .leading, spacing: InkuSpacing.spacing4) {
                        HStack(alignment: .center, spacing: InkuSpacing.spacing8) {
                            Text(title)
                                .font(.inkuDisplayMedium)
                                .foregroundStyle(Color.inkuText)

                            Menu {
                                ForEach(MangaSearchMode.allCases) { mode in
                                    Button {
                                        mangaSearchMode = mode
                                    } label: {
                                        if mode == mangaSearchMode {
                                            Label(mode.displayText, systemImage: "checkmark")
                                        } else {
                                            Text(mode.displayText)
                                        }
                                    }
                                }
                            } label: {
                                Image(systemName: "chevron.down")
                                    .symbolVariant(.circle.fill)
                                    .font(.inkuHeadline)
                                    .foregroundStyle(Color.inkuTextSecondary)
                                    .inkuGlass()
                            }

                            Spacer()
                        }

                        if let subtitle {
                            Text(subtitle)
                                .font(.inkuBodySmall)
                                .foregroundStyle(Color.inkuTextSecondary)
                        }
                    }
                    .padding(.horizontal, InkuSpacing.spacing16)
                    .padding(.top, InkuSpacing.spacing20)
                    .padding(.bottom, InkuSpacing.spacing12)

                    Divider()
                        .background(Color.inkuTextTertiary.opacity(0.2))
                        .padding(.bottom, InkuSpacing.spacing16)

                    // Grid
                    LazyVGrid(
                        columns: Array(
                            repeating: GridItem(.flexible(), spacing: InkuSpacing.spacing16),
                            count: columnCount(for: geometry.size.width)
                        ),
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
                            #if os(visionOS)
                            .buttonBorderShape(
                                .roundedRectangle(radius: InkuRadius.radius12)
                            )
                            #endif
                            .task {
                                if manga == mangas.last {
                                    onMangaAppear(manga)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, InkuSpacing.spacing16)

                    // Loading indicator
                    if isLoadingMore {
                        InkuLoadingView(message: L10n.Common.loading)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, InkuSpacing.spacing16)
                    }
                }
            }
            #if !os(visionOS)
            .scrollDismissesKeyboard(.immediately)
            #endif
        }
        .background(Color.inkuSurface)
    }
}

// MARK: - Previews

#Preview("Manga Results") {
    @Previewable @State var mode: MangaSearchMode = .contains
    NavigationStack {
        MangaResultsView(
            mangas: [.testData, .testData, .testData],
            searchText: "One Piece",
            isLoadingMore: false,
            mangaSearchMode: $mode,
            onMangaAppear: { _ in }
        )
    }
}

#Preview("Manga Results - Loading More") {
    @Previewable @State var mode: MangaSearchMode = .beginsWith
    NavigationStack {
        MangaResultsView(
            mangas: [.testData, .testData],
            searchText: "Naruto",
            isLoadingMore: true,
            mangaSearchMode: $mode,
            onMangaAppear: { _ in }
        )
    }
}
