//
//  CollectionListView.swift
//  Inku
//
//  Created by Eduardo Andrade on 08/01/26.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2026 Eduardo Andrade. All rights reserved.
//

import SwiftUI
import SwiftData
import InkuUI

struct CollectionListView: View {

    // MARK: - Query

    @Query private var collectionMangas: [CollectionManga]

    // MARK: - Environment

    @Environment(\.modelContext) private var modelContext
    @Environment(\.collectionViewModel) private var viewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(AuthViewModel.self) private var authViewModel

    // MARK: - States

    @State private var searchText = ""
    @State private var mangaToEdit: CollectionManga?
    @State private var mangaToDelete: CollectionManga?
    @State private var isDeleting = false

    // MARK: - Properties

    private let filter: CollectionFilter
    private let sortOption: CollectionSortOption

    // MARK: - Initializers

    init(
        filter: CollectionFilter,
        sortOption: CollectionSortOption
    ) {
        self.filter = filter
        self.sortOption = sortOption

        let predicate: Predicate<CollectionManga>? = {
            switch filter {
            case .all:
                return nil
            case .reading:
                return #Predicate<CollectionManga> { manga in
                    manga.currentReadingVolume != nil
                }
            case .complete:
                return #Predicate<CollectionManga> { manga in
                    manga.hasCompleteCollection
                }
            case .incomplete:
                return #Predicate<CollectionManga> { manga in
                    !manga.hasCompleteCollection
                }
            }
        }()

        let sortDescriptors: [SortDescriptor<CollectionManga>] = {
            switch sortOption {
            case .dateAdded:
                return [SortDescriptor(\.dateAdded, order: .reverse)]
            case .title:
                return [SortDescriptor(\.title, order: .forward)]
            case .progress:
                return [SortDescriptor(\.volumesOwnedCount, order: .reverse)]
            }
        }()

        _collectionMangas = Query(
            filter: predicate,
            sort: sortDescriptors
        )
    }

    // MARK: - Body

    var body: some View {
        Group {
            if filteredMangas.isEmpty {
                if searchText.isEmpty {
                    emptyStateView
                } else {
                    emptySearchResultsView
                }
            } else {
                collectionList
            }
        }
        .searchable(
            text: $searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: L10n.Collection.Search.placeholder
        )
        .scrollDismissesKeyboard(.interactively)
        .sheet(item: $mangaToEdit) { manga in
            EditCollectionSheet(collectionManga: manga)
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
                confirmDelete(manga)
            }
        } message: { manga in
            Text(L10n.Collection.Delete.message(manga.title))
        }
        .alert(
            L10n.Error.title,
            isPresented: .constant(viewModel.errorMessage != nil),
            presenting: viewModel.errorMessage
        ) { _ in
            Button(L10n.Common.ok, role: .cancel) {
                viewModel.clearError()
            }
        } message: { errorMessage in
            Text(errorMessage)
        }
        .overlay {
            if isDeleting {
                loadingOverlay
            }
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

    private var collectionList: some View {
        GeometryReader { geometry in
            ScrollView {
                if horizontalSizeClass == .regular {
                    LazyVGrid(
                        columns: Array(
                            repeating: GridItem(.flexible(), spacing: InkuSpacing.spacing16),
                            count: columnCount(for: geometry.size.width)
                        ),
                        spacing: InkuSpacing.spacing16
                    ) {
                        mangaCards
                    }
                    .padding(InkuSpacing.spacing16)
                } else {
                    LazyVStack(spacing: InkuSpacing.spacing16) {
                        mangaCards
                    }
                    .padding(InkuSpacing.spacing16)
                }
            }
            .background(Color.inkuSurface)
        }
    }

    private var mangaCards: some View {
        ForEach(filteredMangas) { manga in
            CollectionItemCard(
                collectionManga: manga,
                onEdit: { editManga(manga) },
                onDelete: { deleteManga(manga) },
                onTap: {
                    Task {
                        await viewModel.loadMangaById(manga.mangaId)
                    }
                }
            )
            .buttonStyle(.plain)
        }
    }

    private var emptyStateView: some View {
        InkuEmptyView(
            icon: emptyStateIcon,
            iconSize: .large,
            title: emptyStateTitle,
            subtitle: emptyStateMessage,
            symbolEffect: .pulse,
            symbolEffectOptions: .repeating
        )
        .background(Color.inkuSurface)
    }

    private var emptySearchResultsView: some View {
        InkuEmptyView(
            icon: "magnifyingglass",
            iconSize: .large,
            title: L10n.Collection.Search.emptyTitle,
            subtitle: L10n.Collection.Search.emptyMessage(searchText),
            symbolEffect: .pulse,
            symbolEffectOptions: .repeating
        )
        .background(Color.inkuSurface)
    }

    // MARK: - Computed Properties

    private func columnCount(for width: CGFloat) -> Int {
        return width > 1000 ? 2 : 1
    }

    private var filteredMangas: [CollectionManga] {
        guard !searchText.isEmpty else {
            return collectionMangas
        }

        return collectionMangas.filter { manga in
            manga.title.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var emptyStateIcon: String {
        switch filter {
        case .all:
            return "books.vertical"
        case .reading:
            return "book.pages"
        case .complete:
            return "checkmark.circle"
        case .incomplete:
            return "circle.dotted"
        }
    }

    private var emptyStateTitle: String {
        switch filter {
        case .all:
            return L10n.Collection.Empty.allTitle
        case .reading:
            return L10n.Collection.Empty.readingTitle
        case .complete:
            return L10n.Collection.Empty.completeTitle
        case .incomplete:
            return L10n.Collection.Empty.incompleteTitle
        }
    }

    private var emptyStateMessage: String {
        switch filter {
        case .all:
            return L10n.Collection.Empty.allMessage
        case .reading:
            return L10n.Collection.Empty.readingMessage
        case .complete:
            return L10n.Collection.Empty.completeMessage
        case .incomplete:
            return L10n.Collection.Empty.incompleteMessage
        }
    }

    // MARK: - Private Functions

    private func editManga(_ manga: CollectionManga) {
        mangaToEdit = manga
    }

    private func deleteManga(_ manga: CollectionManga) {
        mangaToDelete = manga
    }

    private func confirmDelete(_ manga: CollectionManga) {
        mangaToDelete = nil
        isDeleting = true

        Task {
            do {
                try await authViewModel.deleteMangaFromCollection(manga)
            } catch {
                viewModel.setError(error.localizedDescription)
            }
            isDeleting = false
        }
    }
}

// MARK: - Previews

#Preview(
    "Collection List - Empty All",
    traits: .previewContainer(.empty)
) {
    @Previewable @State var authViewModel = AuthViewModel()
    NavigationStack {
        CollectionListView(
            filter: .all,
            sortOption: .dateAdded
        )
        .navigationTitle("My Collection")
    }
    .environment(\.collectionViewModel, MockCollectionViewModel.empty)
    .environment(authViewModel)
}

#Preview(
    "Collection List - With Data",
    traits: .previewContainer(.withData)
) {
    @Previewable @State var authViewModel = AuthViewModel()
    NavigationStack {
        CollectionListView(
            filter: .all,
            sortOption: .dateAdded
        )
        .navigationTitle("My Collection")
    }
    .environment(\.collectionViewModel, MockCollectionViewModel.empty)
    .environment(authViewModel)
}

#Preview(
    "Collection List - Reading Filter",
    traits: .previewContainer(.withData)
) {
    @Previewable @State var authViewModel = AuthViewModel()
    NavigationStack {
        CollectionListView(
            filter: .reading,
            sortOption: .dateAdded
        )
        .navigationTitle("Currently Reading")
    }
    .environment(\.collectionViewModel, MockCollectionViewModel.empty)
    .environment(authViewModel)
}

#Preview(
    "Collection List - Complete Filter",
    traits: .previewContainer(.withData)
) {
    @Previewable @State var authViewModel = AuthViewModel()
    NavigationStack {
        CollectionListView(
            filter: .complete,
            sortOption: .dateAdded
        )
        .navigationTitle("Complete")
    }
    .environment(\.collectionViewModel, MockCollectionViewModel.empty)
    .environment(authViewModel)
}
