//
//  MockMangaListInteractor.swift
//  Inku
//
//  Created by Eduardo Andrade on 23/12/25.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2025 Eduardo Andrade. All rights reserved.
//

import Foundation

final class MockMangaListInteractor: MangaListInteractorProtocol {

    // MARK: - Functions

    func fetchMangas(page: Int, per: Int) async throws -> MangaListResponse {
        .testData
    }

    func fetchMangasByGenre(_ genre: String, page: Int, per: Int) async throws -> MangaListResponse {
        .testData
    }

    func fetchMangasByDemographic(_ demographic: String, page: Int, per: Int) async throws -> MangaListResponse {
        .testData
    }

    func fetchMangasByTheme(_ theme: String, page: Int, per: Int) async throws -> MangaListResponse {
        .testData
    }

    func fetchGenres() async throws -> [Genre] {
        []
    }

    func fetchDemographics() async throws -> [Demographic] {
        []
    }

    func fetchThemes() async throws -> [Theme] {
        []
    }
}
