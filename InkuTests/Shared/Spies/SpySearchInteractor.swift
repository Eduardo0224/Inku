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

    private(set) var searchMangasByTitleWasCalled = false
    private(set) var searchAuthorsByNameWasCalled = false

    private(set) var lastSearchedText: String?
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
        searchMangasByTitleWasCalled = false
        searchAuthorsByNameWasCalled = false

        lastSearchedText = nil
        lastSearchedAuthorName = nil
        lastPage = nil
        lastPer = nil
    }

    func searchMangasByTitle(_ text: String, page: Int, per: Int) async throws -> MangaListResponse {
        searchMangasByTitleWasCalled = true
        lastSearchedText = text
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

    func searchAuthorsByName(_ name: String) async throws -> [Author] {
        searchAuthorsByNameWasCalled = true
        lastSearchedAuthorName = name

        if shouldThrowError {
            throw errorToThrow
        }

        return authorsToReturn
    }
}
