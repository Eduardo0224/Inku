//
//  SpyMangaListInteractor.swift
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
@testable import Inku

final class SpyMangaListInteractor: MangaListInteractorProtocol, @unchecked Sendable {

    // MARK: - Properties (Spy Tracking)

    private(set) var fetchMangasWasCalled = false
    private(set) var fetchMangasByGenreWasCalled = false
    private(set) var fetchMangasByDemographicWasCalled = false
    private(set) var fetchMangasByThemeWasCalled = false
    private(set) var fetchGenresWasCalled = false
    private(set) var fetchDemographicsWasCalled = false
    private(set) var fetchThemesWasCalled = false

    private(set) var lastFetchedGenre: String?
    private(set) var lastFetchedDemographic: String?
    private(set) var lastFetchedTheme: String?
    private(set) var lastPage: Int?
    private(set) var lastPer: Int?

    // MARK: - Properties (Stub Data)

    var mangasToReturn: [Manga] = []
    var genresToReturn: [String] = []
    var demographicsToReturn: [String] = []
    var themesToReturn: [String] = []
    var totalToReturn: Int?
    var shouldThrowError = false
    var errorToThrow: Error = NetworkError.unknown(0)

    // MARK: - Functions

    func fetchMangas(page: Int, per: Int) async throws -> MangaListResponse {
        fetchMangasWasCalled = true
        lastPage = page
        lastPer = per

        if shouldThrowError {
            throw errorToThrow
        }

        let total = totalToReturn ?? mangasToReturn.count
        return MangaListResponse(
            items: mangasToReturn,
            metadata: .init(total: total, page: page, per: per)
        )
    }

    func fetchMangasByGenre(_ genre: String, page: Int, per: Int) async throws -> MangaListResponse {
        fetchMangasByGenreWasCalled = true
        lastFetchedGenre = genre
        lastPage = page
        lastPer = per

        if shouldThrowError {
            throw errorToThrow
        }

        let filtered = mangasToReturn.filter { $0.genres.contains(where: { $0.genre == genre }) }
        let total = totalToReturn ?? filtered.count
        return MangaListResponse(
            items: filtered,
            metadata: .init(total: total, page: page, per: per)
        )
    }

    func fetchMangasByDemographic(_ demographic: String, page: Int, per: Int) async throws -> MangaListResponse {
        fetchMangasByDemographicWasCalled = true
        lastFetchedDemographic = demographic
        lastPage = page
        lastPer = per

        if shouldThrowError {
            throw errorToThrow
        }

        let filtered = mangasToReturn.filter { $0.demographics.contains(where: { $0.demographic == demographic }) }
        let total = totalToReturn ?? filtered.count
        return MangaListResponse(
            items: filtered,
            metadata: .init(total: total, page: page, per: per)
        )
    }

    func fetchMangasByTheme(_ theme: String, page: Int, per: Int) async throws -> MangaListResponse {
        fetchMangasByThemeWasCalled = true
        lastFetchedTheme = theme
        lastPage = page
        lastPer = per

        if shouldThrowError {
            throw errorToThrow
        }

        let filtered = mangasToReturn.filter { $0.themes.contains(where: { $0.theme == theme }) }
        let total = totalToReturn ?? filtered.count
        return MangaListResponse(
            items: filtered,
            metadata: .init(total: total, page: page, per: per)
        )
    }

    func fetchGenres() async throws -> [String] {
        fetchGenresWasCalled = true

        if shouldThrowError {
            throw errorToThrow
        }

        return genresToReturn
    }

    func fetchDemographics() async throws -> [String] {
        fetchDemographicsWasCalled = true

        if shouldThrowError {
            throw errorToThrow
        }

        return demographicsToReturn
    }

    func fetchThemes() async throws -> [String] {
        fetchThemesWasCalled = true

        if shouldThrowError {
            throw errorToThrow
        }

        return themesToReturn
    }
}
