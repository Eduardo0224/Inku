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

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.showsEmptyState {
                    emptyStateView
                } else if viewModel.showsNoResults {
                    noResultsView
                } else if viewModel.isSearching && viewModel.searchResults.isEmpty {
                    skeletonView
                } else {
                    resultsView
                }
            }
            .navigationTitle(L10n.Search.Screen.title)
            .searchable(
                text: $viewModel.searchText,
                prompt: L10n.Search.Placeholder.search
            )
            .searchScopes($viewModel.searchScope) {
                ForEach(SearchScope.allCases) { scope in
                    Text(scope.displayText)
                        .tag(scope)
                }
            }
            .alert(
                L10n.Error.title,
                isPresented: Binding(
                    get: { viewModel.errorMessage != nil && !viewModel.searchResults.isEmpty },
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
        InkuEmptyView(
            icon: "magnifyingglass",
            iconSize: .large,
            title: L10n.Search.EmptyState.title,
            subtitle: L10n.Search.EmptyState.message,
            symbolEffect: .pulse,
            symbolEffectOptions: .repeating
        )
        .background(Color.inkuSurface)
    }

    private var noResultsView: some View {
        InkuEmptyView(
            icon: "doc.text.magnifyingglass",
            iconSize: .large,
            title: L10n.Search.NoResults.title,
            subtitle: L10n.Search.NoResults.message,
            symbolEffect: .bounce,
            symbolEffectOptions: .repeat(2)
        )
        .background(Color.inkuSurface)
    }

    private var resultsView: some View {
        InkuListContainer(
            title: resultsTitle,
            subtitle: viewModel.searchText.isEmpty ? nil : L10n.Search.Results.forQuery(viewModel.searchText),
            scrollDismissesKeyboard: .immediately
        ) {
            VStack(spacing: InkuSpacing.spacing16) {
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: InkuSpacing.spacing16), count: 2),
                    spacing: InkuSpacing.spacing16
                ) {
                    ForEach(viewModel.searchResults) { manga in
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
                            if manga == viewModel.searchResults.last {
                                Task {
                                    await viewModel.loadMoreResults()
                                }
                            }
                        }
                    }
                }

                if viewModel.isLoadingMore {
                    InkuLoadingView(message: L10n.Common.loading)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, InkuSpacing.spacing16)
                }
            }
        }
    }

    private var resultsTitle: String {
        let count = viewModel.searchResults.count
        let resultWord = count == 1 ? L10n.Search.Results.singular : L10n.Search.Results.plural
        return "\(count) \(resultWord)"
    }

    private var skeletonView: some View {
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
