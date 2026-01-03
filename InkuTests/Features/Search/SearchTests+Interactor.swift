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
    struct InteractorTests {

        // MARK: - Subject Under Test

        let sut = SearchInteractor(networkService: MockNetworkService())

        // MARK: - Search by Title Tests

        @Test("Search by title makes correct API call")
        func searchByTitle() async throws {
            // Given
            let searchText = "One Piece"
            let page = 1
            let per = 20

            // When
            let response = try await sut.searchMangasByTitle(searchText, page: page, per: per)

            // Then
            #expect(response.items.isEmpty == false)
            #expect(response.metadata.page == page)
            #expect(response.metadata.per == per)
        }

        // MARK: - Search by Author Tests

        @Test("Search by author makes correct API call")
        func searchByAuthor() async throws {
            // Given
            let authorName = "Eiichiro Oda"

            // When
            let mangas = try await sut.searchMangasByAuthor(authorName)

            // Then
            #expect(mangas.isEmpty == false)
        }
    }
}

// MARK: - Mock Network Service

private final class MockNetworkService: NetworkServiceProtocol {

    func get<T: Decodable>(
        endpoint: String,
        queryItems: [URLQueryItem]?
    ) async throws -> T {
        if endpoint.contains("mangasContains") {
            return MangaListResponse.testData as! T
        } else if endpoint.contains("author") {
            return [Manga.testData] as! T
        }
        throw NetworkError.invalidResponse
    }

    func post<T: Decodable, U: Encodable>(
        endpoint: String,
        body: U
    ) async throws -> T {
        throw NetworkError.invalidResponse
    }
}
