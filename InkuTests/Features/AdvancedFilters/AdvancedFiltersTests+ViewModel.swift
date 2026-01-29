//
//  AdvancedFiltersTests+ViewModel.swift
//  InkuTests
//
//  Created by Eduardo Andrade on 28/01/26.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2026 Eduardo Andrade. All rights reserved.
//

import Foundation
import Testing
@testable import Inku

extension AdvancedFiltersTests {

    @Suite("ViewModel Tests")
    @MainActor
    struct ViewModelTests {

        // MARK: - Subject Under Test

        let sut: AdvancedFiltersViewModel

        // MARK: - Spies

        let spyInteractor: SpyAdvancedFiltersInteractor

        // MARK: - Initializers

        init() {
            spyInteractor = SpyAdvancedFiltersInteractor()
            sut = AdvancedFiltersViewModel(interactor: spyInteractor)
        }

        // MARK: - Load Filter Options Tests

        @Test("Load filter options successfully loads all data")
        func loadFilterOptionsSuccess() async {
            // Given
            spyInteractor.genresToReturn = Self.sampleGenres
            spyInteractor.demographicsToReturn = Self.sampleDemographics
            spyInteractor.themesToReturn = Self.sampleThemes

            // When
            await sut.loadFilterOptions()

            // Then
            #expect(sut.availableGenres.sorted() == Self.sampleGenres.sorted())
            #expect(sut.availableDemographics.sorted() == Self.sampleDemographics.sorted())
            #expect(sut.availableThemes.sorted() == Self.sampleThemes.sorted())
            #expect(sut.hasLoadedFilterOptions == true)
            #expect(spyInteractor.fetchGenresWasCalled == true)
            #expect(spyInteractor.fetchDemographicsWasCalled == true)
            #expect(spyInteractor.fetchThemesWasCalled == true)
        }

        @Test("Load filter options skips loading when already loaded")
        func loadFilterOptionsAlreadyLoaded() async {
            // Given
            spyInteractor.genresToReturn = Self.sampleGenres
            spyInteractor.demographicsToReturn = Self.sampleDemographics
            spyInteractor.themesToReturn = Self.sampleThemes
            await sut.loadFilterOptions()

            // Reset spy flags
            spyInteractor.reset()

            // When - second call
            await sut.loadFilterOptions()

            // Then - should NOT call interactor again
            #expect(sut.hasLoadedFilterOptions == true)
            #expect(spyInteractor.fetchGenresWasCalled == false)
            #expect(spyInteractor.fetchDemographicsWasCalled == false)
            #expect(spyInteractor.fetchThemesWasCalled == false)
        }

        @Test("Load filter options with preloaded data skips API call")
        func loadFilterOptionsWithPreloadedData() async {
            // Given
            let sutWithPreload = AdvancedFiltersViewModel(
                interactor: spyInteractor,
                preloadedGenres: Self.sampleGenres,
                preloadedDemographics: Self.sampleDemographics,
                preloadedThemes: Self.sampleThemes
            )

            // When
            await sutWithPreload.loadFilterOptions()

            // Then - should NOT call interactor
            #expect(sutWithPreload.hasLoadedFilterOptions == true)
            #expect(sutWithPreload.hasPreloadedData == true)
            #expect(spyInteractor.fetchGenresWasCalled == false)
            #expect(spyInteractor.fetchDemographicsWasCalled == false)
            #expect(spyInteractor.fetchThemesWasCalled == false)
        }

        @Test("Load filter options handles error")
        func loadFilterOptionsError() async {
            // Given
            spyInteractor.shouldThrowError = true
            spyInteractor.errorToThrow = NetworkError.serverError(500)

            // When
            await sut.loadFilterOptions()

            // Then
            #expect(sut.availableGenres.isEmpty)
            #expect(sut.availableDemographics.isEmpty)
            #expect(sut.availableThemes.isEmpty)
            #expect(sut.errorMessage != nil)
        }

        // MARK: - Perform Search Tests

        @Test("Perform search successfully with active filters")
        func performSearchSuccess() async {
            // Given
            sut.searchTitle = "Dragon"
            sut.selectedGenres = ["Action"]
            spyInteractor.mangasToReturn = Self.sampleMangas

            // When
            await sut.performSearch()

            // Then
            #expect(sut.searchResults == Self.sampleMangas)
            #expect(sut.hasSearched == true)
            #expect(sut.errorMessage == nil)
            #expect(spyInteractor.searchMangasWasCalled == true)
            #expect(spyInteractor.lastSearchCriteria?.searchTitle == "Dragon")
            #expect(spyInteractor.lastSearchCriteria?.searchGenres == ["Action"])
        }

        @Test("Perform search returns error when no active filters")
        func performSearchNoFilters() async {
            // Given - no filters set
            #expect(sut.hasActiveFilters == false)

            // When
            await sut.performSearch()

            // Then
            #expect(sut.errorMessage == L10n.AdvancedFilters.Error.noCriteria)
            #expect(spyInteractor.searchMangasWasCalled == false)
        }

        @Test("Perform search handles network error")
        func performSearchNetworkError() async {
            // Given
            sut.searchTitle = "Test"
            spyInteractor.shouldThrowError = true
            spyInteractor.errorToThrow = NetworkError.serverError(500)

            // When
            await sut.performSearch()

            // Then
            #expect(sut.searchResults.isEmpty)
            #expect(sut.errorMessage != nil)
            #expect(spyInteractor.searchMangasWasCalled == true)
        }

        @Test("Perform search applies sorting to results")
        func performSearchWithSorting() async {
            // Given
            let manga1 = Self.createManga(id: 1, title: "Zeta", score: 8.0)
            let manga2 = Self.createManga(id: 2, title: "Alpha", score: 9.0)
            spyInteractor.mangasToReturn = [manga1, manga2]
            sut.searchTitle = "Test"
            sut.sortOption = .titleAscending

            // When
            await sut.performSearch()

            // Then
            #expect(sut.searchResults.first?.title == "Alpha")
            #expect(sut.searchResults.last?.title == "Zeta")
        }

        // MARK: - Load More Results Tests

        @Test("Load more results appends to existing results")
        func loadMoreResultsSuccess() async {
            // Given
            let initialMangas = [Self.sampleMangas[0]]
            let moreMangas = [Self.sampleMangas[1]]
            sut.searchTitle = "Test"

            spyInteractor.mangasToReturn = initialMangas
            spyInteractor.totalToReturn = 100
            await sut.performSearch()

            spyInteractor.mangasToReturn = moreMangas
            spyInteractor.totalToReturn = 100

            // When
            await sut.loadMoreResults()

            // Then
            #expect(sut.searchResults.count == 2)
            #expect(sut.isLoadingMore == false)
        }

        @Test("Load more results does not execute when no search performed")
        func loadMoreResultsNoSearch() async {
            // Given - no search performed
            #expect(sut.hasSearched == false)

            // When
            await sut.loadMoreResults()

            // Then
            #expect(spyInteractor.searchMangasWasCalled == false)
        }

        @Test("Load more results maintains sorting")
        func loadMoreResultsWithSorting() async {
            // Given
            let manga1 = Self.createManga(id: 1, title: "Beta", score: 8.0)
            let manga2 = Self.createManga(id: 2, title: "Alpha", score: 9.0)
            let manga3 = Self.createManga(id: 3, title: "Zeta", score: 7.0)

            sut.searchTitle = "Test"
            sut.sortOption = .titleAscending

            spyInteractor.mangasToReturn = [manga1, manga2]
            spyInteractor.totalToReturn = 100
            await sut.performSearch()

            spyInteractor.mangasToReturn = [manga3]
            spyInteractor.totalToReturn = 100

            // When
            await sut.loadMoreResults()

            // Then - should maintain alphabetical order
            #expect(sut.searchResults[0].title == "Alpha")
            #expect(sut.searchResults[1].title == "Beta")
            #expect(sut.searchResults[2].title == "Zeta")
        }

        // MARK: - Clear All Filters Tests

        @Test("Clear all filters resets all form fields")
        func clearAllFilters() {
            // Given
            sut.searchTitle = "Test"
            sut.searchAuthorFirstName = "John"
            sut.searchAuthorLastName = "Doe"
            sut.selectedGenres = ["Action"]
            sut.selectedDemographics = ["Shounen"]
            sut.selectedThemes = ["School"]
            sut.searchResults = Self.sampleMangas
            sut.hasSearched = true

            // When
            sut.clearAllFilters()

            // Then
            #expect(sut.searchTitle.isEmpty)
            #expect(sut.searchAuthorFirstName.isEmpty)
            #expect(sut.searchAuthorLastName.isEmpty)
            #expect(sut.selectedGenres.isEmpty)
            #expect(sut.selectedDemographics.isEmpty)
            #expect(sut.selectedThemes.isEmpty)
            #expect(sut.searchResults.isEmpty)
            #expect(sut.hasSearched == false)
            #expect(sut.errorMessage == nil)
        }

        // MARK: - Computed Properties Tests

        @Test(
            "hasActiveFilters returns correct value",
            arguments: [
                .init(title: "Test", expected: true),
                .init(firstName: "John", expected: true),
                .init(lastName: "Doe", expected: true),
                .init(genres: ["Action"], expected: true),
                .init(demographics: ["Shounen"], expected: true),
                .init(themes: ["School"], expected: true),
                .init(expected: false)
            ] as [HasActiveFiltersArgument]
        )
        private func hasActiveFilters(argument: HasActiveFiltersArgument) {
            // Given
            sut.searchTitle = argument.title
            sut.searchAuthorFirstName = argument.firstName
            sut.searchAuthorLastName = argument.lastName
            sut.selectedGenres = Set(argument.genres)
            sut.selectedDemographics = Set(argument.demographics)
            sut.selectedThemes = Set(argument.themes)

            // Then
            #expect(sut.hasActiveFilters == argument.expected)
        }

        @Test("activeFilterCount calculates correctly")
        func activeFilterCount() {
            // Given
            sut.searchTitle = "Test"
            sut.selectedGenres = ["Action", "Adventure"]
            sut.selectedDemographics = ["Shounen"]

            // When
            let count = sut.activeFilterCount

            // Then - 1 title + 2 genres + 1 demographic = 4
            #expect(count == 4)
        }

        @Test("hasFilterCategories returns correct value")
        func hasFilterCategories() {
            // Given - empty categories
            #expect(sut.hasFilterCategories == false)

            // When - add genres
            sut.availableGenres = Self.sampleGenres

            // Then
            #expect(sut.hasFilterCategories == true)
        }

        @Test("currentSearch builds CustomSearch correctly")
        func currentSearchBuildsCorrectly() {
            // Given
            sut.searchTitle = "Dragon"
            sut.searchAuthorFirstName = "John"
            sut.selectedGenres = ["Action", "Fantasy"]
            sut.searchContains = true

            // When
            let search = sut.currentSearch

            // Then
            #expect(search.searchTitle == "Dragon")
            #expect(search.searchAuthorFirstName == "John")
            #expect(search.searchAuthorLastName == nil)
            #expect(search.searchGenres?.sorted() == ["Action", "Fantasy"].sorted())
            #expect(search.searchContains == true)
        }

        // MARK: - Preselected Values Tests

        @Test("Init with preselected search restores all values")
        func initWithPreselectedSearch() {
            // Given
            let preselectedSearch = CustomSearch(
                searchTitle: "Dragon",
                searchAuthorFirstName: "John",
                searchAuthorLastName: "Doe",
                searchGenres: ["Action", "Fantasy"],
                searchThemes: ["School"],
                searchDemographics: ["Shounen"],
                searchContains: true
            )

            // When
            let sutWithPreselect = AdvancedFiltersViewModel(
                interactor: spyInteractor,
                preselectedSearch: preselectedSearch
            )

            // Then
            #expect(sutWithPreselect.searchTitle == "Dragon")
            #expect(sutWithPreselect.searchAuthorFirstName == "John")
            #expect(sutWithPreselect.searchAuthorLastName == "Doe")
            #expect(sutWithPreselect.selectedGenres == ["Action", "Fantasy"])
            #expect(sutWithPreselect.selectedThemes == ["School"])
            #expect(sutWithPreselect.selectedDemographics == ["Shounen"])
            #expect(sutWithPreselect.searchContains == true)
        }

        @Test("Init with preselected sort option restores value")
        func initWithPreselectedSortOption() {
            // Given
            let preselectedSortOption = SearchSortOption.volumesDescending

            // When
            let sutWithPreselect = AdvancedFiltersViewModel(
                interactor: spyInteractor,
                preselectedSortOption: preselectedSortOption
            )

            // Then
            #expect(sutWithPreselect.sortOption == .volumesDescending)
        }

        @Test("Apply sorting updates results in correct order")
        func applySorting() {
            // Given
            let manga1 = Self.createManga(id: 1, title: "Zeta", score: 8.0)
            let manga2 = Self.createManga(id: 2, title: "Alpha", score: 9.0)
            sut.searchResults = [manga1, manga2]
            sut.sortOption = .titleAscending

            // When
            sut.applySorting()

            // Then
            #expect(sut.searchResults.first?.title == "Alpha")
            #expect(sut.searchResults.last?.title == "Zeta")
        }
    }
}

// MARK: - Test Data

private extension AdvancedFiltersTests.ViewModelTests {

    static let sampleGenres: [String] = ["Action", "Adventure", "Drama"]

    static let sampleDemographics: [String] = ["Shounen", "Seinen"]

    static let sampleThemes: [String] = ["School", "Military"]

    static let sampleMangas: [Manga] = [
        createManga(id: 1, title: "One Piece", score: 9.21),
        createManga(id: 2, title: "Attack on Titan", score: 8.54)
    ]

    static func createManga(id: Int, title: String, score: Double?) -> Manga {
        .init(
            id: id,
            title: title,
            titleEnglish: title,
            titleJapanese: nil,
            sypnosis: "Test synopsis",
            background: nil,
            mainPicture: nil,
            url: nil,
            volumes: 100,
            chapters: nil,
            status: "Publishing",
            score: score,
            startDate: nil,
            endDate: nil,
            authors: [],
            genres: [.init(id: "1", genre: "Action")],
            demographics: [.init(id: "1", demographic: "Shounen")],
            themes: [.init(id: "1", theme: "Adventure")]
        )
    }
}

// MARK: - Arguments

private extension AdvancedFiltersTests.ViewModelTests {

    struct HasActiveFiltersArgument: CustomTestStringConvertible {
        let title: String
        let firstName: String
        let lastName: String
        let genres: [String]
        let demographics: [String]
        let themes: [String]
        let expected: Bool

        var testDescription: String {
            var components: [String] = []

            if !title.isEmpty {
                components.append("title: \"\(title)\"")
            }
            if !firstName.isEmpty {
                components.append("firstName: \"\(firstName)\"")
            }
            if !lastName.isEmpty {
                components.append("lastName: \"\(lastName)\"")
            }
            if !genres.isEmpty {
                components.append("genres: \(genres)")
            }
            if !demographics.isEmpty {
                components.append("demographics: \(demographics)")
            }
            if !themes.isEmpty {
                components.append("themes: \(themes)")
            }

            let filters = components.isEmpty ? "no filters" : components.joined(separator: ", ")
            return "\(filters) → expects \(expected)"
        }

        init(
            title: String = "",
            firstName: String = "",
            lastName: String = "",
            genres: [String] = [],
            demographics: [String] = [],
            themes: [String] = [],
            expected: Bool
        ) {
            self.title = title
            self.firstName = firstName
            self.lastName = lastName
            self.genres = genres
            self.demographics = demographics
            self.themes = themes
            self.expected = expected
        }
    }
}
