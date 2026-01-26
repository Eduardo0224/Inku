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

/// Main view for Advanced Filters feature.
///
/// Provides a comprehensive filtering interface with multi-criteria search,
/// sorting options, and paginated results display.
struct AdvancedFilterView: View {

    // MARK: - States

    @State private var viewModel: AdvancedFiltersViewModel
    @State private var showGenreSelector = false
    @State private var showDemographicSelector = false
    @State private var showThemeSelector = false
    @State private var showSortOptions = false

    // MARK: - Initializers

    init(interactor: AdvancedFiltersInteractorProtocol = AdvancedFiltersInteractor()) {
        self.viewModel = AdvancedFiltersViewModel(interactor: interactor)
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: InkuSpacing.spacing20) {
                    // Filter Form
                    filterFormSection

                    // Search Button
                    searchButton

                    // Results Section
                    if viewModel.hasSearched {
                        resultsSection
                    }
                }
                .padding(InkuSpacing.spacing16)
            }
            .navigationTitle("Advanced Filters")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    if viewModel.hasActiveFilters {
                        Button("Clear All") {
                            viewModel.clearAllFilters()
                        }
                        .fontWeight(.medium)
                    }
                }
            }
            .task {
                await viewModel.loadFilterOptions()
            }
            .sheet(isPresented: $showGenreSelector) {
                MultiSelectFilterView(
                    selectedItems: $viewModel.selectedGenres,
                    title: "Genres",
                    options: viewModel.availableGenres,
                    icon: "theatermasks.fill"
                )
            }
            .sheet(isPresented: $showDemographicSelector) {
                MultiSelectFilterView(
                    selectedItems: $viewModel.selectedDemographics,
                    title: "Demographics",
                    options: viewModel.availableDemographics,
                    icon: "person.3.fill"
                )
            }
            .sheet(isPresented: $showThemeSelector) {
                MultiSelectFilterView(
                    selectedItems: $viewModel.selectedThemes,
                    title: "Themes",
                    options: viewModel.availableThemes,
                    icon: "tag.fill"
                )
            }
            .sheet(isPresented: $showSortOptions) {
                SortOptionsView(selectedOption: $viewModel.sortOption)
                    .onChange(of: viewModel.sortOption) { _, _ in
                        viewModel.applySorting()
                    }
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
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

    @ViewBuilder
    private var filterFormSection: some View {
        VStack(spacing: InkuSpacing.spacing16) {
            // Title Search
            VStack(alignment: .leading, spacing: InkuSpacing.spacing8) {
                Text("Title")
                    .font(.inkuText(.headlineSmall))
                    .foregroundStyle(.secondary)

                TextField("Search by title", text: $viewModel.searchTitle)
                    .textFieldStyle(.roundedBorder)
            }

            // Author Search
            VStack(alignment: .leading, spacing: InkuSpacing.spacing8) {
                Text("Author")
                    .font(.inkuText(.headlineSmall))
                    .foregroundStyle(.secondary)

                TextField("First name", text: $viewModel.searchAuthorFirstName)
                    .textFieldStyle(.roundedBorder)

                TextField("Last name", text: $viewModel.searchAuthorLastName)
                    .textFieldStyle(.roundedBorder)
            }

            Divider()

            // Multi-select Filters
            FilterSelectorButton(
                title: "Genres",
                selectedCount: viewModel.selectedGenres.count,
                icon: "theatermasks.fill"
            ) {
                showGenreSelector = true
            }

            FilterSelectorButton(
                title: "Demographics",
                selectedCount: viewModel.selectedDemographics.count,
                icon: "person.3.fill"
            ) {
                showDemographicSelector = true
            }

            FilterSelectorButton(
                title: "Themes",
                selectedCount: viewModel.selectedThemes.count,
                icon: "tag.fill"
            ) {
                showThemeSelector = true
            }

            Divider()

            // Search Mode Toggle
            Toggle(isOn: $viewModel.searchContains) {
                VStack(alignment: .leading, spacing: InkuSpacing.spacing4) {
                    Text("Search Mode")
                        .font(.inkuText(.headlineSmall))

                    Text(viewModel.searchContains ? "Contains text" : "Begins with text")
                        .font(.inkuText(.bodySmall))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(InkuSpacing.spacing16)
        .inkuCard()
    }

    @ViewBuilder
    private var searchButton: some View {
        Button {
            Task {
                await viewModel.performSearch()
            }
        } label: {
            HStack {
                Image(systemName: "magnifyingglass")
                Text("Search")
                    .fontWeight(.semibold)

                if viewModel.activeFilterCount > 0 {
                    Text("(\(viewModel.activeFilterCount))")
                        .fontWeight(.medium)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(InkuSpacing.spacing12)
            .background(.inkuAccent)
            .foregroundStyle(.white)
            .cornerRadius(InkuRadius.radius12)
        }
        .disabled(viewModel.isLoading || !viewModel.hasActiveFilters)
        .opacity((viewModel.isLoading || !viewModel.hasActiveFilters) ? 0.6 : 1.0)
    }

    @ViewBuilder
    private var resultsSection: some View {
        VStack(alignment: .leading, spacing: InkuSpacing.spacing16) {
            // Results Header
            HStack {
                Text("\(viewModel.searchResults.count) Results")
                    .font(.inkuText(.headlineMedium))
                    .fontWeight(.semibold)

                Spacer()

                Button {
                    showSortOptions = true
                } label: {
                    HStack(spacing: InkuSpacing.spacing4) {
                        Image(systemName: "arrow.up.arrow.down")
                        Text("Sort")
                    }
                    .font(.inkuText(.bodyMedium))
                    .foregroundStyle(.inkuAccent)
                }
            }

            // Results List
            if viewModel.isLoading {
                LoadingResultsView()
            } else if viewModel.searchResults.isEmpty {
                EmptySearchResultsView()
            } else {
                resultsListView
            }
        }
    }

    @ViewBuilder
    private var resultsListView: some View {
        LazyVStack(spacing: InkuSpacing.spacing12) {
            ForEach(viewModel.searchResults) { manga in
                NavigationLink(value: manga) {
                    MangaResultRow(manga: manga)
                }
                .buttonStyle(.plain)
            }

            // Load More
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

private struct FilterSelectorButton: View {
    let title: String
    let selectedCount: Int
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(.inkuAccent)
                    .frame(width: 24)

                Text(title)
                    .foregroundStyle(.primary)

                Spacer()

                if selectedCount > 0 {
                    Text("\(selectedCount)")
                        .font(.inkuText(.bodySmall))
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, InkuSpacing.spacing8)
                        .padding(.vertical, InkuSpacing.spacing4)
                        .background(.inkuAccent)
                        .cornerRadius(InkuRadius.radius8)
                }

                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
                    .font(.system(size: 14))
            }
            .padding(InkuSpacing.spacing12)
            .background(Color(.systemBackground))
            .cornerRadius(InkuRadius.radius8)
            .overlay(
                RoundedRectangle(cornerRadius: InkuRadius.radius8)
                    .stroke(Color(.separator), lineWidth: 1)
            )
        }
    }
}

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
                    .fill(Color(.systemGray5))
            }
            .frame(width: 60, height: 90)
            .cornerRadius(InkuRadius.radius8)

            VStack(alignment: .leading, spacing: InkuSpacing.spacing4) {
                Text(manga.title)
                    .font(.inkuText(.headlineSmall))
                    .fontWeight(.semibold)
                    .lineLimit(2)

                if let score = manga.score {
                    HStack(spacing: InkuSpacing.spacing4) {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.inkuAccent)
                        Text(String(format: "%.2f", score))
                            .fontWeight(.medium)
                    }
                    .font(.inkuText(.bodySmall))
                }

                if let volumes = manga.volumes {
                    Text("\(volumes) volumes")
                        .font(.inkuText(.bodySmall))
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .padding(InkuSpacing.spacing12)
        .inkuCard()
    }
}

private struct LoadingResultsView: View {
    var body: some View {
        VStack(spacing: InkuSpacing.spacing12) {
            ProgressView()
            Text("Searching...")
                .font(.inkuText(.bodyMedium))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(InkuSpacing.spacing32)
    }
}

private struct EmptySearchResultsView: View {
    var body: some View {
        ContentUnavailableView {
            Label("No Results", systemImage: "magnifyingglass")
        } description: {
            Text("Try adjusting your filters")
        }
        .padding(InkuSpacing.spacing32)
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
                Text("Load More")
                    .fontWeight(.medium)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(InkuSpacing.spacing12)
        .background(Color(.systemGray6))
        .cornerRadius(InkuRadius.radius8)
        .disabled(isLoading)
    }
}

// MARK: - Previews

#Preview("Empty State") {
    AdvancedFilterView(interactor: MockAdvancedFiltersInteractor())
}

#Preview("With Filters") {
    let view = AdvancedFilterView(interactor: MockAdvancedFiltersInteractor())
    view.viewModel = .mockWithFilters
    return view
}

#Preview("With Search Results") {
    let view = AdvancedFilterView(interactor: MockAdvancedFiltersInteractor())
    view.viewModel = .mockWithSearch
    return view
}

#Preview("Loading State") {
    let view = AdvancedFilterView(interactor: MockAdvancedFiltersInteractor())
    view.viewModel = .mockLoading
    return view
}
