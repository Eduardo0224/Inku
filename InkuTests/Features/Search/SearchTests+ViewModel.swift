//
//  SearchTests+ViewModel.swift
//  InkuTests
//
//  Created by Eduardo Andrade on 02/01/26.
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

extension SearchTests {

    @Suite("ViewModel Tests")
    @MainActor
    struct ViewModelTests {

        // MARK: - Subject Under Test

        let sut: SearchViewModel

        // MARK: - Spies

        let spyInteractor: SpySearchInteractor

        // MARK: - Initializers

        init() {
            spyInteractor = SpySearchInteractor()
            sut = SearchViewModel(interactor: spyInteractor)
        }

        // MARK: - Search by Title Tests

        @Test("Perform search by title successfully")
        func searchByTitleSuccess() async {
            // Given
            spyInteractor.mangasToReturn = Self.sampleMangas
            sut.searchText = "One Piece"
            sut.searchScope = .title

            // When
            await sut.performSearch()

            // Then
            #expect(sut.mangaResults == Self.sampleMangas)
            #expect(sut.errorMessage == nil)
            #expect(sut.isSearching == false)
            #expect(spyInteractor.searchMangasContainsWasCalled == true)
            #expect(spyInteractor.lastSearchedTextContains == "One Piece")
        }

        @Test("Perform search by title with empty text clears results")
        func searchByTitleEmptyText() async {
            // Given
            sut.searchText = ""

            // When
            await sut.performSearch()

            // Then
            #expect(sut.mangaResults.isEmpty)
            #expect(sut.authorResults.isEmpty)
            #expect(spyInteractor.searchMangasContainsWasCalled == false)
            #expect(spyInteractor.searchMangasBeginsWithWasCalled == false)
        }

        // MARK: - Search by Author Tests

        @Test("Perform search by author successfully")
        func searchByAuthorSuccess() async {
            // Given
            spyInteractor.authorsToReturn = Self.sampleAuthors
            sut.searchText = "Eiichiro Oda"
            sut.searchScope = .author

            // When
            await sut.performSearch()

            // Then
            #expect(sut.authorResults == Self.sampleAuthors)
            #expect(sut.errorMessage == nil)
            #expect(sut.isSearching == false)
            #expect(spyInteractor.searchAuthorsByNameWasCalled == true)
            #expect(spyInteractor.lastSearchedAuthorName == "Eiichiro Oda")
        }

        // MARK: - Search Mode Tests

        @Test("Search with beginsWith mode calls correct interactor method")
        func searchBeginsWithModeSuccess() async {
            // Given
            spyInteractor.mangasToReturn = Self.sampleMangas
            sut.searchText = "One"
            sut.searchScope = .title
            sut.mangaSearchMode = .beginsWith

            // When
            await sut.performSearch()

            // Then
            #expect(sut.mangaResults == Self.sampleMangas)
            #expect(sut.errorMessage == nil)
            #expect(sut.isSearching == false)
            #expect(spyInteractor.searchMangasBeginsWithWasCalled == true)
            #expect(spyInteractor.searchMangasContainsWasCalled == false)
            #expect(spyInteractor.lastSearchedTextBeginsWith == "One")
            #expect(sut.hasMorePages == false) // beginsWith doesn't support pagination
        }

        @Test("Search with contains mode calls correct interactor method")
        func searchContainsModeSuccess() async {
            // Given
            spyInteractor.mangasToReturn = Self.sampleMangas
            sut.searchText = "Piece"
            sut.searchScope = .title
            sut.mangaSearchMode = .contains

            // When
            await sut.performSearch()

            // Then
            #expect(sut.mangaResults == Self.sampleMangas)
            #expect(sut.errorMessage == nil)
            #expect(sut.isSearching == false)
            #expect(spyInteractor.searchMangasContainsWasCalled == true)
            #expect(spyInteractor.searchMangasBeginsWithWasCalled == false)
            #expect(spyInteractor.lastSearchedTextContains == "Piece")
        }

        @Test("Changing manga search mode triggers new search")
        func mangaSearchModeChangeTriggersSearch() async {
            // Given
            spyInteractor.mangasToReturn = Self.sampleMangas
            sut.searchText = "manga"
            sut.searchScope = .title
            sut.mangaSearchMode = .contains
            await sut.performSearch()

            spyInteractor.reset()

            // When - change mode
            sut.mangaSearchMode = .beginsWith

            // Wait for search to complete
            try? await Task.sleep(for: .milliseconds(100))

            // Then - should trigger new search
            #expect(spyInteractor.searchMangasBeginsWithWasCalled == true)
        }

        // MARK: - Sorting Tests

        @Test("Contains mode sorts first page by score descending")
        func containsModeSortsFirstPage() async {
            // Given - unsorted mangas from server
            let unsortedMangas: [Manga] = [
                Self.mangaWithScore(id: 1, score: 7.5),
                Self.mangaWithScore(id: 2, score: 9.2),
                Self.mangaWithScore(id: 3, score: 8.1)
            ]
            spyInteractor.mangasToReturn = unsortedMangas
            sut.searchText = "manga"
            sut.searchScope = .title
            sut.mangaSearchMode = .contains

            // When
            await sut.performSearch()

            // Then - should be sorted by score descending
            #expect(sut.mangaResults.count == 3)
            #expect(sut.mangaResults[0].score == 9.2) // Highest
            #expect(sut.mangaResults[1].score == 8.1)
            #expect(sut.mangaResults[2].score == 7.5) // Lowest
        }

        @Test("BeginsWith mode sorts all results by score descending")
        func beginswWithModeSortsAllResults() async {
            // Given - unsorted mangas from server
            let unsortedMangas: [Manga] = [
                Self.mangaWithScore(id: 1, score: 6.8),
                Self.mangaWithScore(id: 2, score: 9.5),
                Self.mangaWithScore(id: 3, score: 7.2),
                Self.mangaWithScore(id: 4, score: 8.9)
            ]
            spyInteractor.mangasToReturn = unsortedMangas
            sut.searchText = "One"
            sut.searchScope = .title
            sut.mangaSearchMode = .beginsWith

            // When
            await sut.performSearch()

            // Then - should be sorted by score descending
            #expect(sut.mangaResults.count == 4)
            #expect(sut.mangaResults[0].score == 9.5) // Highest
            #expect(sut.mangaResults[1].score == 8.9)
            #expect(sut.mangaResults[2].score == 7.2)
            #expect(sut.mangaResults[3].score == 6.8) // Lowest
        }

        @Test("Load more results sorts new page independently")
        func loadMoreResultsSortsPageIndependently() async {
            // Given - First page
            let firstPageMangas: [Manga] = [
                Self.mangaWithScore(id: 1, score: 7.5),
                Self.mangaWithScore(id: 2, score: 9.0),
                Self.mangaWithScore(id: 3, score: 8.2)
            ]
            spyInteractor.mangasToReturn = firstPageMangas
            spyInteractor.totalToReturn = 100
            sut.searchText = "manga"
            sut.searchScope = .title
            sut.mangaSearchMode = .contains
            await sut.performSearch()

            // Then - First page sorted
            #expect(sut.mangaResults[0].score == 9.0)
            #expect(sut.mangaResults[1].score == 8.2)
            #expect(sut.mangaResults[2].score == 7.5)

            // Given - Second page (unsorted)
            let secondPageMangas: [Manga] = [
                Self.mangaWithScore(id: 4, score: 6.8),
                Self.mangaWithScore(id: 5, score: 9.5), // Better than all in page 1
                Self.mangaWithScore(id: 6, score: 7.9)
            ]
            spyInteractor.mangasToReturn = secondPageMangas
            spyInteractor.totalToReturn = 100

            // When - Load more
            await sut.loadMoreResults()

            // Then - Pages are NOT mixed, each page sorted independently
            #expect(sut.mangaResults.count == 6)

            // Page 1 (positions 0-2) - sorted within itself
            #expect(sut.mangaResults[0].score == 9.0)
            #expect(sut.mangaResults[1].score == 8.2)
            #expect(sut.mangaResults[2].score == 7.5)

            // Page 2 (positions 3-5) - sorted within itself
            #expect(sut.mangaResults[3].score == 9.5) // Highest overall, but in position 3
            #expect(sut.mangaResults[4].score == 7.9)
            #expect(sut.mangaResults[5].score == 6.8)
        }

        // MARK: - Pagination Tests

        @Test("Load more results appends to existing results")
        func loadMoreResultsSuccess() async {
            // Given
            let initialMangas = [Self.sampleMangas[0]]
            let moreMangas = [Self.sampleMangas[1]]
            spyInteractor.mangasToReturn = initialMangas
            spyInteractor.totalToReturn = 100
            sut.searchText = "manga"
            sut.searchScope = .title
            await sut.performSearch()

            spyInteractor.mangasToReturn = moreMangas
            spyInteractor.totalToReturn = 100

            // When
            await sut.loadMoreResults()

            // Then
            #expect(sut.mangaResults.count == 2)
            #expect(sut.isLoadingMore == false)
        }

        @Test("Load more results does not work for author search")
        func loadMoreResultsAuthorScope() async {
            // Given
            spyInteractor.authorsToReturn = Self.sampleAuthors
            sut.searchText = "Oda"
            sut.searchScope = .author
            await sut.performSearch()

            spyInteractor.reset()

            // When
            await sut.loadMoreResults()

            // Then - should NOT call interactor for author search
            #expect(spyInteractor.searchMangasContainsWasCalled == false)
            #expect(spyInteractor.searchMangasBeginsWithWasCalled == false)
            #expect(spyInteractor.searchAuthorsByNameWasCalled == false)
        }

        @Test("Load more results does not work for beginsWith mode")
        func loadMoreResultsBeginsWithMode() async {
            // Given
            spyInteractor.mangasToReturn = Self.sampleMangas
            sut.searchText = "One"
            sut.searchScope = .title
            sut.mangaSearchMode = .beginsWith
            await sut.performSearch()

            spyInteractor.reset()

            // When
            await sut.loadMoreResults()

            // Then - should NOT call interactor for beginsWith mode
            #expect(spyInteractor.searchMangasContainsWasCalled == false)
            #expect(spyInteractor.searchMangasBeginsWithWasCalled == false)
        }

        // MARK: - Scope Change Tests

        @Test("Changing scope triggers new search")
        func scopeChangeTriggersSearch() async {
            // Given
            spyInteractor.mangasToReturn = Self.sampleMangas
            sut.searchText = "manga"
            sut.searchScope = .title
            await sut.performSearch()

            spyInteractor.reset()
            spyInteractor.authorsToReturn = Self.sampleAuthors

            // When - change scope
            sut.searchScope = .author

            // Wait for search to complete
            try? await Task.sleep(for: .milliseconds(100))

            // Then - should trigger new search
            #expect(spyInteractor.searchAuthorsByNameWasCalled == true)
        }

        // MARK: - Clear Search Tests

        @Test("Clear search resets all properties")
        func clearSearch() async {
            // Given
            spyInteractor.mangasToReturn = Self.sampleMangas
            sut.searchText = "manga"
            sut.mangaSearchMode = .beginsWith
            await sut.performSearch()

            // When
            sut.clearSearch()

            // Then
            #expect(sut.searchText.isEmpty)
            #expect(sut.mangaResults.isEmpty)
            #expect(sut.authorResults.isEmpty)
            #expect(sut.errorMessage == nil)
            #expect(sut.mangaSearchMode == .contains) // Should reset to .contains
        }

        @Test("Clearing search text resets manga search mode to contains")
        func clearingSearchTextResetsMangaSearchMode() async {
            // Given
            spyInteractor.mangasToReturn = Self.sampleMangas
            sut.searchText = "One"
            sut.searchScope = .title
            sut.mangaSearchMode = .beginsWith
            await sut.performSearch()

            #expect(sut.mangaSearchMode == .beginsWith)

            // When - simulate pressing X button on search bar
            sut.searchText = ""

            // Then - mode should reset to .contains for faster next search
            #expect(sut.mangaSearchMode == .contains)
        }

        // MARK: - Empty State Tests

        @Test("Shows empty state when no text and no results")
        func showsEmptyState() {
            // Given / When
            sut.searchText = ""
            sut.mangaResults = []
            sut.authorResults = []

            // Then
            #expect(sut.showsEmptyState == true)
            #expect(sut.showsNoResults == false)
        }

        @Test("Shows no results when text exists but no results")
        func showsNoResults() async {
            // Given
            spyInteractor.mangasToReturn = []
            sut.searchText = "nonexistent"

            // When
            await sut.performSearch()

            // Then
            #expect(sut.showsEmptyState == false)
            #expect(sut.showsNoResults == true)
        }

        // MARK: - Error Handling Tests

        @Test(
            "Handle different error types correctly",
            arguments: [
                .init(error: NetworkError.invalidURL, expectedContains: L10n.Error.generic),
                .init(error: NetworkError.invalidResponse, expectedContains: L10n.Error.generic),
                .init(error: URLError(.notConnectedToInternet), expectedContains: L10n.Error.network),
                .init(error: URLError(.timedOut), expectedContains: L10n.Error.timeout)
            ] as [HandleErrorArgument]
        )
        private func handleErrorTypes(argument: HandleErrorArgument) async {
            // Given
            spyInteractor.shouldThrowError = true
            spyInteractor.errorToThrow = argument.error
            sut.searchText = "manga"

            // When
            await sut.performSearch()

            // Then
            #expect(sut.errorMessage?.localizedCaseInsensitiveContains(argument.expectedContains) == true)
        }

        // MARK: - Grouped Authors Tests

        @Test("Authors are grouped by first letter of firstName")
        func authorsGroupedByFirstLetter() async {
            // Given
            spyInteractor.authorsToReturn = Self.sampleAuthorsForGrouping
            sut.searchText = "author"
            sut.searchScope = .author

            // When
            await sut.performSearch()
            let grouped = sut.groupedAuthors

            // Then
            #expect(grouped.contains(where: { $0.key == "A" }))
            #expect(grouped.contains(where: { $0.key == "E" }))
            #expect(grouped.contains(where: { $0.key == "K" }))
        }

        @Test("Authors within group are sorted by firstName then lastName")
        func authorsWithinGroupSorted() async {
            // Given
            let authors: [Author] = [
                .init(id: "1", firstName: "Akira", lastName: "Toriyama", role: "Story"),
                .init(id: "2", firstName: "Akira", lastName: "Kareno", role: "Art"),
                .init(id: "3", firstName: "Akiko", lastName: "Higashimura", role: "Story")
            ]
            spyInteractor.authorsToReturn = authors
            sut.searchText = "Aki"
            sut.searchScope = .author

            // When
            await sut.performSearch()
            let groupA = sut.groupedAuthors.first(where: { $0.key == "A" })?.value

            // Then
            #expect(groupA?.count == 3)
            #expect(groupA?[0].lastName == "Higashimura") // Akiko < Akira
            #expect(groupA?[1].lastName == "Kareno")       // Akira Kareno < Akira Toriyama
            #expect(groupA?[2].lastName == "Toriyama")
        }

        @Test("Section order is A-Z, then 0-9, then #")
        func sectionOrderCorrect() async {
            // Given
            let authors: [Author] = [
                .init(id: "1", firstName: "#Special", lastName: "Author", role: "Art"),
                .init(id: "2", firstName: "Alice", lastName: "Brown", role: "Story"),
                .init(id: "3", firstName: "5th", lastName: "Dimension", role: "Art"),
                .init(id: "4", firstName: "Zelda", lastName: "Fitzgerald", role: "Story")
            ]
            spyInteractor.authorsToReturn = authors
            sut.searchText = "author"
            sut.searchScope = .author

            // When
            await sut.performSearch()
            let grouped = sut.groupedAuthors

            // Then - Order should be A, Z, 0-9, #
            let keys = grouped.map { $0.key }
            let aIndex = keys.firstIndex(of: "A")
            let zIndex = keys.firstIndex(of: "Z")
            let numbersIndex = keys.firstIndex(of: "0-9")
            let specialIndex = keys.firstIndex(of: "#")

            #expect(aIndex != nil && zIndex != nil && numbersIndex != nil && specialIndex != nil)
            #expect(aIndex! < zIndex!)
            #expect(zIndex! < numbersIndex!)
            #expect(numbersIndex! < specialIndex!)
        }

        @Test("Authors with empty firstName use lastName for grouping")
        func emptyFirstNameUsesLastName() async {
            // Given
            let authors: [Author] = [
                .init(id: "1", firstName: "Akira", lastName: "Toriyama", role: "Story"),
                .init(id: "2", firstName: "", lastName: "Alice", role: "Art"),
                .init(id: "3", firstName: "", lastName: "Bob", role: "Story")
            ]
            spyInteractor.authorsToReturn = authors
            sut.searchText = "author"
            sut.searchScope = .author

            // When
            await sut.performSearch()
            let grouped = sut.groupedAuthors

            // Then
            let groupA = grouped.first(where: { $0.key == "A" })?.value
            let groupB = grouped.first(where: { $0.key == "B" })?.value

            #expect(groupA?.count == 2) // Akira + Alice (empty firstName)
            #expect(groupB?.count == 1) // Bob (empty firstName)
            #expect(groupA?.contains(where: { $0.lastName == "Alice" }) == true)
        }

        @Test(
            "Special characters and numbers are grouped correctly",
            arguments: [
                .init(firstName: "@Author", expectedGroup: "#"),
                .init(firstName: "\"Quoted\"", expectedGroup: "#"),
                .init(firstName: "5th", expectedGroup: "0-9"),
                .init(firstName: "3D", expectedGroup: "0-9"),
                .init(firstName: "Alice", expectedGroup: "A"),
                .init(firstName: "alice", expectedGroup: "A") // Case insensitive
            ] as [GroupingArgument]
        )
        private func specialCharactersGrouping(argument: GroupingArgument) async {
            // Given
            let author = Author(
                id: "1",
                firstName: argument.firstName,
                lastName: "Test",
                role: "Story"
            )
            spyInteractor.authorsToReturn = [author]
            sut.searchText = "test"
            sut.searchScope = .author

            // When
            await sut.performSearch()
            let grouped = sut.groupedAuthors

            // Then
            #expect(grouped.contains(where: { $0.key == argument.expectedGroup }))
            let group = grouped.first(where: { $0.key == argument.expectedGroup })
            #expect(group?.value.contains(where: { $0.id == "1" }) == true)
        }

        @Test("Empty author results returns empty groupedAuthors")
        func emptyAuthorsReturnsEmptyGroups() async {
            // Given
            spyInteractor.authorsToReturn = []
            sut.searchText = "nonexistent"
            sut.searchScope = .author

            // When
            await sut.performSearch()

            // Then
            #expect(sut.groupedAuthors.isEmpty)
        }
    }
}

// MARK: - Test Data

private extension SearchTests.ViewModelTests {

    static let sampleMangas: [Manga] = [
        .init(
            id: 1,
            title: "One Piece",
            titleEnglish: "One Piece",
            titleJapanese: nil,
            sypnosis: "A story about pirates",
            background: nil,
            mainPicture: nil,
            url: nil,
            volumes: nil,
            chapters: nil,
            status: "Publishing",
            score: 9.21,
            startDate: nil,
            endDate: nil,
            authors: [],
            genres: [.init(id: "1", genre: "Action")],
            demographics: [.init(id: "1", demographic: "Shounen")],
            themes: [.init(id: "1", theme: "Pirate")]
        ),
        .init(
            id: 2,
            title: "Naruto",
            titleEnglish: "Naruto",
            titleJapanese: nil,
            sypnosis: "A ninja's journey",
            background: nil,
            mainPicture: nil,
            url: nil,
            volumes: nil,
            chapters: nil,
            status: "Finished",
            score: 8.12,
            startDate: nil,
            endDate: nil,
            authors: [],
            genres: [.init(id: "1", genre: "Action")],
            demographics: [.init(id: "1", demographic: "Shounen")],
            themes: [.init(id: "2", theme: "Ninja")]
        )
    ]

    static let sampleAuthors: [Author] = [
        .init(
            id: "1",
            firstName: "Eiichiro",
            lastName: "Oda",
            role: "Story & Art"
        ),
        .init(
            id: "2",
            firstName: "Kentaro",
            lastName: "Miura",
            role: "Story & Art"
        )
    ]

    static let sampleAuthorsForGrouping: [Author] = [
        .init(id: "1", firstName: "Akira", lastName: "Toriyama", role: "Story"),
        .init(id: "2", firstName: "Eiichiro", lastName: "Oda", role: "Story & Art"),
        .init(id: "3", firstName: "Kentaro", lastName: "Miura", role: "Story & Art"),
        .init(id: "4", firstName: "Akiko", lastName: "Higashimura", role: "Story")
    ]

    static func mangaWithScore(id: Int, score: Double) -> Manga {
        .init(
            id: id,
            title: "Test Manga \(id)",
            titleEnglish: "Test Manga \(id)",
            titleJapanese: nil,
            sypnosis: "Test synopsis",
            background: nil,
            mainPicture: nil,
            url: nil,
            volumes: nil,
            chapters: nil,
            status: "Publishing",
            score: score,
            startDate: nil,
            endDate: nil,
            authors: [],
            genres: [],
            demographics: [],
            themes: []
        )
    }
}

// MARK: - Arguments

private extension SearchTests.ViewModelTests {

    struct HandleErrorArgument: CustomTestStringConvertible {
        let error: Error
        let expectedContains: String

        var testDescription: String {
            "\(String(describing: error)) → expects '\(expectedContains)'"
        }

        init(error: Error, expectedContains: String) {
            self.error = error
            self.expectedContains = expectedContains
        }
    }

    struct GroupingArgument: CustomTestStringConvertible {
        let firstName: String
        let expectedGroup: String

        var testDescription: String {
            "'\(firstName)' → group '\(expectedGroup)'"
        }

        init(firstName: String, expectedGroup: String) {
            self.firstName = firstName
            self.expectedGroup = expectedGroup
        }
    }
}
