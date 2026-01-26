//
//  AdvancedFiltersViewModel.swift
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

import Foundation
import Observation

@Observable
@MainActor
final class AdvancedFiltersViewModel {

    // MARK: - Private Properties

    @ObservationIgnored
    private let interactor: AdvancedFiltersInteractorProtocol

    @ObservationIgnored
    private var currentPage = 1

    @ObservationIgnored
    private let itemsPerPage = API.Constants.defaultPageSize

    // MARK: - Properties

    // Filter Form State
    var searchTitle: String = ""
    var searchAuthorFirstName: String = ""
    var searchAuthorLastName: String = ""
    var selectedGenres: Set<String> = []
    var selectedDemographics: Set<String> = []
    var selectedThemes: Set<String> = []
    var searchContains: Bool = true
    var sortOption: SearchSortOption = .scoreDescending

    // Filter Options (fetched from API)
    var availableGenres: [String] = []
    var availableDemographics: [String] = []
    var availableThemes: [String] = []

    // Search Results
    var searchResults: [Manga] = []
    var hasSearched: Bool = false

    // Loading States
    var isLoading = false
    var isLoadingMore = false
    var isLoadingFilters = false

    // Error Handling
    var errorMessage: String?

    // Pagination
    var hasMorePages = true

    private(set) var hasLoadedFilterOptions = false

    // MARK: - Computed Properties

    /// Returns `true` if at least one filter is active.
    var hasActiveFilters: Bool {
        !searchTitle.isEmpty ||
        !searchAuthorFirstName.isEmpty ||
        !searchAuthorLastName.isEmpty ||
        !selectedGenres.isEmpty ||
        !selectedDemographics.isEmpty ||
        !selectedThemes.isEmpty
    }

    /// Count of active filters for UI display.
    var activeFilterCount: Int {
        var count = 0
        if !searchTitle.isEmpty { count += 1 }
        if !searchAuthorFirstName.isEmpty { count += 1 }
        if !searchAuthorLastName.isEmpty { count += 1 }
        count += selectedGenres.count
        count += selectedDemographics.count
        count += selectedThemes.count
        return count
    }

    /// Current CustomSearch object based on form state.
    var currentSearch: CustomSearch {
        CustomSearch(
            searchTitle: searchTitle.isEmpty ? nil : searchTitle,
            searchAuthorFirstName: searchAuthorFirstName.isEmpty ? nil : searchAuthorFirstName,
            searchAuthorLastName: searchAuthorLastName.isEmpty ? nil : searchAuthorLastName,
            searchGenres: selectedGenres.isEmpty ? nil : Array(selectedGenres),
            searchThemes: selectedThemes.isEmpty ? nil : Array(selectedThemes),
            searchDemographics: selectedDemographics.isEmpty ? nil : Array(selectedDemographics),
            searchContains: searchContains
        )
    }

    // MARK: - Initializers

    init(interactor: AdvancedFiltersInteractorProtocol = AdvancedFiltersInteractor()) {
        self.interactor = interactor
    }

    // MARK: - Functions

    /// Loads filter options (genres, demographics, themes) from API.
    func loadFilterOptions() async {
        guard !hasLoadedFilterOptions, !isLoadingFilters else { return }

        isLoadingFilters = true
        defer { isLoadingFilters = false }

        do {
            async let genresTask = interactor.fetchGenres()
            async let demographicsTask = interactor.fetchDemographics()
            async let themesTask = interactor.fetchThemes()

            let (genres, demographics, themes) = try await (genresTask, demographicsTask, themesTask)

            availableGenres = genres.sorted()
            availableDemographics = demographics.sorted()
            availableThemes = themes.sorted()

            hasLoadedFilterOptions = true
        } catch {
            handleError(error)
        }
    }

    /// Performs search with current filter criteria.
    func performSearch() async {
        guard !isLoading else { return }
        guard hasActiveFilters else {
            errorMessage = String(
                localized: "advanced_filters.error.no_criteria",
                defaultValue: "Please select at least one filter criterion"
            )
            return
        }

        isLoading = true
        currentPage = 1
        searchResults = []
        errorMessage = nil
        defer { isLoading = false }

        do {
            let response = try await interactor.searchMangas(
                currentSearch,
                page: currentPage,
                per: itemsPerPage
            )

            // Sort results client-side
            searchResults = sortOption.sort(response.items)
            hasMorePages = response.metadata.hasMorePages
            hasSearched = true
        } catch {
            handleError(error)
        }
    }

    /// Loads next page of search results.
    func loadMoreResults() async {
        guard !isLoadingMore, !isLoading, hasMorePages, hasSearched else { return }

        isLoadingMore = true
        defer { isLoadingMore = false }

        let nextPage = currentPage + 1

        do {
            let response = try await interactor.searchMangas(
                currentSearch,
                page: nextPage,
                per: itemsPerPage
            )

            // Sort and append new results
            let sortedNewItems = sortOption.sort(response.items)
            searchResults.append(contentsOf: sortedNewItems)
            currentPage = nextPage
            hasMorePages = response.metadata.hasMorePages
        } catch {
            handleError(error)
        }
    }

    /// Clears all filter criteria and search results.
    func clearAllFilters() {
        searchTitle = ""
        searchAuthorFirstName = ""
        searchAuthorLastName = ""
        selectedGenres = []
        selectedDemographics = []
        selectedThemes = []
        searchResults = []
        hasSearched = false
        errorMessage = nil
    }

    /// Re-sorts current search results (client-side).
    func applySorting() {
        guard !searchResults.isEmpty else { return }
        searchResults = sortOption.sort(searchResults)
    }

    // MARK: - Private Functions

    private func handleError(_ error: Error) {
        if let urlError = error as? URLError {
            errorMessage = String(
                localized: "error.network.generic",
                defaultValue: "Network error. Please check your connection."
            )
        } else {
            errorMessage = String(
                localized: "error.generic",
                defaultValue: "An unexpected error occurred. Please try again."
            )
        }
    }
}
