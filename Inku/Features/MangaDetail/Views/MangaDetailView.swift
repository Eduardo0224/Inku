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
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.tabBarPlacement) private var tabBarPlacement
    @Environment(AuthViewModel.self) private var authViewModel

    // MARK: - States

    @State private var collectionManga: CollectionManga?
    @State private var mangaToEdit: CollectionManga?
    @State private var mangaToDelete: CollectionManga?
    @State private var errorMessage: String?
    @State private var showErrorAlert: Bool = false
    @State private var isDeleting: Bool = false

    // MARK: - Properties

    let manga: Manga

    // MARK: - Computed Properties

    private var isInCollection: Bool {
        collectionManga != nil
    }

    private func usesTwoColumnLayout(for width: CGFloat) -> Bool {
        horizontalSizeClass == .regular && width > 1000
    }

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .top) {
            // Background Image with Glass Effect
            AsyncImage(url: manga.coverImageURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: 350)
                    .blur(radius: 30)
                    .clipped()
            } placeholder: {
                Color.inkuSurface
                    .frame(maxWidth: .infinity, maxHeight: 350)
            }
            .overlay {
                Rectangle()
                    .fill(.thinMaterial)
                    .frame(maxWidth: .infinity, maxHeight: 350)
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
            .frame(height: 350)
            .ignoresSafeArea(edges: .horizontal)
            .liquidGlassBackground()

            // Content
            GeometryReader { geometry in
                ScrollView {
                    if usesTwoColumnLayout(for: geometry.size.width) {
                        twoColumnLayout
                    } else {
                        singleColumnLayout
                    }
                }
            }
        }
        .overlay {
            if isDeleting {
                loadingOverlay
            }
        }
        .background(Color.inkuSurface)
        .navigationTitle(tabBarPlacement == .topBar ? "" : L10n.MangaDetail.Screen.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
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
        .alert(
            L10n.Error.title,
            isPresented: $showErrorAlert
        ) {
            Button(L10n.Common.ok, role: .cancel) {
                showErrorAlert = false
                errorMessage = nil
            }
        } message: {
            if let errorMessage = errorMessage {
                Text(errorMessage)
            }
        }
        .task {
            collectionViewModel.setModelContext(modelContext)
            checkIfInCollection()
        }
    }

    // MARK: - Private Views

    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            InkuLoadingView(message: L10n.Common.deleting)
                .padding(InkuSpacing.spacing32)
                .background {
                    RoundedRectangle(cornerRadius: InkuRadius.radius16)
                        .fill(.regularMaterial)
                }
                .frame(width: 150, height: 150)
        }
    }

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
        } else {
            ToolbarItem(placement: .secondaryAction) {
                addToCollectionButton
            }
        }
    }

    private var addToCollectionButton: some View {
        Button {
            addToCollection()
        } label: {
            Label(L10n.Collection.Actions.add, systemImage: "bookmark.fill")
        }
    }

    private var twoColumnLayout: some View {
        HStack(alignment: .top, spacing: InkuSpacing.spacing24) {
            // Left Column
            VStack(spacing: InkuSpacing.spacing24) {
                headerSection(isTwoColumn: true)
                statsSection
                publicationSection
                authorsSection
                tagsSection
            }
            .frame(maxWidth: .infinity)

            // Right Column
            VStack(spacing: InkuSpacing.spacing24) {
                synopsisSection(showsFullText: true)
                    .padding(.top, InkuSpacing.spacing16)
                backgroundSection
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, InkuSpacing.spacing16)
        .padding(.bottom, InkuSpacing.spacing24)
    }

    private var singleColumnLayout: some View {
        VStack(spacing: InkuSpacing.spacing24) {
            headerSection(isTwoColumn: false)
                .padding(.horizontal, InkuSpacing.spacing16)

            statsSection
                .padding(.horizontal, InkuSpacing.spacing16)

            publicationSection
                .padding(.horizontal, InkuSpacing.spacing16)

            synopsisSection(showsFullText: false)
                .padding(.horizontal, InkuSpacing.spacing16)

            authorsSection
                .padding(.horizontal, InkuSpacing.spacing16)

            tagsSection
                .padding(.horizontal, InkuSpacing.spacing16)
        }
        .padding(.bottom, InkuSpacing.spacing24)
    }

    // MARK: - Section Helpers

    private func headerSection(isTwoColumn: Bool) -> some View {
        MangaHeaderSection(
            coverURL: manga.coverImageURL,
            title: manga.displayTitle,
            japaneseTitle: manga.titleJapanese,
            score: manga.score,
            isRegularSizeClass: isTwoColumn
        )
    }

    private var statsSection: some View {
        MangaStatsSection(
            volumes: manga.volumes,
            chapters: manga.chapters,
            status: manga.status
        )
    }

    @ViewBuilder
    private var publicationSection: some View {
        if manga.startDate != nil {
            MangaPublicationSection(
                startDate: manga.startDate,
                endDate: manga.endDate,
                status: manga.status
            )
        }
    }

    private func synopsisSection(showsFullText: Bool) -> some View {
        MangaSynopsisSection(
            synopsis: manga.sypnosis,
            background: manga.background,
            title: manga.displayTitle,
            showsFullText: showsFullText,
            showsBackgroundButton: !showsFullText
        )
    }

    @ViewBuilder
    private var backgroundSection: some View {
        if let background = manga.background, !background.isEmpty {
            MangaBackgroundSection(background: background)
        }
    }

    @ViewBuilder
    private var authorsSection: some View {
        if !manga.authors.isEmpty {
            MangaAuthorsSection(authors: manga.authors)
        }
    }

    @ViewBuilder
    private var tagsSection: some View {
        if !manga.genres.isEmpty || !manga.demographics.isEmpty || !manga.themes.isEmpty {
            MangaTagsSection(
                genres: manga.genres,
                demographics: manga.demographics,
                themes: manga.themes
            )
        }
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
            errorMessage = error.localizedDescription
            showErrorAlert = true
        }
    }

    private func removeFromCollection(_ manga: CollectionManga) {
        mangaToDelete = nil
        isDeleting = true

        Task {
            do {
                try await authViewModel.deleteMangaFromCollection(manga)
                collectionManga = nil
            } catch {
                errorMessage = error.localizedDescription
                showErrorAlert = true
            }
            isDeleting = false
        }
    }
}

// MARK: - Previews

#Preview("Manga Detail - Full Data") {
    @Previewable @State var authViewModel = AuthViewModel()
    NavigationStack {
        MangaDetailView(manga: .testData)
            .environment(\.collectionViewModel, MockCollectionViewModel.empty)
            .environment(authViewModel)
    }
}

#Preview("Manga Detail - Minimal Data") {
    @Previewable @State var authViewModel = AuthViewModel()
    NavigationStack {
        MangaDetailView(manga: .emptyData)
            .environment(\.collectionViewModel, MockCollectionViewModel.empty)
            .environment(authViewModel)
    }
}
