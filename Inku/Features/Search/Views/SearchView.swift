//
//  SearchView.swift
//  Inku
//
//  Created by Eduardo Andrade on 02/01/26.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2026 Eduardo Andrade. All rights reserved.
//

import SwiftUI
import InkuUI

struct SearchView: View {

    // MARK: - States

    @State private var viewModel: SearchViewModel

    // MARK: - Initializers

    init(interactor: SearchInteractorProtocol = SearchInteractor()) {
        self.viewModel = SearchViewModel(interactor: interactor)
    }

    // MARK: - Computed Properties

    private var searchPlaceholder: String {
        switch viewModel.searchScope {
        case .title:
            L10n.Search.Placeholder.manga
        case .author:
            L10n.Search.Placeholder.author
        }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.showsEmptyState {
                    emptyStateView
                } else if viewModel.showsNoResults {
                    noResultsView
                } else if viewModel.isSearching && !viewModel.hasResults {
                    skeletonView
                } else {
                    resultsView
                }
            }
            .navigationTitle(L10n.Search.Screen.title)
            .searchable(
                text: $viewModel.searchText,
                placement: .toolbar,
                prompt: searchPlaceholder
            )
            .searchScopes($viewModel.searchScope, activation: .onTextEntry) {
                ForEach(SearchScope.allCases) { scope in
                    Text(scope.displayText)
                        .tag(scope)
                }
            }
            .alert(
                L10n.Error.title,
                isPresented: Binding(
                    get: { viewModel.errorMessage != nil && viewModel.hasResults },
                    set: { if !$0 { viewModel.errorMessage = nil } }
                )
            ) {
                Button(L10n.Common.ok, role: .cancel) {
                    viewModel.errorMessage = nil
                }
                Button(L10n.Common.retry) {
                    Task {
                        await viewModel.performSearch()
                    }
                }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
            .navigationDestination(for: Manga.self) { manga in
                MangaDetailView(manga: manga)
            }
        }
    }

    // MARK: - Private Views

    private var emptyStateView: some View {
        Group {
            switch viewModel.searchScope {
            case .title:
                InkuEmptyView(
                    icon: "magnifyingglass",
                    iconSize: .large,
                    title: L10n.Search.EmptyState.Manga.title,
                    subtitle: L10n.Search.EmptyState.Manga.message,
                    symbolEffect: .pulse,
                    symbolEffectOptions: .repeating
                )
            case .author:
                InkuEmptyView(
                    icon: "person.text.rectangle",
                    iconSize: .large,
                    title: L10n.Search.EmptyState.Author.title,
                    subtitle: L10n.Search.EmptyState.Author.message,
                    symbolEffect: .pulse,
                    symbolEffectOptions: .repeating
                )
            }
        }
        .background(Color.inkuSurface)
    }

    private var noResultsView: some View {
        Group {
            switch viewModel.searchScope {
            case .title:
                InkuEmptyView(
                    icon: "doc.text.magnifyingglass",
                    iconSize: .large,
                    title: L10n.Search.NoResults.Manga.title,
                    subtitle: L10n.Search.NoResults.Manga.message,
                    symbolEffect: .bounce,
                    symbolEffectOptions: .repeat(2)
                )
            case .author:
                InkuEmptyView(
                    icon: "person.crop.circle.badge.questionmark",
                    iconSize: .large,
                    title: L10n.Search.NoResults.Author.title,
                    subtitle: L10n.Search.NoResults.Author.message,
                    symbolEffect: .bounce,
                    symbolEffectOptions: .repeat(2)
                )
            }
        }
        .background(Color.inkuSurface)
    }

    private var resultsView: some View {
        Group {
            switch viewModel.searchScope {
            case .title:
                MangaResultsView(
                    mangas: viewModel.mangaResults,
                    searchText: viewModel.searchText,
                    isLoadingMore: viewModel.isLoadingMore,
                    mangaSearchMode: $viewModel.mangaSearchMode
                ) { manga in
                    Task {
                        await viewModel.loadMoreResults()
                    }
                }
            case .author:
                AuthorResultsView(
                    groupedAuthors: viewModel.groupedAuthors,
                    searchText: viewModel.searchText
                )
            }
        }
    }

    private var skeletonView: some View {
        Group {
            switch viewModel.searchScope {
            case .title:
                mangaSkeletonView
            case .author:
                authorSkeletonView
            }
        }
    }

    private var mangaSkeletonView: some View {
        InkuListContainer(
            title: L10n.Search.Results.searching,
            subtitle: viewModel.searchText.isEmpty ? nil : L10n.Search.Results.forQuery(viewModel.searchText),
            showsDivider: true,
            scrollDisabled: true
        ) {
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: InkuSpacing.spacing16), count: 2),
                spacing: InkuSpacing.spacing16
            ) {
                ForEach(0..<8, id: \.self) { _ in
                    InkuSearchResultCard(
                        imageURL: nil,
                        title: "Loading Title",
                        subtitle: "Loading Subtitle",
                        badge: "Genre",
                        isLoading: true
                    )
                }
            }
        }
    }

    private var authorSkeletonView: some View {
        InkuListContainer(
            title: L10n.Search.Results.searching,
            subtitle: viewModel.searchText.isEmpty ? nil : L10n.Search.Results.forQuery(viewModel.searchText),
            showsDivider: true,
            scrollDisabled: true
        ) {
            LazyVStack(spacing: InkuSpacing.spacing12) {
                ForEach(0..<20, id: \.self) { _ in
                    InkuAuthorResultCard(
                        firstName: "Loading",
                        lastName: "Author",
                        role: "Role",
                        isLoading: true
                    )
                }
            }
        }
    }
}

// MARK: - Previews

#Preview("Search - Empty") {
    SearchView(interactor: MockSearchInteractor())
}

#Preview("Search - With Results") {
    SearchView(interactor: MockSearchInteractor())
}

#Preview("Search - Error") {
    SearchView(interactor: MockSearchInteractorWithError())
}
