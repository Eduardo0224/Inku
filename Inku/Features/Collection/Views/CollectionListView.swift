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

    // MARK: - States

    @State private var searchText = ""
    @State private var mangaToEdit: CollectionManga?
    @State private var mangaToDelete: CollectionManga?

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
    }

    // MARK: - Private Views

    private var collectionList: some View {
        ScrollView {
            LazyVStack(spacing: InkuSpacing.spacing16) {
                ForEach(filteredMangas) { manga in
                    CollectionItemCard(
                        collectionManga: manga,
                        onEdit: { editManga(manga) },
                        onDelete: { deleteManga(manga) }
                    )
                    .buttonStyle(.plain)
                }
            }
            .padding(InkuSpacing.spacing16)
        }
        .background(Color.inkuSurface)
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
        try? viewModel.removeFromCollection(manga)
        mangaToDelete = nil
    }
}

// MARK: - Previews

#Preview(
    "Collection List - Empty All",
    traits: .previewContainer(.empty)
) {
    NavigationStack {
        CollectionListView(
            filter: .all,
            sortOption: .dateAdded
        )
        .navigationTitle("My Collection")
    }
    .environment(\.collectionViewModel, MockCollectionViewModel.empty)
}

#Preview(
    "Collection List - With Data",
    traits: .previewContainer(.withData)
) {
    NavigationStack {
        CollectionListView(
            filter: .all,
            sortOption: .dateAdded
        )
        .navigationTitle("My Collection")
    }
    .environment(\.collectionViewModel, MockCollectionViewModel.empty)
}

#Preview(
    "Collection List - Reading Filter",
    traits: .previewContainer(.withData)
) {
    NavigationStack {
        CollectionListView(
            filter: .reading,
            sortOption: .dateAdded
        )
        .navigationTitle("Currently Reading")
    }
    .environment(\.collectionViewModel, MockCollectionViewModel.empty)
}

#Preview(
    "Collection List - Complete Filter",
    traits: .previewContainer(.withData)
) {
    NavigationStack {
        CollectionListView(
            filter: .complete,
            sortOption: .dateAdded
        )
        .navigationTitle("Complete")
    }
    .environment(\.collectionViewModel, MockCollectionViewModel.empty)
}
