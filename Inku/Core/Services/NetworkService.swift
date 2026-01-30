//
//  NetworkService.swift
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

final class NetworkService: NetworkServiceProtocol, Sendable {

    // MARK: - Private Properties

    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder

    // MARK: - Initializers

    init(
        baseURL: URL = URL(string: API.baseURL)!,
        session: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.session = session

        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder.dateDecodingStrategy = .iso8601
    }

    // MARK: - Functions

    func get<T: Decodable & Sendable>(endpoint: String) async throws -> T {
        try await get(endpoint: endpoint, queryItems: [])
    }

    func get<T: Decodable & Sendable>(endpoint: String, queryItems: [URLQueryItem]) async throws -> T {
        try await get(endpoint: endpoint, queryItems: queryItems, headers: [:])
    }

    func get<T: Decodable & Sendable>(endpoint: String, headers: [String: String]) async throws -> T {
        try await get(endpoint: endpoint, queryItems: [], headers: headers)
    }

    func get<T: Decodable & Sendable>(endpoint: String, queryItems: [URLQueryItem], headers: [String: String]) async throws -> T {
        let url = baseURL.appending(path: endpoint, directoryHint: .notDirectory)
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        components?.queryItems = queryItems.isEmpty ? nil : queryItems

        guard let finalURL = components?.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: finalURL)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")

        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        return try await perform(request)
    }

    func post<T: Encodable & Sendable, U: Decodable & Sendable>(
        endpoint: String,
        body: T,
        queryItems: [URLQueryItem] = []
    ) async throws -> U {
        try await post(endpoint: endpoint, body: body, queryItems: queryItems, headers: [:])
    }

    func post<T: Encodable & Sendable, U: Decodable & Sendable>(
        endpoint: String,
        body: T,
        headers: [String: String]
    ) async throws -> U {
        try await post(endpoint: endpoint, body: body, queryItems: [], headers: headers)
    }

    func post<T: Encodable & Sendable, U: Decodable & Sendable>(
        endpoint: String,
        body: T,
        queryItems: [URLQueryItem],
        headers: [String: String]
    ) async throws -> U {
        let url = baseURL.appending(path: endpoint, directoryHint: .notDirectory)
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        components?.queryItems = queryItems.isEmpty ? nil : queryItems

        guard let finalURL = components?.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: finalURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")

        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        request.httpBody = try encoder.encode(body)

        return try await perform(request)
    }

    func post<U: Decodable & Sendable>(endpoint: String, headers: [String: String]) async throws -> U {
        let url = baseURL.appending(path: endpoint, directoryHint: .notDirectory)

        guard let finalURL = URL(string: url.absoluteString) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: finalURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")

        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        return try await perform(request)
    }

    func delete(endpoint: String, headers: [String: String]) async throws {
        let url = baseURL.appending(path: endpoint, directoryHint: .notDirectory)

        guard let finalURL = URL(string: url.absoluteString) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: finalURL)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        let (_, response) = try await session.data(for: request)
        try validateResponse(response)
    }

    // MARK: - Private Functions

    private func perform<T: Decodable>(_ request: URLRequest) async throws -> T {
        let (data, response) = try await session.data(for: request)
        try validateResponse(response)
        return try decoder.decode(T.self, from: data)
    }

    private func validateResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200...299:
            return
        case 400:
            throw NetworkError.badRequest
        case 401:
            throw NetworkError.unauthorized
        case 404:
            throw NetworkError.notFound
        case 422:
            throw NetworkError.validationError
        case 500...599:
            throw NetworkError.serverError(httpResponse.statusCode)
        default:
            throw NetworkError.unknown(httpResponse.statusCode)
        }
    }
}

// MARK: - NetworkError

enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case badRequest
    case unauthorized
    case notFound
    case validationError
    case serverError(Int)
    case unknown(Int)
}
