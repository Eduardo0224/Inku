//
//  MockAdvancedFiltersViewModel.swift
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
extension AdvancedFiltersViewModel {

    /// Mock ViewModel with pre-loaded filter options for previews.
    static let mockWithFilters: AdvancedFiltersViewModel = {
        let vm = AdvancedFiltersViewModel(interactor: MockAdvancedFiltersInteractor())
        vm.availableGenres = [
            "Action", "Adventure", "Comedy", "Drama", "Fantasy",
            "Horror", "Mystery", "Romance", "Sci-Fi", "Sports"
        ]
        vm.availableDemographics = ["Shounen", "Shoujo", "Seinen", "Kids", "Josei"]
        vm.availableThemes = [
            "School", "Mecha", "Vampires", "Music", "Martial Arts",
            "Super Power", "Historical", "Military", "Psychological", "Slice of Life"
        ]
        vm.hasLoadedFilterOptions = true
        return vm
    }()

    /// Mock ViewModel with active search.
    static let mockWithSearch: AdvancedFiltersViewModel = {
        let vm = AdvancedFiltersViewModel(interactor: MockAdvancedFiltersInteractor())
        vm.searchTitle = "dragon"
        vm.selectedGenres = ["Action", "Adventure"]
        vm.selectedDemographics = ["Shounen"]
        vm.searchContains = true
        vm.searchResults = [.testData, .testData, .testData]
        vm.hasSearched = true
        vm.availableGenres = ["Action", "Adventure", "Comedy", "Drama", "Fantasy"]
        vm.availableDemographics = ["Shounen", "Shoujo", "Seinen"]
        vm.availableThemes = ["School", "Mecha", "Vampires"]
        vm.hasLoadedFilterOptions = true
        return vm
    }()

    /// Mock ViewModel with loading state.
    static let mockLoading: AdvancedFiltersViewModel = {
        let vm = AdvancedFiltersViewModel(interactor: MockAdvancedFiltersInteractor())
        vm.isLoading = true
        vm.searchTitle = "one piece"
        return vm
    }()

    /// Mock ViewModel with error state.
    static let mockWithError: AdvancedFiltersViewModel = {
        let vm = AdvancedFiltersViewModel(interactor: MockAdvancedFiltersInteractorWithError())
        vm.errorMessage = "Network error. Please check your connection."
        vm.hasSearched = true
        return vm
    }()

    /// Empty mock ViewModel.
    static let mockEmpty: AdvancedFiltersViewModel = {
        AdvancedFiltersViewModel(interactor: MockAdvancedFiltersInteractor())
    }()
}
