//
//  AdvancedFiltersViewModelProtocol.swift
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

@MainActor
protocol AdvancedFiltersViewModelProtocol: Observable {

    // MARK: - Properties

    // Filter Form State
    var searchTitle: String { get }
    var searchAuthorFirstName: String { get }
    var searchAuthorLastName: String { get }
    var selectedGenres: Set<String> { get }
    var selectedDemographics: Set<String> { get }
    var selectedThemes: Set<String> { get }
    var searchContains: Bool { get }
    var sortOption: SearchSortOption { get }

    // Filter Options
    var availableGenres: [String] { get }
    var availableDemographics: [String] { get }
    var availableThemes: [String] { get }

    // Search Results
    var searchResults: [Manga] { get }
    var hasSearched: Bool { get }

    // Loading States
    var isLoading: Bool { get }
    var isLoadingMore: Bool { get }
    var isLoadingFilters: Bool { get }
    var errorMessage: String? { get }
    var hasMorePages: Bool { get }
    var hasLoadedFilterOptions: Bool { get }
    var hasPreloadedData: Bool { get }

    // Computed Properties
    var hasActiveFilters: Bool { get }
    var activeFilterCount: Int { get }
    var hasFilterCategories: Bool { get }
    var currentSearch: CustomSearch { get }

    // MARK: - Functions

    func loadFilterOptions() async
    func performSearch() async
    func loadMoreResults() async
    func clearAllFilters()
    func applySorting()
}
