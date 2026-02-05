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
    private(set) var postWasCalled = false
    private(set) var deleteWasCalled = false
    private(set) var lastEndpoint: String?
    private(set) var lastQueryItems: [URLQueryItem]?
    private(set) var lastBody: (any Encodable & Sendable)?
    private(set) var lastHeaders: [String: String]?

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

    func get<T>(endpoint: String, headers: [String: String]) async throws -> T where T : Decodable, T : Sendable {
        getWasCalled = true
        lastEndpoint = endpoint
        lastHeaders = headers

        if shouldThrowError {
            throw errorToThrow
        }

        guard let data = dataToReturn as? T else {
            throw NetworkError.invalidResponse
        }

        return data
    }

    func post<T, U>(
        endpoint: String,
        body: T,
        headers: [String : String]
    ) async throws -> U where T : Encodable, T : Sendable, U : Decodable, U : Sendable {
        postWasCalled = true
        lastEndpoint = endpoint
        lastBody = body
        lastHeaders = headers

        if shouldThrowError {
            throw errorToThrow
        }

        guard let data = dataToReturn as? U else {
            throw NetworkError.invalidResponse
        }

        return data
    }

    func post<U>(
        endpoint: String,
        headers: [String : String]
    ) async throws -> U where U : Decodable, U : Sendable {
        postWasCalled = true
        lastEndpoint = endpoint
        lastHeaders = headers

        if shouldThrowError {
            throw errorToThrow
        }

        guard let data = dataToReturn as? U else {
            throw NetworkError.invalidResponse
        }

        return data
    }

    func post<T>(
        endpoint: String,
        body: T,
        headers: [String : String]
    ) async throws where T : Encodable, T : Sendable {
        postWasCalled = true
        lastEndpoint = endpoint
        lastBody = body
        lastHeaders = headers

        if shouldThrowError {
            throw errorToThrow
        }
    }

    func delete(endpoint: String, headers: [String : String]) async throws {
        deleteWasCalled = true
        lastEndpoint = endpoint
        lastHeaders = headers

        if shouldThrowError {
            throw errorToThrow
        }
    }
}
