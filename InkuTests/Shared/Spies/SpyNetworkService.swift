//
//  SpyNetworkService.swift
//  InkuTests
//
//  Created by Eduardo Andrade on 24/12/25.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2025 Eduardo Andrade. All rights reserved.
//

import Foundation
@testable import Inku

final class SpyNetworkService: NetworkServiceProtocol, @unchecked Sendable {

    // MARK: - Properties (Spy Tracking)

    private(set) var getWasCalled = false
    private(set) var lastEndpoint: String?
    private(set) var lastQueryItems: [URLQueryItem]?
    private(set) var postWasCalled = false
    private(set) var lastBody: (any Encodable & Sendable)?

    // MARK: - Properties (Stub Data)

    var dataToReturn: (any Decodable & Sendable)?
    var shouldThrowError = false
    var errorToThrow: Error = NetworkError.unknown(0)

    // MARK: - Functions

    func get<T: Decodable & Sendable>(endpoint: String) async throws -> T {
        try await get(endpoint: endpoint, queryItems: [])
    }

    func get<T: Decodable & Sendable>(endpoint: String, queryItems: [URLQueryItem]) async throws -> T {
        getWasCalled = true
        lastEndpoint = endpoint
        lastQueryItems = queryItems

        if shouldThrowError {
            throw errorToThrow
        }

        guard let data = dataToReturn as? T else {
            throw NetworkError.invalidResponse
        }

        return data
    }

    func post<T: Encodable & Sendable, U: Decodable & Sendable>(
        endpoint: String,
        body: T,
        queryItems: [URLQueryItem]
    ) async throws -> U {
        postWasCalled = true
        lastEndpoint = endpoint
        lastBody = body
        lastQueryItems = queryItems

        if shouldThrowError {
            throw errorToThrow
        }

        guard let data = dataToReturn as? U else {
            throw NetworkError.invalidResponse
        }

        return data
    }
}
