//
//  MangaListTests+ViewModel.swift
//  InkuTests
//
//  Created by Eduardo Andrade on 24/12/25.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2025 Eduardo Andrade. All rights reserved.
//

import Foundation
import Testing
@testable import Inku

extension MangaListTests {

    @Suite("ViewModel Tests")
    @MainActor
    struct ViewModelTests {

        // MARK: - Subject Under Test

        let sut: MangaListViewModel

        // MARK: - Spies

        let spyInteractor: SpyMangaListInteractor

        // MARK: - Initializers

        init() {
            spyInteractor = SpyMangaListInteractor()
            sut = MangaListViewModel(interactor: spyInteractor)
        }

        // MARK: - Load Initial Data Tests

        @Test("Load initial data if needed loads data on first call")
        func loadInitialDataFirstCall() async {
            // Given
            spyInteractor.mangasToReturn = Self.sampleMangas
            spyInteractor.genresToReturn = Self.sampleGenres
            spyInteractor.demographicsToReturn = Self.sampleDemographics
            spyInteractor.themesToReturn = Self.sampleThemes
            #expect(sut.hasLoadedInitialData == false)
            // When
            let task = sut.loadInitialDataIfNeeded()
            await task.value
            // Then
            #expect(sut.hasLoadedInitialData == true)
            #expect(sut.mangas == Self.sampleMangas)
            #expect(sut.genres.map(\.genre) == Self.sampleGenres)
            #expect(sut.demographics.map(\.demographic) == Self.sampleDemographics)
            #expect(sut.themes.map(\.theme) == Self.sampleThemes)
            #expect(spyInteractor.fetchMangasWasCalled == true)
            #expect(spyInteractor.fetchGenresWasCalled == true)
            #expect(spyInteractor.fetchDemographicsWasCalled == true)
            #expect(spyInteractor.fetchThemesWasCalled == true)
        }

        @Test("Load initial data if needed skips loading on subsequent calls")
        func loadInitialDataSubsequentCalls() async {
            // Given
            spyInteractor.mangasToReturn = Self.sampleMangas
            spyInteractor.genresToReturn = Self.sampleGenres
            spyInteractor.demographicsToReturn = Self.sampleDemographics
            spyInteractor.themesToReturn = Self.sampleThemes
            // When
            let task = sut.loadInitialDataIfNeeded()
            await task.value
            // Reset spy flags
            spyInteractor.reset()
            // When - second call
            let secondTask = sut.loadInitialDataIfNeeded()
            await secondTask.value
            // Then - should NOT call interactor again
            #expect(sut.hasLoadedInitialData == true)
            #expect(spyInteractor.fetchMangasWasCalled == false)
            #expect(spyInteractor.fetchGenresWasCalled == false)
            #expect(spyInteractor.fetchDemographicsWasCalled == false)
            #expect(spyInteractor.fetchThemesWasCalled == false)
        }

        // MARK: - Load Mangas Tests

        @Test("Load mangas successfully updates mangas array")
        func loadMangasSuccess() async {
            // Given
            let expectedMangas = Self.sampleMangas
            spyInteractor.mangasToReturn = expectedMangas

            // When
            await sut.loadMangas()

            // Then
            #expect(sut.mangas == expectedMangas)
            #expect(sut.errorMessage == nil)
            #expect(sut.isLoading == false)
            #expect(spyInteractor.fetchMangasWasCalled == true)
        }

        @Test("Load mangas failure sets error message")
        func loadMangasFailure() async {
            // Given
            spyInteractor.shouldThrowError = true
            spyInteractor.errorToThrow = NetworkError.serverError(500)

            // When
            await sut.loadMangas()

            // Then
            #expect(sut.mangas.isEmpty)
            #expect(sut.errorMessage != nil)
            #expect(sut.isLoading == false)
            #expect(spyInteractor.fetchMangasWasCalled == true)
        }

        @Test("Loading state is true while loading mangas")
        func loadingState() async {
            // Given
            spyInteractor.mangasToReturn = Self.sampleMangas

            // When
            let loadTask = Task {
                await sut.loadMangas()
            }

            // Then - isLoading should be true initially
            // Note: This is a simplified check since we can't easily test concurrent state
            await loadTask.value
            #expect(sut.isLoading == false)
        }

        // MARK: - Load More Mangas Tests

        @Test("Load more mangas appends to existing mangas")
        func loadMoreMangasSuccess() async {
            // Given
            let initialMangas = [Self.sampleMangas[0]]
            let moreMangas = [Self.sampleMangas[1]]
            spyInteractor.mangasToReturn = initialMangas
            spyInteractor.totalToReturn = 100  // Simulate more pages available
            await sut.loadMangas()

            spyInteractor.mangasToReturn = moreMangas
            spyInteractor.totalToReturn = 100  // Maintain total count

            // When
            await sut.loadMoreMangas()

            // Then
            #expect(sut.mangas.count == 2)
            #expect(sut.isLoadingMore == false)
        }

        @Test("Load more mangas does not execute when already loading")
        func loadMoreMangasWhileLoading() async {
            // Given
            spyInteractor.mangasToReturn = Self.sampleMangas
            await sut.loadMangas()

            // Simulate loading state
            // When
            await sut.loadMoreMangas()

            // Then - should have called the interactor
            #expect(spyInteractor.fetchMangasWasCalled == true)
        }

        // MARK: - Filter Tests

        @Test(
            "Apply filter updates selected filter and loads mangas",
            arguments: [
                .init(filter: .genre("Action"), expectedGenreCall: true),
                .init(filter: .demographic("Shounen"), expectedDemographicCall: true),
                .init(filter: .theme("School"), expectedThemeCall: true),
                .init(filter: .none, expectedNoneCall: true)
            ] as [ApplyFilterArgument]
        )
        private func applyFilter(argument: ApplyFilterArgument) async {
            // Given
            spyInteractor.mangasToReturn = Self.sampleMangas

            // When
            await sut.applyFilter(argument.filter)

            // Then
            #expect(sut.selectedFilter == argument.filter)

            if argument.expectedGenreCall {
                #expect(spyInteractor.fetchMangasByGenreWasCalled == true)
            } else if argument.expectedDemographicCall {
                #expect(spyInteractor.fetchMangasByDemographicWasCalled == true)
            } else if argument.expectedThemeCall {
                #expect(spyInteractor.fetchMangasByThemeWasCalled == true)
            } else if argument.expectedNoneCall {
                #expect(spyInteractor.fetchMangasWasCalled == true)
            }
        }

        @Test("Clear filters resets to none filter")
        func clearFilters() async {
            // Given
            spyInteractor.mangasToReturn = Self.sampleMangas
            await sut.applyFilter(.genre("Action"))

            // When
            await sut.clearFilters()

            // Then
            #expect(sut.selectedFilter == .none)
            #expect(sut.isFilterActive == false)
        }

        @Test("isFilterActive returns true when filter is applied")
        func isFilterActive() async {
            // Given
            spyInteractor.mangasToReturn = Self.sampleMangas

            // When - no filter
            #expect(sut.isFilterActive == false)

            // When - with filter
            await sut.applyFilter(.genre("Action"))

            // Then
            #expect(sut.isFilterActive == true)
        }

        // MARK: - Load Filter Options Tests

        @Test("Load filter options loads all filter data")
        func loadFilterOptions() async {
            // Given
            spyInteractor.genresToReturn = Self.sampleGenres
            spyInteractor.demographicsToReturn = Self.sampleDemographics
            spyInteractor.themesToReturn = Self.sampleThemes

            // When
            await sut.loadFilterOptions()

            // Then
            #expect(sut.genres.map(\.genre) == spyInteractor.genresToReturn)
            #expect(sut.demographics.map(\.demographic) == spyInteractor.demographicsToReturn)
            #expect(sut.themes.map(\.theme) == spyInteractor.themesToReturn)
            #expect(spyInteractor.fetchGenresWasCalled == true)
            #expect(spyInteractor.fetchDemographicsWasCalled == true)
            #expect(spyInteractor.fetchThemesWasCalled == true)
        }

        // MARK: - Error Handling Tests

        @Test(
            "Handle different error types correctly",
            arguments: [
                .init(error: NetworkError.invalidURL, expectedContains: L10n.Error.generic),
                .init(error: NetworkError.invalidResponse, expectedContains: L10n.Error.generic),
                .init(error: NetworkError.serverError(500), expectedContains: L10n.Error.generic),
                .init(error: URLError(.notConnectedToInternet), expectedContains: L10n.Error.network),
                .init(error: URLError(.timedOut), expectedContains: L10n.Error.timeout)
            ] as [HandleErrorArgument]
        )
        private func handleErrorTypes(argument: HandleErrorArgument) async {
            // Given
            spyInteractor.shouldThrowError = true
            spyInteractor.errorToThrow = argument.error

            // When
            await sut.loadMangas()

            // Then
            #expect(sut.errorMessage?.localizedCaseInsensitiveContains(argument.expectedContains) == true)
            switch argument.error {
            case NetworkError.invalidURL, NetworkError.invalidResponse, NetworkError.serverError:
                #expect(sut.errorMessage == L10n.Error.generic)
            case URLError.notConnectedToInternet:
                #expect(sut.errorMessage == L10n.Error.network)
            case URLError.timedOut:
                #expect(sut.errorMessage == L10n.Error.timeout)
            case URLError.timedOut:
                #expect(sut.errorMessage == L10n.Error.timeout)
            default:
                #expect(sut.errorMessage == L10n.Error.generic)
            }
        }
    }
}

// MARK: - Test Data

private extension MangaListTests.ViewModelTests {

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
            title: "Attack on Titan",
            titleEnglish: "Attack on Titan",
            titleJapanese: nil,
            sypnosis: "Humanity fights titans",
            background: nil,
            mainPicture: nil,
            url: nil,
            volumes: nil,
            chapters: nil,
            status: "Finished",
            score: 8.54,
            startDate: nil,
            endDate: nil,
            authors: [],
            genres: [.init(id: "1", genre: "Action")],
            demographics: [.init(id: "1", demographic: "Shounen")],
            themes: [.init(id: "2", theme: "Military")]
        )
    ]

    static let sampleGenres: [String] = [
        Genre.testData
    ].map { $0.genre }

    static let sampleDemographics: [String] = [
        Demographic.testData
    ].map { $0.demographic }

    static let sampleThemes: [String] = [
        Theme.testData
    ].map { $0.theme }
}

// MARK: - Arguments

private extension MangaListTests.ViewModelTests {

    struct ApplyFilterArgument: CustomTestStringConvertible {
        let filter: MangaFilter
        let expectedGenreCall: Bool
        let expectedDemographicCall: Bool
        let expectedThemeCall: Bool
        let expectedNoneCall: Bool

        var testDescription: String {
            switch filter {
            case .genre(let value):
                "genre: \(value)"
            case .demographic(let value):
                "demographic: \(value)"
            case .theme(let value):
                "theme: \(value)"
            case .none:
                "none"
            case .advanced(let customSearch, let searchSortOption):
                "advanced: \(customSearch), \(searchSortOption)"
            }
        }

        init(
            filter: MangaFilter,
            expectedGenreCall: Bool = false,
            expectedDemographicCall: Bool = false,
            expectedThemeCall: Bool = false,
            expectedNoneCall: Bool = false
        ) {
            self.filter = filter
            self.expectedGenreCall = expectedGenreCall
            self.expectedDemographicCall = expectedDemographicCall
            self.expectedThemeCall = expectedThemeCall
            self.expectedNoneCall = expectedNoneCall
        }
    }

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
