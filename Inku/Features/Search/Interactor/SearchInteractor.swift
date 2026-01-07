//
//  SearchInteractor.swift
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

final class SearchInteractor: SearchInteractorProtocol {

    // MARK: - Private Properties

    private let networkService: NetworkServiceProtocol

    // MARK: - Initializers

    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }

    // MARK: - Functions

    func searchMangasContains(_ text: String, page: Int, per: Int) async throws -> MangaListResponse {
        let queryItems = makePaginationQueryItems(page: page, per: per)
        return try await networkService.get(
            endpoint: API.Endpoints.searchMangaContains(text),
            queryItems: queryItems
        )
    }

    func searchMangasBeginsWith(_ text: String) async throws -> [Manga] {
        try await networkService.get(endpoint: API.Endpoints.searchMangaBeginsWith(text))
    }

    func searchAuthorsByName(_ name: String) async throws -> [Author] {
        try await networkService.get(endpoint: API.Endpoints.searchAuthor(name))
    }

    // MARK: - Private Functions

    private func makePaginationQueryItems(page: Int, per: Int) -> [URLQueryItem] {
        [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per", value: "\(per)")
        ]
    }
}
