//
//  CollectionInteractor.swift
//  Inku
//
//  Created by Eduardo Andrade on 20/01/26.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2026 Eduardo Andrade. All rights reserved.
//

import Foundation

final class CollectionInteractor: CollectionInteractorProtocol {

    // MARK: - Private Properties

    private let networkService: NetworkServiceProtocol

    // MARK: - Initializers

    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }

    // MARK: - Functions

    func getMangaById(_ id: Int) async throws -> Manga {
        try await networkService.get(endpoint: "/search/manga/\(id)")
    }
}
