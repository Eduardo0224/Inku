//
//  MangaListTests+AdvancedFilters.swift
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

extension MangaListTests {

    @Suite("Advanced Filters Integration Tests")
    @MainActor
    struct AdvancedFiltersIntegrationTests {

        // MARK: - Subject Under Test

        let sut: MangaListViewModel

        // MARK: - Spies

        let spyInteractor: SpyMangaListInteractor
        let spyAdvancedFiltersInteractor: SpyAdvancedFiltersInteractor

        // MARK: - Initializers

        init() {
            spyInteractor = SpyMangaListInteractor()
            spyAdvancedFiltersInteractor = SpyAdvancedFiltersInteractor()
            sut = MangaListViewModel(
                interactor: spyInteractor,
                advancedFiltersInteractor: spyAdvancedFiltersInteractor
            )
        }

        // MARK: - Apply Advanced Search Tests

        @Test("Apply advanced search updates selected filter with CustomSearch and SearchSortOption")
        func applyAdvancedSearchUpdatesFilter() async {
            // Given
            let search = CustomSearch(
                searchTitle: "Dragon",
                searchGenres: ["Action"],
                searchContains: true
            )
            let sortOption = SearchSortOption.titleAscending
            spyAdvancedFiltersInteractor.mangasToReturn = Self.sampleMangas

            // When
            await sut.applyAdvancedSearch(search, sortOption: sortOption)

            // Then
            if case .advanced(let appliedSearch, let appliedSortOption) = sut.selectedFilter {
                #expect(appliedSearch == search)
                #expect(appliedSortOption == sortOption)
            } else {
                Issue.record("Expected .advanced filter, got \(sut.selectedFilter)")
            }
        }

        @Test("Apply advanced search loads mangas through advanced filters interactor")
        func applyAdvancedSearchCallsInteractor() async {
            // Given
            let search = CustomSearch(searchTitle: "Test", searchContains: false)
            let sortOption = SearchSortOption.scoreDescending
            spyAdvancedFiltersInteractor.mangasToReturn = Self.sampleMangas

            // When
            await sut.applyAdvancedSearch(search, sortOption: sortOption)

            // Then
            #expect(spyAdvancedFiltersInteractor.searchMangasWasCalled == true)
            #expect(spyAdvancedFiltersInteractor.lastSearchCriteria == search)
            #expect(sut.mangas.count > 0)
        }

        @Test("Apply advanced search with sorting applies sort to results")
        func applyAdvancedSearchAppliesSorting() async {
            // Given
            let manga1 = Self.createManga(id: 1, title: "Zeta", score: 8.0)
            let manga2 = Self.createManga(id: 2, title: "Alpha", score: 9.0)
            spyAdvancedFiltersInteractor.mangasToReturn = [manga1, manga2]

            let search = CustomSearch(searchTitle: "Test", searchContains: false)
            let sortOption = SearchSortOption.titleAscending

            // When
            await sut.applyAdvancedSearch(search, sortOption: sortOption)

            // Then
            #expect(sut.mangas.first?.title == "Alpha")
            #expect(sut.mangas.last?.title == "Zeta")
        }

        @Test("Load more mangas with advanced filter maintains sorting")
        func loadMoreMangasWithAdvancedFilterMaintainsSorting() async {
            // Given
            let manga1 = Self.createManga(id: 1, title: "Beta", score: 8.0)
            let manga2 = Self.createManga(id: 2, title: "Alpha", score: 9.0)
            let manga3 = Self.createManga(id: 3, title: "Zeta", score: 7.0)

            let search = CustomSearch(searchTitle: "Test", searchContains: false)
            let sortOption = SearchSortOption.titleAscending

            spyAdvancedFiltersInteractor.mangasToReturn = [manga1, manga2]
            spyAdvancedFiltersInteractor.totalToReturn = 100
            await sut.applyAdvancedSearch(search, sortOption: sortOption)

            spyAdvancedFiltersInteractor.mangasToReturn = [manga3]
            spyAdvancedFiltersInteractor.totalToReturn = 100

            // When
            await sut.loadMoreMangas()

            // Then - should maintain alphabetical order
            #expect(sut.mangas[0].title == "Alpha")
            #expect(sut.mangas[1].title == "Beta")
            #expect(sut.mangas[2].title == "Zeta")
        }

        // MARK: - Filter State Tests

        @Test("isAdvancedFilterActive returns true when advanced filter is active")
        func isAdvancedFilterActiveTrue() async {
            // Given
            let search = CustomSearch(searchTitle: "Test", searchContains: false)
            let sortOption = SearchSortOption.scoreDescending
            spyAdvancedFiltersInteractor.mangasToReturn = Self.sampleMangas

            // When
            await sut.applyAdvancedSearch(search, sortOption: sortOption)

            // Then
            #expect(sut.isAdvancedFilterActive == true)
            #expect(sut.isFilterActive == false)  // Traditional filters should be false
        }

        @Test("isAdvancedFilterActive returns false when traditional filter is active")
        func isAdvancedFilterActiveFalse() async {
            // Given
            spyInteractor.mangasToReturn = Self.sampleMangas

            // When
            await sut.applyFilter(.genre("Action"))

            // Then
            #expect(sut.isAdvancedFilterActive == false)
            #expect(sut.isFilterActive == true)  // Traditional filters should be true
        }

        @Test("currentAdvancedSearch returns CustomSearch when advanced filter is active")
        func currentAdvancedSearchReturnsSearch() async {
            // Given
            let search = CustomSearch(
                searchTitle: "Dragon",
                searchGenres: ["Action", "Fantasy"],
                searchContains: true
            )
            spyAdvancedFiltersInteractor.mangasToReturn = Self.sampleMangas

            // When
            await sut.applyAdvancedSearch(search, sortOption: .scoreDescending)

            // Then
            #expect(sut.currentAdvancedSearch == search)
            #expect(sut.currentAdvancedSearch?.searchTitle == "Dragon")
            #expect(sut.currentAdvancedSearch?.searchGenres == ["Action", "Fantasy"])
        }

        @Test("currentSortOption returns SearchSortOption when advanced filter is active")
        func currentSortOptionReturnsSortOption() async {
            // Given
            let search = CustomSearch(searchTitle: "Test", searchContains: false)
            let sortOption = SearchSortOption.volumesDescending
            spyAdvancedFiltersInteractor.mangasToReturn = Self.sampleMangas

            // When
            await sut.applyAdvancedSearch(search, sortOption: sortOption)

            // Then
            #expect(sut.currentSortOption == .volumesDescending)
        }

        @Test("Clear filters resets advanced filter to none")
        func clearFiltersResetsAdvancedFilter() async {
            // Given
            let search = CustomSearch(searchTitle: "Test", searchContains: false)
            spyAdvancedFiltersInteractor.mangasToReturn = Self.sampleMangas
            await sut.applyAdvancedSearch(search, sortOption: .scoreDescending)

            // When
            await sut.clearFilters()

            // Then
            #expect(sut.selectedFilter == .none)
            #expect(sut.isAdvancedFilterActive == false)
            #expect(sut.currentAdvancedSearch == nil)
            #expect(sut.currentSortOption == nil)
        }

        // MARK: - Error Handling Tests

        @Test("Apply advanced search handles network error")
        func applyAdvancedSearchHandlesError() async {
            // Given
            let search = CustomSearch(searchTitle: "Test", searchContains: false)
            spyAdvancedFiltersInteractor.shouldThrowError = true
            spyAdvancedFiltersInteractor.errorToThrow = NetworkError.serverError(500)

            // When
            await sut.applyAdvancedSearch(search, sortOption: .scoreDescending)

            // Then
            #expect(sut.mangas.isEmpty)
            #expect(sut.errorMessage != nil)
            #expect(sut.isAdvancedFilterActive == true)  // Filter should remain set
        }

        // MARK: - MangaFilter Equatable Tests

        @Test("MangaFilter advanced cases are equatable")
        func mangaFilterAdvancedEquatable() {
            // Given
            let search1 = CustomSearch(searchTitle: "Test", searchContains: false)
            let search2 = CustomSearch(searchTitle: "Test", searchContains: false)
            let search3 = CustomSearch(searchTitle: "Different", searchContains: false)

            let filter1 = MangaFilter.advanced(search1, .scoreDescending)
            let filter2 = MangaFilter.advanced(search2, .scoreDescending)
            let filter3 = MangaFilter.advanced(search1, .titleAscending)
            let filter4 = MangaFilter.advanced(search3, .scoreDescending)

            // Then
            #expect(filter1 == filter2)  // Same search, same sort
            #expect(filter1 != filter3)  // Same search, different sort
            #expect(filter1 != filter4)  // Different search, same sort
        }
    }
}

// MARK: - Test Data

private extension MangaListTests.AdvancedFiltersIntegrationTests {

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
