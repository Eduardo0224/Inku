//
//  SpySearchInteractor.swift
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
@testable import Inku

final class SpySearchInteractor: SearchInteractorProtocol, @unchecked Sendable {

    // MARK: - Properties (Spy Tracking)

    private(set) var searchMangasContainsWasCalled = false
    private(set) var searchMangasBeginsWithWasCalled = false
    private(set) var searchAuthorsByNameWasCalled = false

    private(set) var lastSearchedTextContains: String?
    private(set) var lastSearchedTextBeginsWith: String?
    private(set) var lastSearchedAuthorName: String?
    private(set) var lastPage: Int?
    private(set) var lastPer: Int?

    // MARK: - Properties (Stub Data)

    var mangasToReturn: [Manga] = []
    var authorsToReturn: [Author] = []
    var totalToReturn: Int?
    var shouldThrowError = false
    var errorToThrow: Error = NetworkError.unknown(0)

    // MARK: - Functions

    func reset() {
        searchMangasContainsWasCalled = false
        searchMangasBeginsWithWasCalled = false
        searchAuthorsByNameWasCalled = false

        lastSearchedTextContains = nil
        lastSearchedTextBeginsWith = nil
        lastSearchedAuthorName = nil
        lastPage = nil
        lastPer = nil
    }

    func searchMangasContains(_ text: String, page: Int, per: Int) async throws -> MangaListResponse {
        searchMangasContainsWasCalled = true
        lastSearchedTextContains = text
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

    func searchMangasBeginsWith(_ text: String) async throws -> [Manga] {
        searchMangasBeginsWithWasCalled = true
        lastSearchedTextBeginsWith = text

        if shouldThrowError {
            throw errorToThrow
        }

        return mangasToReturn
    }

    func searchAuthorsByName(_ name: String) async throws -> [Author] {
        searchAuthorsByNameWasCalled = true
        lastSearchedAuthorName = name

        if shouldThrowError {
            throw errorToThrow
        }

        return authorsToReturn
    }
}
