//
//  MangaListInteractor.swift
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

final class MangaListInteractor: MangaListInteractorProtocol {

    // MARK: - Private Properties

    private let networkService: NetworkServiceProtocol

    // MARK: - Initializers

    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }

    // MARK: - Functions

    func fetchMangas(page: Int, per: Int) async throws -> MangaListResponse {
        let queryItems = makePaginationQueryItems(page: page, per: per)
        return try await networkService.get(endpoint: API.Endpoints.listMangas, queryItems: queryItems)
    }

    func fetchMangasByGenre(_ genre: String, page: Int, per: Int) async throws -> MangaListResponse {
        let queryItems = makePaginationQueryItems(page: page, per: per)
        return try await networkService.get(endpoint: API.Endpoints.listMangaByGenre(genre), queryItems: queryItems)
    }

    func fetchMangasByDemographic(_ demographic: String, page: Int, per: Int) async throws -> MangaListResponse {
        let queryItems = makePaginationQueryItems(page: page, per: per)
        return try await networkService.get(
            endpoint: API.Endpoints.listMangaByDemographic(demographic),
            queryItems: queryItems
        )
    }

    func fetchMangasByTheme(_ theme: String, page: Int, per: Int) async throws -> MangaListResponse {
        let queryItems = makePaginationQueryItems(page: page, per: per)
        return try await networkService.get(endpoint: API.Endpoints.listMangaByTheme(theme), queryItems: queryItems)
    }

    func fetchGenres() async throws -> [String] {
        try await networkService.get(endpoint: API.Endpoints.listGenres)
    }

    func fetchDemographics() async throws -> [String] {
        try await networkService.get(endpoint: API.Endpoints.listDemographics)
    }

    func fetchThemes() async throws -> [String] {
        try await networkService.get(endpoint: API.Endpoints.listThemes)
    }

    // MARK: - Private Functions

    private func makePaginationQueryItems(page: Int, per: Int) -> [URLQueryItem] {
        [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per", value: "\(per)")
        ]
    }
}
