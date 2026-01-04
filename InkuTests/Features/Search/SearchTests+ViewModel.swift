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
            #expect(spyInteractor.searchMangasByTitleWasCalled == true)
            #expect(spyInteractor.lastSearchedText == "One Piece")
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
            #expect(spyInteractor.searchMangasByTitleWasCalled == false)
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
            #expect(spyInteractor.searchMangasByTitleWasCalled == false)
            #expect(spyInteractor.searchAuthorsByNameWasCalled == false)
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
            await sut.performSearch()

            // When
            sut.clearSearch()

            // Then
            #expect(sut.searchText.isEmpty)
            #expect(sut.mangaResults.isEmpty)
            #expect(sut.authorResults.isEmpty)
            #expect(sut.errorMessage == nil)
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
}
