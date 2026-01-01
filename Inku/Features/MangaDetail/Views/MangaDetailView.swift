//
//  MangaDetailView.swift
//  Inku
//
//  Created by Eduardo Andrade on 30/12/25.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2025 Eduardo Andrade. All rights reserved.
//

import SwiftUI
import InkuUI

struct MangaDetailView: View {

    // MARK: - Properties

    let manga: Manga

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .top) {
            // Background Image with Glass Effect
            GeometryReader { geometry in
                AsyncImage(url: manga.coverImageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: 350)
                        .blur(radius: 30)
                        .clipped()
                } placeholder: {
                    Color.inkuSurface
                        .frame(width: geometry.size.width, height: 350)
                }
                .overlay {
                    Rectangle()
                        .fill(.thinMaterial)
                        .frame(width: geometry.size.width, height: 350)
                }
                .overlay(alignment: .bottom) {
                    LinearGradient(
                        gradient: Gradient(
                            colors: [.clear, Color.inkuSurface]
                        ),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 100)
                }
                .ignoresSafeArea()
            }
            .frame(height: 350)

            // Content
            ScrollView {
                VStack(spacing: InkuSpacing.spacing24) {
                    MangaHeaderSection(
                        coverURL: manga.coverImageURL,
                        title: manga.displayTitle,
                        japaneseTitle: manga.titleJapanese,
                        score: manga.score
                    )
                    .padding(.horizontal, InkuSpacing.spacing16)

                    MangaStatsSection(
                        volumes: manga.volumes,
                        chapters: manga.chapters,
                        status: manga.status
                    )
                    .padding(.horizontal, InkuSpacing.spacing16)

                    if manga.startDate != nil {
                        MangaPublicationSection(
                            startDate: manga.startDate,
                            endDate: manga.endDate,
                            status: manga.status
                        )
                        .padding(.horizontal, InkuSpacing.spacing16)
                    }

                    MangaSynopsisSection(
                        synopsis: manga.sypnosis,
                        background: manga.background,
                        title: manga.displayTitle
                    )
                    .padding(.horizontal, InkuSpacing.spacing16)

                    if !manga.authors.isEmpty {
                        MangaAuthorsSection(authors: manga.authors)
                            .padding(.horizontal, InkuSpacing.spacing16)
                    }

                    if !manga.genres.isEmpty || !manga.demographics.isEmpty || !manga.themes.isEmpty {
                        MangaTagsSection(
                            genres: manga.genres,
                            demographics: manga.demographics,
                            themes: manga.themes
                        )
                        .padding(.horizontal, InkuSpacing.spacing16)
                    }
                }
                .padding(.bottom, InkuSpacing.spacing24)
            }
        }
        .background(Color.inkuSurface)
        .navigationTitle(L10n.MangaDetail.Screen.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Previews

#Preview("Manga Detail - Full Data") {
    NavigationStack {
        MangaDetailView(manga: .testData)
    }
}

#Preview("Manga Detail - Minimal Data") {
    NavigationStack {
        MangaDetailView(manga: .emptyData)
    }
}
