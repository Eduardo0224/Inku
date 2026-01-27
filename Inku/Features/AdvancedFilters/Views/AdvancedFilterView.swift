//
//  AdvancedFilterView.swift
//  Inku
//
//  Created by Eduardo Andrade on 26/01/26.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2026 Eduardo Andrade. All rights reserved.
//

import SwiftUI
import InkuUI

struct AdvancedFilterView: View {

    // MARK: - States

    @State private var viewModel: AdvancedFiltersViewModel
    @State private var genresExpanded = false
    @State private var demographicsExpanded = false
    @State private var themesExpanded = false

    // MARK: - Initializers

    init(interactor: AdvancedFiltersInteractorProtocol = AdvancedFiltersInteractor()) {
        self.viewModel = AdvancedFiltersViewModel(interactor: interactor)
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: InkuSpacing.spacing20) {
                    filterFormSection
                    searchButton

                    if viewModel.hasSearched {
                        resultsSection
                    }
                }
                .padding(InkuSpacing.spacing16)
            }
            .navigationTitle(L10n.AdvancedFilters.Screen.title)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    if viewModel.hasActiveFilters {
                        Button(L10n.AdvancedFilters.Button.clearAll) {
                            viewModel.clearAllFilters()
                        }
                        .fontWeight(.medium)
                        .tint(Color.inkuAccentStrong)
                    }
                }
            }
            .task {
                await viewModel.loadFilterOptions()
            }
            .background(Color.inkuSurface)
            .alert(L10n.Error.title, isPresented: .constant(viewModel.errorMessage != nil)) {
                Button(L10n.Common.ok) {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
        }
    }

    // MARK: - Private Views

    private var filterFormSection: some View {
        VStack(spacing: InkuSpacing.spacing16) {
            if viewModel.hasFilterCategories {
                filterCategoriesSection
            }
            textFieldsSection
            searchModeSection
        }
    }

    private var textFieldsSection: some View {
        VStack(spacing: InkuSpacing.spacing20) {
            VStack(alignment: .leading, spacing: InkuSpacing.spacing8) {
                Text(L10n.AdvancedFilters.Filter.title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                TextField(L10n.AdvancedFilters.Placeholder.title, text: $viewModel.searchTitle)
                    .textFieldStyle(.automatic)
            }

            VStack(alignment: .leading, spacing: InkuSpacing.spacing8) {
                Text(L10n.AdvancedFilters.Filter.author)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                TextField(L10n.AdvancedFilters.Placeholder.firstName, text: $viewModel.searchAuthorFirstName)
                    .textFieldStyle(.automatic)

                Divider()

                TextField(L10n.AdvancedFilters.Placeholder.lastName, text: $viewModel.searchAuthorLastName)
                    .textFieldStyle(.automatic)
            }
        }
        .padding(InkuSpacing.spacing16)
        .inkuCard()
    }

    private var filterCategoriesSection: some View {
        VStack(spacing: InkuSpacing.spacing16) {
            // Genres
            FilterDisclosureSection(
                title: L10n.AdvancedFilters.Filter.genres,
                icon: "theatermasks.fill",
                options: viewModel.availableGenres,
                selectedItems: $viewModel.selectedGenres,
                isExpanded: $genresExpanded
            )

            // Demographics
            FilterDisclosureSection(
                title: L10n.AdvancedFilters.Filter.demographics,
                icon: "person.3.fill",
                options: viewModel.availableDemographics,
                selectedItems: $viewModel.selectedDemographics,
                isExpanded: $demographicsExpanded
            )

            // Themes
            FilterDisclosureSection(
                title: L10n.AdvancedFilters.Filter.themes,
                icon: "tag.fill",
                options: viewModel.availableThemes,
                selectedItems: $viewModel.selectedThemes,
                isExpanded: $themesExpanded
            )
        }
        .padding(InkuSpacing.spacing16)
        .inkuCard()
    }

    private var searchModeSection: some View {
        VStack(alignment: .leading, spacing: InkuSpacing.spacing12) {
            Text(L10n.AdvancedFilters.Filter.searchMode)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Picker("", selection: $viewModel.searchContains) {
                Text(L10n.AdvancedFilters.SearchMode.beginsWith).tag(false)
                Text(L10n.AdvancedFilters.SearchMode.contains).tag(true)
            }
            .pickerStyle(.segmented)
        }
        .padding(InkuSpacing.spacing16)
        .inkuCard()
    }

    private var searchButton: some View {
        Button {
            Task {
                await viewModel.performSearch()
            }
        } label: {
            HStack {
                Image(systemName: "magnifyingglass")
                Text(L10n.AdvancedFilters.Button.search)
                    .fontWeight(.semibold)

                if viewModel.activeFilterCount > 0 {
                    Text("(\(viewModel.activeFilterCount))")
                        .fontWeight(.medium)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(InkuSpacing.spacing12)
            .background(Color.inkuAccentStrong)
            .foregroundStyle(.white)
            .cornerRadius(InkuRadius.radius12)
        }
        .disabled(viewModel.isLoading || !viewModel.hasActiveFilters)
        .opacity((viewModel.isLoading || !viewModel.hasActiveFilters) ? 0.6 : 1.0)
    }

    private var resultsSection: some View {
        VStack(alignment: .leading, spacing: InkuSpacing.spacing16) {
            HStack {
                Text("\(viewModel.searchResults.count) \(L10n.AdvancedFilters.Results.count)")
                    .font(.headline)
                    .fontWeight(.semibold)

                Spacer()

                Menu {
                    ForEach(SearchSortOption.allCases) { option in
                        Button {
                            viewModel.sortOption = option
                            viewModel.applySorting()
                        } label: {
                            HStack {
                                Image(systemName: option.iconName)
                                Text(option.displayName)

                                if viewModel.sortOption == option {
                                    Spacer()
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack(spacing: InkuSpacing.spacing4) {
                        Image(systemName: "arrow.up.arrow.down")
                        Text(L10n.AdvancedFilters.Button.sort)
                    }
                    .font(.subheadline)
                    .foregroundStyle(Color.inkuAccent)
                } primaryAction: {
                    // No primary action needed
                }
            }

            if viewModel.isLoading {
                InkuLoadingView(message: L10n.AdvancedFilters.State.searching)
                    .padding(InkuSpacing.spacing32)
            } else if viewModel.searchResults.isEmpty {
                InkuEmptyView(
                    icon: "magnifyingglass",
                    iconSize: .large,
                    title: L10n.AdvancedFilters.Empty.noResults,
                    subtitle: L10n.AdvancedFilters.Empty.adjustFilters
                )
                .padding(InkuSpacing.spacing32)
            } else {
                resultsListView
            }
        }
    }

    private var resultsListView: some View {
        LazyVStack(spacing: InkuSpacing.spacing12) {
            ForEach(viewModel.searchResults) { manga in
                NavigationLink(value: manga) {
                    MangaResultRow(manga: manga)
                }
                .buttonStyle(.plain)
            }

            if viewModel.hasMorePages {
                LoadMoreButton(isLoading: viewModel.isLoadingMore) {
                    Task {
                        await viewModel.loadMoreResults()
                    }
                }
            }
        }
        .navigationDestination(for: Manga.self) { manga in
            MangaDetailView(manga: manga)
        }
    }

}

// MARK: - Supporting Components

private struct MangaResultRow: View {
    let manga: Manga

    var body: some View {
        HStack(spacing: InkuSpacing.spacing12) {
            AsyncImage(url: manga.coverImageURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.inkuSurfaceSecondary)
            }
            .frame(width: 60, height: 90)
            .cornerRadius(InkuRadius.radius8)

            VStack(alignment: .leading, spacing: InkuSpacing.spacing4) {
                Text(manga.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(2)

                if let score = manga.score {
                    HStack(spacing: InkuSpacing.spacing4) {
                        Image(systemName: "star")
                            .symbolVariant(.fill)
                            .foregroundStyle(Color.inkuAccent)
                        Text(score.formatted(.number.precision(.fractionLength(2))))
                            .fontWeight(.medium)
                    }
                    .font(.caption)
                }

                if let volumes = manga.volumes {
                    Text("\(volumes) volumes")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .padding(InkuSpacing.spacing12)
        .inkuCard()
    }
}

private struct LoadMoreButton: View {
    let isLoading: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            if isLoading {
                ProgressView()
            } else {
                Text(L10n.AdvancedFilters.Button.loadMore)
                    .fontWeight(.medium)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(InkuSpacing.spacing12)
        .background(Color.inkuSurfaceSecondary)
        .cornerRadius(InkuRadius.radius8)
        .disabled(isLoading)
    }
}

// MARK: - Previews

#Preview("Default") {
    AdvancedFilterView(interactor: MockAdvancedFiltersInteractor())
}

#Preview("Empty Categories") {
    AdvancedFilterView(interactor: MockAdvancedFiltersInteractorEmptyCategories())
}

#Preview("With Errors") {
    AdvancedFilterView(interactor: MockAdvancedFiltersInteractorWithError())
}

