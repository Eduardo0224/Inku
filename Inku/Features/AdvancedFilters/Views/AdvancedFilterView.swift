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

                TextField(L10n.AdvancedFilters.Placeholder.lastName, text: $viewModel.searchAuthorLastName)
                    .textFieldStyle(.automatic)
            }

            Divider()

            // Genres
            DisclosureGroup(
                isExpanded: $genresExpanded,
                content: {
                    if !viewModel.availableGenres.isEmpty {
                        FlowLayout(spacing: InkuSpacing.spacing8) {
                            ForEach(viewModel.availableGenres, id: \.self) { genre in
                                InkuBadge(
                                    text: genre,
                                    style: viewModel.selectedGenres.contains(genre) ? .accent : .secondary
                                )
                                .onTapGesture {
                                    toggleGenre(genre)
                                }
                            }
                        }
                        .padding(.top, InkuSpacing.spacing8)
                    }
                },
                label: {
                    HStack {
                        Image(systemName: "theatermasks.fill")
                            .foregroundStyle(Color.inkuAccent)
                            .frame(width: 24)

                        Text(L10n.AdvancedFilters.Filter.genres)
                            .foregroundStyle(.primary)

                        Spacer()

                        if viewModel.selectedGenres.count > 0 {
                            Text("\(viewModel.selectedGenres.count)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .padding(.horizontal, InkuSpacing.spacing8)
                                .padding(.vertical, InkuSpacing.spacing4)
                                .background(Color.inkuAccent)
                                .cornerRadius(InkuRadius.radius8)
                        }
                    }
                }
            )

            // Demographics
            DisclosureGroup(
                isExpanded: $demographicsExpanded,
                content: {
                    if !viewModel.availableDemographics.isEmpty {
                        FlowLayout(spacing: InkuSpacing.spacing8) {
                            ForEach(viewModel.availableDemographics, id: \.self) { demographic in
                                InkuBadge(
                                    text: demographic,
                                    style: viewModel.selectedDemographics.contains(demographic) ? .accent : .secondary
                                )
                                .onTapGesture {
                                    toggleDemographic(demographic)
                                }
                            }
                        }
                        .padding(.top, InkuSpacing.spacing8)
                    }
                },
                label: {
                    HStack {
                        Image(systemName: "person.3.fill")
                            .foregroundStyle(Color.inkuAccent)
                            .frame(width: 24)

                        Text(L10n.AdvancedFilters.Filter.demographics)
                            .foregroundStyle(.primary)

                        Spacer()

                        if viewModel.selectedDemographics.count > 0 {
                            Text("\(viewModel.selectedDemographics.count)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .padding(.horizontal, InkuSpacing.spacing8)
                                .padding(.vertical, InkuSpacing.spacing4)
                                .background(Color.inkuAccent)
                                .cornerRadius(InkuRadius.radius8)
                        }
                    }
                }
            )

            // Themes
            DisclosureGroup(
                isExpanded: $themesExpanded,
                content: {
                    if !viewModel.availableThemes.isEmpty {
                        FlowLayout(spacing: InkuSpacing.spacing8) {
                            ForEach(viewModel.availableThemes, id: \.self) { theme in
                                InkuBadge(
                                    text: theme,
                                    style: viewModel.selectedThemes.contains(theme) ? .accent : .secondary
                                )
                                .onTapGesture {
                                    toggleTheme(theme)
                                }
                            }
                        }
                        .padding(.top, InkuSpacing.spacing8)
                    }
                },
                label: {
                    HStack {
                        Image(systemName: "tag.fill")
                            .foregroundStyle(Color.inkuAccent)
                            .frame(width: 24)

                        Text(L10n.AdvancedFilters.Filter.themes)
                            .foregroundStyle(.primary)

                        Spacer()

                        if viewModel.selectedThemes.count > 0 {
                            Text("\(viewModel.selectedThemes.count)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .padding(.horizontal, InkuSpacing.spacing8)
                                .padding(.vertical, InkuSpacing.spacing4)
                                .background(Color.inkuAccent)
                                .cornerRadius(InkuRadius.radius8)
                        }
                    }
                }
            )

            Divider()

            Toggle(isOn: $viewModel.searchContains) {
                VStack(alignment: .leading, spacing: InkuSpacing.spacing4) {
                    Text(L10n.AdvancedFilters.Filter.searchMode)
                        .font(.subheadline)

                    Text(viewModel.searchContains ? L10n.AdvancedFilters.SearchMode.contains : L10n.AdvancedFilters.SearchMode.beginsWith)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
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
            .background(Color.inkuAccent)
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

    // MARK: - Private Functions

    private func toggleGenre(_ genre: String) {
        if viewModel.selectedGenres.contains(genre) {
            viewModel.selectedGenres.remove(genre)
        } else {
            viewModel.selectedGenres.insert(genre)
        }
    }

    private func toggleDemographic(_ demographic: String) {
        if viewModel.selectedDemographics.contains(demographic) {
            viewModel.selectedDemographics.remove(demographic)
        } else {
            viewModel.selectedDemographics.insert(demographic)
        }
    }

    private func toggleTheme(_ theme: String) {
        if viewModel.selectedThemes.contains(theme) {
            viewModel.selectedThemes.remove(theme)
        } else {
            viewModel.selectedThemes.insert(theme)
        }
    }
}

// MARK: - Supporting Components

// MARK: - Flow Layout

private struct FlowLayout: Layout {

    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            let position = CGPoint(
                x: bounds.minX + result.positions[index].x,
                y: bounds.minY + result.positions[index].y
            )
            subview.place(at: position, proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }

                positions.append(CGPoint(x: x, y: y))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }

            self.size = CGSize(width: maxWidth, height: y + lineHeight)
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

#Preview("Empty State") {
    AdvancedFilterView(interactor: MockAdvancedFiltersInteractor())
}

#Preview("With Errors") {
    AdvancedFilterView(interactor: MockAdvancedFiltersInteractorWithError())
}

