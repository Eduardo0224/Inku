//
//  CollectionTests+Interactor.swift
//  InkuTests
//
//  Created by Eduardo Andrade on 21/01/26.
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

extension CollectionTests {

    @Suite("Interactor Tests")
    @MainActor
    struct InteractorTests {

        // MARK: - Subject Under Test

        let sut: CollectionInteractor

        // MARK: - Spies

        let spyNetworkService: SpyNetworkService

        // MARK: - Initializers

        init() {
            spyNetworkService = SpyNetworkService()
            sut = CollectionInteractor(networkService: spyNetworkService)
        }

        // MARK: - Get Manga By ID Tests

        @Test("Get manga by ID successfully")
        func getMangaByIdSuccess() async throws {
            // Given
            let mangaId = 1
            spyNetworkService.dataToReturn = Manga.testData

            // When
            let manga = try await sut.getMangaById(mangaId)

            // Then
            #expect(manga.id == Manga.testData.id)
            #expect(manga.displayTitle == Manga.testData.displayTitle)
            #expect(spyNetworkService.getWasCalled == true)
            #expect(spyNetworkService.lastEndpoint == API.Endpoints.searchManga(id: mangaId))
        }

        @Test("Get manga by ID network failure throws error")
        func getMangaByIdFailure() async throws {
            // Given
            let mangaId = 1
            spyNetworkService.shouldThrowError = true
            spyNetworkService.errorToThrow = NetworkError.serverError(500)

            // When/Then
            await #expect(throws: NetworkError.self) {
                _ = try await sut.getMangaById(mangaId)
            }

            #expect(spyNetworkService.getWasCalled == true)
            #expect(spyNetworkService.lastEndpoint == API.Endpoints.searchManga(id: mangaId))
        }

        @Test("Get manga by ID with different IDs", arguments: [1, 42, 100, 999, 12345])
        func getMangaByIdWithDifferentIds(mangaId: Int) async throws {
            // Given
            spyNetworkService.dataToReturn = Manga.testData

            // When
            _ = try await sut.getMangaById(mangaId)

            // Then
            #expect(spyNetworkService.getWasCalled == true)
            #expect(spyNetworkService.lastEndpoint == API.Endpoints.searchManga(id: mangaId))
        }

        @Test("Get manga by ID with invalid response throws error")
        func getMangaByIdInvalidResponse() async throws {
            // Given
            let mangaId = 1
            spyNetworkService.dataToReturn = nil

            // When/Then
            await #expect(throws: NetworkError.self) {
                _ = try await sut.getMangaById(mangaId)
            }

            #expect(spyNetworkService.getWasCalled == true)
            #expect(spyNetworkService.lastEndpoint == API.Endpoints.searchManga(id: mangaId))
        }
    }
}
