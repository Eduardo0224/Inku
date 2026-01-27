//
//  MockAdvancedFiltersInteractor.swift
//  Inku
//
//  Created by Eduardo Andrade on 26/01/26.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2026 Eduardo Andrade. All rights reserved.
//

import Foundation

/// Mock implementation for SwiftUI previews and manual testing.
final class MockAdvancedFiltersInteractor: AdvancedFiltersInteractorProtocol {

    // MARK: - Functions

    func searchMangas(_ search: CustomSearch, page: Int, per: Int) async throws -> MangaListResponse {
        .testData
    }

    func fetchGenres() async throws -> [String] {
        [
            "Action",
            "Adventure",
            "Sci-Fi",
            "Romance",
            "Comedy",
            "Drama",
            "Fantasy",
            "Horror",
            "Mystery",
            "Sports"
        ]
    }

    func fetchDemographics() async throws -> [String] {
        [
            "Shounen",
            "Shoujo",
            "Seinen",
            "Kids",
            "Josei"
        ]
    }

    func fetchThemes() async throws -> [String] {
        [
            "School",
            "Mecha",
            "Vampires",
            "Music",
            "Martial Arts",
            "Super Power",
            "Historical",
            "Military",
            "Psychological",
            "Slice of Life"
        ]
    }
}

// MARK: - Mock Error

final class MockAdvancedFiltersInteractorWithError: AdvancedFiltersInteractorProtocol {

    // MARK: - Functions

    func searchMangas(_ search: CustomSearch, page: Int, per: Int) async throws -> MangaListResponse {
        throw URLError(.notConnectedToInternet)
    }

    func fetchGenres() async throws -> [String] {
        throw URLError(.notConnectedToInternet)
    }

    func fetchDemographics() async throws -> [String] {
        throw URLError(.notConnectedToInternet)
    }

    func fetchThemes() async throws -> [String] {
        throw URLError(.notConnectedToInternet)
    }
}

// MARK: - Mock Empty Categories

/// Mock implementation that returns empty filter categories.
/// Used to test conditional rendering when no filter options are available.
final class MockAdvancedFiltersInteractorEmptyCategories: AdvancedFiltersInteractorProtocol {

    // MARK: - Functions

    func searchMangas(_ search: CustomSearch, page: Int, per: Int) async throws -> MangaListResponse {
        .testData
    }

    func fetchGenres() async throws -> [String] {
        []
    }

    func fetchDemographics() async throws -> [String] {
        []
    }

    func fetchThemes() async throws -> [String] {
        []
    }
}
