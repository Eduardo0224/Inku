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
    var searchTitle: String { get set }
    var searchAuthorFirstName: String { get set }
    var searchAuthorLastName: String { get set }
    var selectedGenres: Set<String> { get set }
    var selectedDemographics: Set<String> { get set }
    var selectedThemes: Set<String> { get set }
    var searchContains: Bool { get set }
    var sortOption: SearchSortOption { get set }

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
    var errorMessage: String? { get set }
    var hasMorePages: Bool { get }
    var hasLoadedFilterOptions: Bool { get }

    // Computed Properties
    var hasActiveFilters: Bool { get }
    var activeFilterCount: Int { get }
    var currentSearch: CustomSearch { get }

    // MARK: - Functions

    func loadFilterOptions() async
    func performSearch() async
    func loadMoreResults() async
    func clearAllFilters()
    func applySorting()
}
