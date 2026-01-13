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
import SwiftData
import InkuUI

struct MangaDetailView: View {

    // MARK: - Environment

    @Environment(\.modelContext) private var modelContext
    @Environment(\.collectionViewModel) private var collectionViewModel

    // MARK: - States

    @State private var collectionManga: CollectionManga?
    @State private var mangaToEdit: CollectionManga?
    @State private var mangaToDelete: CollectionManga?

    // MARK: - Properties

    let manga: Manga

    // MARK: - Computed Properties

    private var isInCollection: Bool {
        collectionManga != nil
    }

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
        .toolbar {
            toolbarContent
        }
        .overlay(alignment: .bottomTrailing) {
            if !isInCollection {
                addToCollectionButton
            }
        }
        .sheet(item: $mangaToEdit) { manga in
            EditCollectionSheet(collectionManga: manga)
        }
        .onChange(of: mangaToEdit) { _, _ in
            if mangaToEdit == nil {
                // Sheet closed, refresh collection status
                checkIfInCollection()
            }
        }
        .alert(
            L10n.Collection.Delete.title,
            isPresented: .constant(mangaToDelete != nil),
            presenting: mangaToDelete
        ) { manga in
            Button(L10n.Common.cancel, role: .cancel) {
                mangaToDelete = nil
            }
            Button(L10n.Collection.Delete.confirm, role: .destructive) {
                removeFromCollection(manga)
            }
        } message: { manga in
            Text(L10n.Collection.Delete.message(manga.title))
        }
        .task {
            collectionViewModel.setModelContext(modelContext)
            checkIfInCollection()
        }
    }

    // MARK: - Private Views

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        if isInCollection {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        mangaToEdit = collectionManga
                    } label: {
                        Label(L10n.Collection.Card.edit, systemImage: "pencil")
                    }

                    Button(role: .destructive) {
                        mangaToDelete = collectionManga
                    } label: {
                        Label(L10n.Collection.Card.delete, systemImage: "trash")
                    }
                } label: {
                    Label(L10n.Collection.Actions.manage, systemImage: "bookmark.fill")
                        .symbolRenderingMode(.multicolor)
                }
            }
        }
    }

    private var addToCollectionButton: some View {
        Button {
            addToCollection()
        } label: {
            Label(L10n.Collection.Actions.add, systemImage: "bookmark.fill")
                .font(.inkuHeadline)
                .foregroundStyle(Color.inkuTextOnAccent)
                .padding(.horizontal, InkuSpacing.spacing20)
                .padding(.vertical, InkuSpacing.spacing16)
                .background(Color.inkuAccent)
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
        }
        .padding(InkuSpacing.spacing24)
    }

    // MARK: - Private Functions

    private func checkIfInCollection() {
        collectionManga = collectionViewModel.getCollectionManga(mangaId: manga.id)
    }

    private func addToCollection() {
        do {
            try collectionViewModel.addToCollection(manga)
            checkIfInCollection()
        } catch {
            print("[MangaDetailView] Error adding to collection: \(error)")
        }
    }

    private func removeFromCollection(_ manga: CollectionManga) {
        do {
            try collectionViewModel.removeFromCollection(manga)
            collectionManga = nil
            mangaToDelete = nil
        } catch {
            print("[MangaDetailView] Error removing from collection: \(error)")
        }
    }
}

// MARK: - Previews

#Preview("Manga Detail - Full Data") {
    NavigationStack {
        MangaDetailView(manga: .testData)
            .environment(\.collectionViewModel, MockCollectionViewModel.empty)
    }
}

#Preview("Manga Detail - Minimal Data") {
    NavigationStack {
        MangaDetailView(manga: .emptyData)
            .environment(\.collectionViewModel, MockCollectionViewModel.empty)
    }
}
