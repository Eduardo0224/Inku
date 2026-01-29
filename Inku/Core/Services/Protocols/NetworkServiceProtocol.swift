//
//  NetworkServiceProtocol.swift
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

protocol NetworkServiceProtocol: Sendable {
    func get<T: Decodable & Sendable>(endpoint: String) async throws -> T
    func get<T: Decodable & Sendable>(endpoint: String, queryItems: [URLQueryItem]) async throws -> T
    func post<T: Encodable & Sendable, U: Decodable & Sendable>(endpoint: String, body: T, queryItems: [URLQueryItem]) async throws -> U
}
