//
//  MangaListView.swift
//  Inku
//
//  Created by Eduardo Andrade on 23/12/25.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2025 Eduardo Andrade. All rights reserved.
//

import SwiftUI
import InkuUI

struct MangaListView: View {

    // MARK: - States

    @State private var viewModel: MangaListViewModel
    @State private var showingAdvancedFilters = false

    @AppStorage("mangaListPresentationMode")
    private var presentationMode: MangaPresentationMode = .list

    // MARK: - Environment

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    // MARK: - Initializers

    init(interactor: MangaListInteractorProtocol = MangaListInteractor()) {
        self.viewModel = MangaListViewModel(interactor: interactor)
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Group {
                if let errorMessage = viewModel.errorMessage, viewModel.mangas.isEmpty {
                    errorView(message: errorMessage)
                } else if viewModel.isLoading && viewModel.mangas.isEmpty {
                    skeletonView
                } else if viewModel.mangas.isEmpty {
                    EmptyStateView()
                } else {
                    contentView
                }
            }
            .navigationTitle(L10n.MangaList.Screen.title)
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .topBarLeading) {
                    presentationModeToggle
                }

                ToolbarItem(placement: .topBarTrailing) {
                    if viewModel.isAdvancedFilterActive {
                        Menu {
                            clearFiltersButton
                            Divider()
                            advancedFiltersButton
                        } label: {
                            Image(systemName: "slider.horizontal.2.square.on.square")
                        }
                    } else {
                        advancedFiltersButton
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    filterMenu
                        .disabled(viewModel.errorMessage != nil)
                }
                #else
                ToolbarItem(placement: .automatic) {
                    presentationModeToggle
                }

                ToolbarItem(placement: .automatic) {
                    if viewModel.isAdvancedFilterActive {
                        Menu {
                            clearFiltersButton
                            Divider()
                            advancedFiltersButton
                        } label: {
                            Image(systemName: "slider.horizontal.2.square.on.square")
                        }
                    } else {
                        advancedFiltersButton
                    }
                }

                ToolbarItem(placement: .automatic) {
                    filterMenu
                        .disabled(viewModel.errorMessage != nil)
                }
                #endif
            }
            .sheet(isPresented: $showingAdvancedFilters) {
                AdvancedFilterView(
                    preloadedGenres: viewModel.genres.map(\.genre),
                    preloadedDemographics: viewModel.demographics.map(\.demographic),
                    preloadedThemes: viewModel.themes.map(\.theme),
                    preselectedSearch: viewModel.currentAdvancedSearch,
                    preselectedSortOption: viewModel.currentSortOption
                ) { search, sortOption in
                    Task {
                        await viewModel.applyAdvancedSearch(search, sortOption: sortOption)
                    }
                }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationSizing(.form)
            }
            .alert(
                L10n.Error.title,
                isPresented: Binding(
                    get: { viewModel.errorMessage != nil && !viewModel.mangas.isEmpty },
                    set: { if !$0 { viewModel.errorMessage = nil } }
                )
            ) {
                Button(L10n.Common.ok, role: .cancel) {
                    viewModel.errorMessage = nil
                }
                Button(L10n.Common.retry) {
                    Task {
                        await viewModel.loadMangas()
                    }
                }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
            .task {
                viewModel.loadInitialDataIfNeeded()
            }
            .navigationDestination(for: Manga.self) { manga in
                MangaDetailView(manga: manga)
            }
        }
    }

    // MARK: - Private Views

    @ViewBuilder
    private var contentView: some View {
        switch presentationMode {
        case .list:
            listView
        case .grid:
            MangaGridView(
                mangas: viewModel.mangas,
                isLoadingMore: viewModel.isLoadingMore,
                onMangaAppear: { _ in
                    Task {
                        await viewModel.loadMoreMangas()
                    }
                }
            )
        }
    }

    private var listView: some View {
        GeometryReader { geometry in
            ScrollView {
                if shouldUseGridLayout(for: geometry.size.width) {
                    LazyVGrid(
                        columns: Array(
                            repeating: GridItem(.flexible(), spacing: InkuSpacing.spacing16),
                            count: listColumnCount(for: geometry.size.width)
                        ),
                        spacing: InkuSpacing.spacing16
                    ) {
                        mangaRows
                    }
                    .padding(InkuSpacing.spacing16)
                } else {
                    LazyVStack(spacing: InkuSpacing.spacing16) {
                        mangaRows
                    }
                    .padding(InkuSpacing.spacing16)
                }

                if viewModel.isLoadingMore {
                    InkuLoadingView(message: L10n.Common.loading)
                        .padding(InkuSpacing.spacing16)
                }
            }
            .background(Color.inkuSurface)
        }
    }

    private var mangaRows: some View {
        ForEach(viewModel.mangas) { manga in
            NavigationLink(value: manga) {
                MangaRowView(manga: manga)
            }
            .buttonStyle(.plain)
            .task {
                if manga == viewModel.mangas.last {
                    Task {
                        await viewModel.loadMoreMangas()
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var skeletonView: some View {
        switch presentationMode {
        case .list:
            GeometryReader { geometry in
                ScrollView {
                    if shouldUseGridLayout(for: geometry.size.width) {
                        LazyVGrid(
                            columns: Array(
                                repeating: GridItem(.flexible(), spacing: InkuSpacing.spacing16),
                                count: listColumnCount(for: geometry.size.width)
                            ),
                            spacing: InkuSpacing.spacing16
                        ) {
                            ForEach(0..<20, id: \.self) { _ in
                                MangaRowView(manga: .skeletonData, isLoading: true)
                            }
                        }
                        .padding(InkuSpacing.spacing16)
                    } else {
                        LazyVStack(spacing: InkuSpacing.spacing16) {
                            ForEach(0..<10, id: \.self) { _ in
                                MangaRowView(manga: .skeletonData, isLoading: true)
                            }
                        }
                        .padding(InkuSpacing.spacing16)
                    }
                }
                .scrollDisabled(true)
                .background(Color.inkuSurface)
            }
        case .grid:
            MangaGridSkeletonView()
        }
    }

    private func errorView(message: String) -> some View {
        InkuErrorView(
            message: message,
            retryActionTitle: L10n.Common.retry
        ) {
            if viewModel.isAdvancedFilterActive {
                showingAdvancedFilters = true
            } else {
                Task {
                    await viewModel.loadMangas()
                }
            }
        }
        .background(Color.inkuSurface)
    }

    private var advancedFiltersButton: some View {
        Button {
            showingAdvancedFilters = true
        } label: {
            Label(L10n.MangaList.Filter.advancedFilters, systemImage: "slider.horizontal.3")
        }
    }

    private var clearFiltersButton: some View {
        Button(role: .destructive) {
            Task {
                await viewModel.clearFilters()
            }
        } label: {
            Label(L10n.MangaList.Filter.clear, systemImage: "xmark")
                .symbolVariant(.circle)
        }
    }

    private var filterMenu: some View {
        Menu {
            if viewModel.isFilterActive {
                clearFiltersButton
                Divider()
            }

            if !viewModel.genres.isEmpty {
                genreSubmenu
            }

            if !viewModel.demographics.isEmpty {
                demographicSubmenu
            }

            if !viewModel.themes.isEmpty {
                themeSubmenu
            }
        } label: {
            Image(
                systemName: viewModel.isFilterActive
                    ? "line.3.horizontal.decrease.circle.fill"
                    : "line.3.horizontal.decrease.circle"
            )
        }
    }

    private var genreSubmenu: some View {
        Menu {
            ForEach(viewModel.genres) { item in
                Button {
                    Task {
                        await viewModel.applyFilter(.genre(item.genre))
                    }
                } label: {
                    Label(
                        item.genre,
                        systemImage: viewModel.selectedFilter.matches(with: item.genre)
                            ? "checkmark.circle.fill"
                            : "circle"
                    )
                }
            }
        } label: {
            Label(L10n.MangaList.Filter.genre, systemImage: "tag")
        }
    }

    private var demographicSubmenu: some View {
        Menu {
            ForEach(viewModel.demographics) { item in
                Button {
                    Task {
                        await viewModel.applyFilter(.demographic(item.demographic))
                    }
                } label: {
                    Label(
                        item.demographic,
                        systemImage: viewModel.selectedFilter.matches(with: item.demographic)
                            ? "checkmark.circle.fill"
                            : "circle"
                    )
                }
            }
        } label: {
            Label(L10n.MangaList.Filter.demographic, systemImage: "person.2")
        }
    }

    private var themeSubmenu: some View {
        Menu {
            ForEach(viewModel.themes) { item in
                Button {
                    Task {
                        await viewModel.applyFilter(.theme(item.theme))
                    }
                } label: {
                    Label(
                        item.theme,
                        systemImage: viewModel.selectedFilter.matches(with: item.theme)
                            ? "checkmark.circle.fill"
                            : "circle"
                    )
                }
            }
        } label: {
            Label(L10n.MangaList.Filter.theme, systemImage: "sparkles")
        }
    }

    private var presentationModeToggle: some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                presentationMode = presentationMode == .list ? .grid : .list
            }
        } label: {
            Image(systemName: presentationMode.iconName)
                .symbolVariant(.circle.fill)
                .font(.inkuHeadline)
                .foregroundStyle(Color.inkuAccent)
        }
    }

    // MARK: - Private Functions

    private func shouldUseGridLayout(for width: CGFloat) -> Bool {
        if horizontalSizeClass == .regular {
            return true
        }

        return width >= 700
    }

    private func listColumnCount(for width: CGFloat) -> Int {
        if horizontalSizeClass == .regular {
            return width > 1000 ? 2 : 1
        }

        return 2
    }
}

// MARK: - Previews

#Preview("Default") {
    MangaListView()
        .environment(\.collectionViewModel, MockCollectionViewModel.empty)
}

#Preview("With Mock Data") {
    MangaListView(interactor: MockMangaListInteractor())
        .environment(\.collectionViewModel, MockCollectionViewModel.withData)
}

#Preview("With Error") {
    MangaListView(interactor: MockMangaListInteractorWithError())
        .environment(\.collectionViewModel, MockCollectionViewModel.withData)
}
