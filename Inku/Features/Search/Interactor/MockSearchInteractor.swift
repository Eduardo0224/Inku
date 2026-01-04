//
//  MockSearchInteractor.swift
//  Inku
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

final class MockSearchInteractor: SearchInteractorProtocol {

    // MARK: - Functions

    func searchMangasByTitle(_ text: String, page: Int, per: Int) async throws -> MangaListResponse {
        .testData
    }

    func searchAuthorsByName(_ name: String) async throws -> [Author] {
        [.testData]
    }
}

// MARK: - Mock Error

final class MockSearchInteractorWithError: SearchInteractorProtocol {

    // MARK: - Functions

    func searchMangasByTitle(_ text: String, page: Int, per: Int) async throws -> MangaListResponse {
        throw URLError(.notConnectedToInternet)
    }

    func searchAuthorsByName(_ name: String) async throws -> [Author] {
        throw URLError(.notConnectedToInternet)
    }
}
