//
//  CollectionView.swift
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

struct CollectionView: View {

    // MARK: - Environment

    @Environment(\.modelContext) private var modelContext
    @Environment(\.collectionViewModel) private var viewModel

    // MARK: - States

    @State private var selectedFilter: CollectionFilter = .all
    @State private var selectedSortOption: CollectionSortOption = .dateAdded
    @State private var showingStats = false
    @State private var navigationPath = NavigationPath()

    // MARK: - Body

    var body: some View {
        NavigationStack(path: $navigationPath) {
            CollectionListView(
                filter: selectedFilter,
                sortOption: selectedSortOption
            )
            .id("\(selectedFilter)-\(selectedSortOption.rawValue)")
            .navigationTitle(L10n.Collection.Screen.title)
            .navigationDestination(for: Manga.self) { manga in
                MangaDetailView(manga: manga)
            }
            .toolbar {
                if !viewModel.isLoadingManga {
                    toolbarContent
                }
            }
            .sheet(isPresented: $showingStats) {
                CollectionStatsView()
            }
        }
        .overlay {
            if viewModel.isLoadingManga {
                loadingOverlay
            }
        }
        .toolbar(
            viewModel.isLoadingManga ? .hidden : .visible,
            for: .tabBar
        )
        .task {
            viewModel.setModelContext(modelContext)
        }
        .onChange(of: viewModel.loadedManga) { _, loadedManga in
            if let manga = loadedManga {
                navigationPath.append(manga)
            }
        }
    }

    // MARK: - Private Views

    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            InkuLoadingView(message: L10n.Common.loading)
                .padding(InkuSpacing.spacing32)
                .background {
                    RoundedRectangle(cornerRadius: InkuRadius.radius16)
                        .fill(.regularMaterial)
                }
                .frame(width: 150, height: 150)
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                showingStats = true
            } label: {
                Label(L10n.Collection.Stats.title, systemImage: "chart.bar")
            }
        }

        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                filterMenu
                Divider()
                sortMenu
            } label: {
                Label(L10n.Collection.Filter.title, systemImage: "line.3.horizontal.decrease")
                    .symbolVariant(.circle)
            }
        }
    }

    private var filterMenu: some View {
        Menu {
            ForEach(CollectionFilter.allCases) { filter in
                Button {
                    selectedFilter = filter
                } label: {
                    Label(filter.displayText, systemImage: filter.icon)
                    if selectedFilter == filter {
                        Image(systemName: "checkmark")
                    }
                }
            }
        } label: {
            Label(L10n.Collection.Filter.title, systemImage: "line.3.horizontal.decrease")
        }
    }

    private var sortMenu: some View {
        Menu {
            ForEach(CollectionSortOption.allCases) { option in
                Button {
                    selectedSortOption = option
                } label: {
                    Label(option.displayText, systemImage: option.icon)
                    if selectedSortOption == option {
                        Image(systemName: "checkmark")
                    }
                }
            }
        } label: {
            Label(L10n.Collection.Sort.title, systemImage: "arrow.up.arrow.down")
        }
    }
}

// MARK: - Previews

#Preview(
    "Collection - Empty",
    traits: .previewContainer(.empty)
) {
    CollectionView()
        .environment(\.collectionViewModel, MockCollectionViewModel.empty)
}

#Preview(
    "Collection - With Data",
    traits: .previewContainer(.withData)
) {
    CollectionView()
        .environment(\.collectionViewModel, MockCollectionViewModel.withData)
}
