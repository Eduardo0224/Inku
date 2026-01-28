//
//  AdvancedFiltersTests+Interactor.swift
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

    @Suite("Interactor Tests")
    @MainActor
    struct InteractorTests {

        // MARK: - Subject Under Test

        let sut: AdvancedFiltersInteractor

        // MARK: - Spies

        let spyNetworkService: SpyNetworkService

        // MARK: - Initializers

        init() {
            spyNetworkService = SpyNetworkService()
            sut = AdvancedFiltersInteractor(networkService: spyNetworkService)
        }

        // MARK: - Search Mangas Tests

        @Test("Search mangas with POST request includes search criteria in body")
        func searchMangasSuccess() async throws {
            // Given
            spyNetworkService.dataToReturn = Self.sampleMangaListResponse
            let search = CustomSearch(
                searchTitle: "Dragon",
                searchGenres: ["Action", "Fantasy"],
                searchDemographics: ["Shounen"],
                searchContains: true
            )

            // When
            let response = try await sut.searchMangas(search, page: 1, per: 20)

            // Then
            #expect(response.items.count == Self.sampleMangaListResponse.items.count)
            #expect(spyNetworkService.postWasCalled == true)
            #expect(spyNetworkService.lastEndpoint == API.Endpoints.searchCustom)
            #expect(spyNetworkService.lastBody != nil)
            #expect(spyNetworkService.lastQueryItems?.contains(where: { $0.name == "page" }) == true)
            #expect(spyNetworkService.lastQueryItems?.contains(where: { $0.name == "per" }) == true)
        }

        @Test("Search mangas with minimal criteria")
        func searchMangasMinimalCriteria() async throws {
            // Given
            spyNetworkService.dataToReturn = Self.sampleMangaListResponse
            let search = CustomSearch(
                searchTitle: "Test",
                searchContains: false
            )

            // When
            let response = try await sut.searchMangas(search, page: 1, per: 20)

            // Then
            #expect(response.items.count == Self.sampleMangaListResponse.items.count)
            #expect(spyNetworkService.postWasCalled == true)
        }

        @Test("Search mangas network failure throws error")
        func searchMangasFailure() async throws {
            // Given
            spyNetworkService.shouldThrowError = true
            spyNetworkService.errorToThrow = NetworkError.serverError(500)
            let search = CustomSearch(searchTitle: "Test", searchContains: false)

            // When/Then
            await #expect(throws: NetworkError.self) {
                _ = try await sut.searchMangas(search, page: 1, per: 20)
            }
        }

        // MARK: - Fetch Genres Tests

        @Test("Fetch genres returns array of genre names")
        func fetchGenresSuccess() async throws {
            // Given
            spyNetworkService.dataToReturn = Self.sampleGenresResponse

            // When
            let genres = try await sut.fetchGenres()

            // Then
            #expect(genres.count == Self.sampleGenresResponse.count)
            #expect(spyNetworkService.getWasCalled == true)
            #expect(spyNetworkService.lastEndpoint == API.Endpoints.listGenres)
        }

        @Test("Fetch genres network failure throws error")
        func fetchGenresFailure() async throws {
            // Given
            spyNetworkService.shouldThrowError = true
            spyNetworkService.errorToThrow = NetworkError.serverError(500)

            // When/Then
            await #expect(throws: NetworkError.self) {
                _ = try await sut.fetchGenres()
            }
        }

        // MARK: - Fetch Demographics Tests

        @Test("Fetch demographics returns array of demographic names")
        func fetchDemographicsSuccess() async throws {
            // Given
            spyNetworkService.dataToReturn = Self.sampleDemographicsResponse

            // When
            let demographics = try await sut.fetchDemographics()

            // Then
            #expect(demographics.count == Self.sampleDemographicsResponse.count)
            #expect(spyNetworkService.getWasCalled == true)
            #expect(spyNetworkService.lastEndpoint == API.Endpoints.listDemographics)
        }

        @Test("Fetch demographics network failure throws error")
        func fetchDemographicsFailure() async throws {
            // Given
            spyNetworkService.shouldThrowError = true
            spyNetworkService.errorToThrow = NetworkError.serverError(500)

            // When/Then
            await #expect(throws: NetworkError.self) {
                _ = try await sut.fetchDemographics()
            }
        }

        // MARK: - Fetch Themes Tests

        @Test("Fetch themes returns array of theme names")
        func fetchThemesSuccess() async throws {
            // Given
            spyNetworkService.dataToReturn = Self.sampleThemesResponse

            // When
            let themes = try await sut.fetchThemes()

            // Then
            #expect(themes.count == Self.sampleThemesResponse.count)
            #expect(spyNetworkService.getWasCalled == true)
            #expect(spyNetworkService.lastEndpoint == API.Endpoints.listThemes)
        }

        @Test("Fetch themes network failure throws error")
        func fetchThemesFailure() async throws {
            // Given
            spyNetworkService.shouldThrowError = true
            spyNetworkService.errorToThrow = NetworkError.serverError(500)

            // When/Then
            await #expect(throws: NetworkError.self) {
                _ = try await sut.fetchThemes()
            }
        }
    }
}

// MARK: - Test Data

private extension AdvancedFiltersTests.InteractorTests {

    static let sampleMangaListResponse = MangaListResponse(
        items: [
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
                themes: [.init(id: "1", theme: "Adventure")]
            )
        ],
        metadata: .init(total: 1, page: 1, per: 20)
    )

    static let sampleGenresResponse = ["Action", "Adventure", "Drama"]

    static let sampleDemographicsResponse = ["Shounen", "Seinen", "Josei"]

    static let sampleThemesResponse = ["School", "Military", "Sports"]
}
