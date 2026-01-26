//
//  AdvancedFiltersInteractor.swift
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

/// Production implementation of AdvancedFiltersInteractorProtocol.
///
/// Handles multi-criteria manga search and filter options fetching.
final class AdvancedFiltersInteractor: AdvancedFiltersInteractorProtocol {

    // MARK: - Private Properties

    private let networkService: NetworkServiceProtocol

    // MARK: - Initializers

    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }

    // MARK: - Functions

    func searchMangas(_ search: CustomSearch, page: Int, per: Int) async throws -> MangaListResponse {
        let queryItems = makePaginationQueryItems(page: page, per: per)
        return try await networkService.post(
            endpoint: API.Endpoints.searchCustom,
            body: search,
            queryItems: queryItems
        )
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
