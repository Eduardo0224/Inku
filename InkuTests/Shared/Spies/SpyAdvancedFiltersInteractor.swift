//
//  SpyAdvancedFiltersInteractor.swift
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
@testable import Inku

final class SpyAdvancedFiltersInteractor: AdvancedFiltersInteractorProtocol, @unchecked Sendable {

    // MARK: - Properties (Spy Tracking)

    private(set) var searchMangasWasCalled = false
    private(set) var fetchGenresWasCalled = false
    private(set) var fetchDemographicsWasCalled = false
    private(set) var fetchThemesWasCalled = false

    private(set) var lastSearchCriteria: CustomSearch?
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

    func reset() {
        searchMangasWasCalled = false
        fetchGenresWasCalled = false
        fetchDemographicsWasCalled = false
        fetchThemesWasCalled = false

        lastSearchCriteria = nil
        lastPage = nil
        lastPer = nil
    }

    func searchMangas(_ search: CustomSearch, page: Int, per: Int) async throws -> MangaListResponse {
        searchMangasWasCalled = true
        lastSearchCriteria = search
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
