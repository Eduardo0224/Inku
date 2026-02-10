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

    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss

    // MARK: - States

    @State private var viewModel: AdvancedFiltersViewModel
    @State private var genresExpanded = false
    @State private var demographicsExpanded = false
    @State private var themesExpanded = false

    // MARK: - Properties

    let onSearch: ((CustomSearch, SearchSortOption) -> Void)?

    // MARK: - Initializers

    init(
        interactor: AdvancedFiltersInteractorProtocol = AdvancedFiltersInteractor(),
        preloadedGenres: [String] = [],
        preloadedDemographics: [String] = [],
        preloadedThemes: [String] = [],
        preselectedSearch: CustomSearch? = nil,
        preselectedSortOption: SearchSortOption? = nil,
        onSearch: ((CustomSearch, SearchSortOption) -> Void)? = nil
    ) {
        self.onSearch = onSearch
        self.viewModel = AdvancedFiltersViewModel(
            interactor: interactor,
            preloadedGenres: preloadedGenres,
            preloadedDemographics: preloadedDemographics,
            preloadedThemes: preloadedThemes,
            preselectedSearch: preselectedSearch,
            preselectedSortOption: preselectedSortOption
        )

        self._genresExpanded = State(initialValue: preselectedSearch?.hasSelectedGenres ?? false)
        self._demographicsExpanded = State(initialValue: preselectedSearch?.hasSelectedDemographics ?? false)
        self._themesExpanded = State(initialValue: preselectedSearch?.hasSelectedThemes ?? false)
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: InkuSpacing.spacing20) {
                    filterFormSection
                    searchButton
                }
                .padding(InkuSpacing.spacing16)
            }
            .navigationTitle(L10n.AdvancedFilters.Screen.title)
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if onSearch != nil {
                        Button(L10n.Common.cancel) {
                            dismiss()
                        }
                    }
                }

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
                if !viewModel.hasPreloadedData {
                    await viewModel.loadFilterOptions()
                }
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
            sortingSection
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
            #if os(visionOS)
            .pickerStyle(.palette)
            #else
            .pickerStyle(.segmented)
            #endif
            .tint(Color.inkuAccentStrong)
        }
        .padding(InkuSpacing.spacing16)
        .inkuCard()
    }

    private var sortingSection: some View {
        VStack(alignment: .leading, spacing: InkuSpacing.spacing12) {
            Text(L10n.AdvancedFilters.Sort.title)
                .font(.inkuSubheadline)
                .foregroundStyle(Color.inkuTextSecondary)

            Menu {
                ForEach(SearchSortOption.allCases) { option in
                    Button {
                        viewModel.sortOption = option
                    } label: {
                        Label(
                            option.displayName,
                            systemImage: viewModel.sortOption == option
                                ? "checkmark.circle.fill"
                                : option.iconName
                        )
                    }
                }
            } label: {
                HStack {
                    Image(systemName: viewModel.sortOption.iconName)
                        .foregroundStyle(Color.inkuAccentStrong)

                    Text(viewModel.sortOption.displayName)
                        .foregroundStyle(Color.inkuText)

                    Spacer()

                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption)
                        .foregroundStyle(Color.inkuAccentSoft)
                }
                .padding(InkuSpacing.spacing12)
                #if !os(visionOS)
                .background(Color.inkuSurface)
                #endif
                .cornerRadius(InkuRadius.radius8)
                #if !os(visionOS)
                .overlay(
                    RoundedRectangle(cornerRadius: InkuRadius.radius8)
                        .stroke(Color.inkuAccent, lineWidth: 1)
                )
                #endif
            }
        }
        .padding(InkuSpacing.spacing16)
        .inkuCard()
    }

    private var searchButton: some View {
        InkuButton(
            L10n.AdvancedFilters.Button.search,
            icon: "magnifyingglass",
            style: .primary,
            isFullWidth: true,
            isLoading: viewModel.isLoading,
            isDisabled: !viewModel.hasActiveFilters,
            badge: viewModel.activeFilterCount > 0 ? "\(viewModel.activeFilterCount)" : nil,
            backgroundColor: Color.inkuAccentStrong,
            cornerRadius: InkuRadius.radius12
        ) {
            if let onSearch {
                onSearch(viewModel.currentSearch, viewModel.sortOption)
                dismiss()
            } else {
                Task {
                    await viewModel.performSearch()
                }
            }
        }
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

#Preview("With Preselected Values") {
    let preselectedSearch = CustomSearch(
        searchTitle: "Dragon",
        searchGenres: ["Action", "Fantasy"],
        searchDemographics: ["Shounen"],
        searchContains: true
    )

    AdvancedFilterView(
        interactor: MockAdvancedFiltersInteractor(),
        preselectedSearch: preselectedSearch,
        preselectedSortOption: .volumesDescending
    )
}
