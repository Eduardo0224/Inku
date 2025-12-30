//
//  MangaListTests+Interactor.swift
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

    @Suite("Interactor Tests")
    @MainActor
    struct InteractorTests {

        // MARK: - Subject Under Test

        let sut: MangaListInteractor

        // MARK: - Spies

        let spyNetworkService: SpyNetworkService

        // MARK: - Initializers

        init() {
            spyNetworkService = SpyNetworkService()
            sut = MangaListInteractor(networkService: spyNetworkService)
        }

        // MARK: - Fetch Mangas Tests

        @Test("Fetch mangas from network successfully")
        func fetchMangasSuccess() async throws {
            // Given
            spyNetworkService.dataToReturn = Self.sampleMangaListResponse

            // When
            let response = try await sut.fetchMangas(page: 1, per: 20)

            // Then
            #expect(response.items.count == Self.sampleMangaListResponse.items.count)
            #expect(spyNetworkService.getWasCalled == true)
            #expect(spyNetworkService.lastEndpoint == API.Endpoints.listMangas)
            #expect(spyNetworkService.lastQueryItems?.contains(where: { $0.name == "page" }) == true)
            #expect(spyNetworkService.lastQueryItems?.contains(where: { $0.name == "per" }) == true)
        }

        @Test("Fetch mangas network failure throws error")
        func fetchMangasFailure() async throws {
            // Given
            spyNetworkService.shouldThrowError = true
            spyNetworkService.errorToThrow = NetworkError.serverError(500)

            // When/Then
            await #expect(throws: NetworkError.self) {
                _ = try await sut.fetchMangas(page: 1, per: 20)
            }
        }

        // MARK: - Fetch Mangas By Genre Tests

        @Test("Fetch mangas by genre includes genre in endpoint")
        func fetchMangasByGenre() async throws {
            // Given
            spyNetworkService.dataToReturn = Self.sampleMangaListResponse
            let genre = "Action"

            // When
            let response = try await sut.fetchMangasByGenre(genre, page: 1, per: 20)

            // Then
            #expect(response.items.count == Self.sampleMangaListResponse.items.count)
            #expect(spyNetworkService.getWasCalled == true)
            #expect(spyNetworkService.lastEndpoint == API.Endpoints.listMangaByGenre(genre))
        }

        // MARK: - Fetch Mangas By Demographic Tests

        @Test("Fetch mangas by demographic includes demographic in endpoint")
        func fetchMangasByDemographic() async throws {
            // Given
            spyNetworkService.dataToReturn = Self.sampleMangaListResponse
            let demographic = "Shounen"

            // When
            let response = try await sut.fetchMangasByDemographic(demographic, page: 1, per: 20)

            // Then
            #expect(response.items.count == Self.sampleMangaListResponse.items.count)
            #expect(spyNetworkService.getWasCalled == true)
            #expect(spyNetworkService.lastEndpoint == API.Endpoints.listMangaByDemographic(demographic))
        }

        // MARK: - Fetch Mangas By Theme Tests

        @Test("Fetch mangas by theme includes theme in endpoint")
        func fetchMangasByTheme() async throws {
            // Given
            spyNetworkService.dataToReturn = Self.sampleMangaListResponse
            let theme = "School"

            // When
            let response = try await sut.fetchMangasByTheme(theme, page: 1, per: 20)

            // Then
            #expect(response.items.count == Self.sampleMangaListResponse.items.count)
            #expect(spyNetworkService.getWasCalled == true)
            #expect(spyNetworkService.lastEndpoint == API.Endpoints.listMangaByTheme(theme))
        }

        // MARK: - Fetch Filter Options Tests

        @Test("Fetch genres from network")
        func fetchGenres() async throws {
            // Given
            spyNetworkService.dataToReturn = Self.sampleGenres

            // When
            let genres = try await sut.fetchGenres()

            // Then
            #expect(genres.count == Self.sampleGenres.count)
            #expect(spyNetworkService.getWasCalled == true)
            #expect(spyNetworkService.lastEndpoint == API.Endpoints.listGenres)
        }

        @Test("Fetch demographics from network")
        func fetchDemographics() async throws {
            // Given
            spyNetworkService.dataToReturn = Self.sampleDemographics

            // When
            let demographics = try await sut.fetchDemographics()

            // Then
            #expect(demographics.count == Self.sampleDemographics.count)
            #expect(spyNetworkService.getWasCalled == true)
            #expect(spyNetworkService.lastEndpoint == API.Endpoints.listDemographics)
        }

        @Test("Fetch themes from network")
        func fetchThemes() async throws {
            // Given
            spyNetworkService.dataToReturn = Self.sampleThemes

            // When
            let themes = try await sut.fetchThemes()

            // Then
            #expect(themes.count == Self.sampleThemes.count)
            #expect(spyNetworkService.getWasCalled == true)
            #expect(spyNetworkService.lastEndpoint == API.Endpoints.listThemes)
        }

        // MARK: - Pagination Tests

        @Test(
            "Fetch mangas with pagination parameters",
            arguments: [
                .init(page: 1, per: 20),
                .init(page: 2, per: 20),
                .init(page: 1, per: 50),
                .init(page: 3, per: 10)
            ] as [PaginationArgument]
        )
        private func fetchMangasWithPagination(argument: PaginationArgument) async throws {
            // Given
            spyNetworkService.dataToReturn = Self.sampleMangaListResponse

            // When
            _ = try await sut.fetchMangas(page: argument.page, per: argument.per)

            // Then
            let pageQuery = spyNetworkService.lastQueryItems?.first(where: { $0.name == "page" })
            let perQuery = spyNetworkService.lastQueryItems?.first(where: { $0.name == "per" })

            #expect(pageQuery?.value == "\(argument.page)")
            #expect(perQuery?.value == "\(argument.per)")
        }
    }
}

// MARK: - Test Data

private extension MangaListTests.InteractorTests {

    static let sampleMangaListResponse = MangaListResponse(
        items: [.testData],
        metadata: .testData
    )

    static let sampleGenres: [String] = [
        Genre.testData
    ].map { String($0.genre) }

    static let sampleDemographics: [String] = [
        Demographic.testData
    ].map { String($0.demographic) }

    static let sampleThemes: [String] = [
        Theme.testData
    ].map { String($0.theme) }
}

// MARK: - Arguments

private extension MangaListTests.InteractorTests {

    struct PaginationArgument: CustomTestStringConvertible {
        let page: Int
        let per: Int

        var testDescription: String {
            "page: \(page), per: \(per)"
        }
    }
}
