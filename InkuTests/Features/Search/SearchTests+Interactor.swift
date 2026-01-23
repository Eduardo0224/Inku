//
//  SearchTests+Interactor.swift
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

    @Suite("Interactor Tests")
    @MainActor
    struct InteractorTests {

        // MARK: - Subject Under Test

        let sut: SearchInteractor

        // MARK: - Spies

        let spyNetworkService: SpyNetworkService

        // MARK: - Initializers

        init() {
            spyNetworkService = SpyNetworkService()
            sut = SearchInteractor(networkService: spyNetworkService)
        }

        // MARK: - Search by Title Tests

        @Test("Search mangas contains makes correct API call")
        func searchMangasContainsSuccess() async throws {
            // Given
            let searchText = "One Piece"
            let page = 1
            let per = 20
            spyNetworkService.dataToReturn = Self.sampleMangaListResponse

            // When
            let response = try await sut.searchMangasContains(searchText, page: page, per: per)

            // Then
            #expect(response.items.count == Self.sampleMangaListResponse.items.count)
            #expect(spyNetworkService.getWasCalled == true)
            #expect(spyNetworkService.lastEndpoint == API.Endpoints.searchMangaContains(searchText))
            #expect(spyNetworkService.lastQueryItems?.contains(where: { $0.name == "page" }) == true)
            #expect(spyNetworkService.lastQueryItems?.contains(where: { $0.name == "per" }) == true)
        }

        @Test("Search mangas contains network failure throws error")
        func searchMangasContainsFailure() async throws {
            // Given
            spyNetworkService.shouldThrowError = true
            spyNetworkService.errorToThrow = NetworkError.serverError(500)

            // When/Then
            await #expect(throws: NetworkError.self) {
                _ = try await sut.searchMangasContains("One Piece", page: 1, per: 20)
            }
        }

        @Test("Search mangas begins with makes correct API call")
        func searchMangasBeginsWithSuccess() async throws {
            // Given
            let searchText = "One"
            spyNetworkService.dataToReturn = Self.sampleMangas

            // When
            let mangas = try await sut.searchMangasBeginsWith(searchText)

            // Then
            #expect(mangas.count == Self.sampleMangas.count)
            #expect(spyNetworkService.getWasCalled == true)
            #expect(spyNetworkService.lastEndpoint == API.Endpoints.searchMangaBeginsWith(searchText))
            #expect(spyNetworkService.lastQueryItems == []) // No pagination
        }

        @Test("Search mangas begins with network failure throws error")
        func searchMangasBeginsWithFailure() async throws {
            // Given
            spyNetworkService.shouldThrowError = true
            spyNetworkService.errorToThrow = NetworkError.serverError(500)

            // When/Then
            await #expect(throws: NetworkError.self) {
                _ = try await sut.searchMangasBeginsWith("One")
            }
        }

        // MARK: - Search by Author Tests

        @Test("Search authors by name makes correct API call")
        func searchAuthorsByNameSuccess() async throws {
            // Given
            let authorName = "Eiichiro Oda"
            spyNetworkService.dataToReturn = Self.sampleAuthors

            // When
            let authors = try await sut.searchAuthorsByName(authorName)

            // Then
            #expect(authors.count == Self.sampleAuthors.count)
            #expect(spyNetworkService.getWasCalled == true)
            #expect(spyNetworkService.lastEndpoint == API.Endpoints.searchAuthor(authorName))
        }

        @Test("Search authors by name network failure throws error")
        func searchAuthorsByNameFailure() async throws {
            // Given
            spyNetworkService.shouldThrowError = true
            spyNetworkService.errorToThrow = NetworkError.notFound

            // When/Then
            await #expect(throws: NetworkError.self) {
                _ = try await sut.searchAuthorsByName("Unknown Author")
            }
        }

        // MARK: - Pagination Tests

        @Test(
            "Search mangas contains with pagination parameters",
            arguments: [
                .init(page: 1, per: 20),
                .init(page: 2, per: 20),
                .init(page: 1, per: 50),
                .init(page: 3, per: 10)
            ] as [PaginationArgument]
        )
        private func searchMangasContainsWithPagination(argument: PaginationArgument) async throws {
            // Given
            spyNetworkService.dataToReturn = Self.sampleMangaListResponse

            // When
            _ = try await sut.searchMangasContains("manga", page: argument.page, per: argument.per)

            // Then
            let pageQuery = spyNetworkService.lastQueryItems?.first(where: { $0.name == "page" })
            let perQuery = spyNetworkService.lastQueryItems?.first(where: { $0.name == "per" })

            #expect(pageQuery?.value == "\(argument.page)")
            #expect(perQuery?.value == "\(argument.per)")
        }
    }
}

// MARK: - Test Data

private extension SearchTests.InteractorTests {

    static let sampleMangaListResponse = MangaListResponse(
        items: [.testData],
        metadata: .testData
    )

    static let sampleMangas: [Manga] = [
        .testData
    ]

    static let sampleAuthors: [Author] = [
        .testData
    ]
}

// MARK: - Arguments

private extension SearchTests.InteractorTests {

    struct PaginationArgument: CustomTestStringConvertible {
        let page: Int
        let per: Int

        var testDescription: String {
            "page: \(page), per: \(per)"
        }
    }
}
