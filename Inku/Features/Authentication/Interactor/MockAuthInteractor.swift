//
//  MockAuthInteractor.swift
//  Inku
//
//  Created by Eduardo Andrade on 30/01/26.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2025 Eduardo Andrade. All rights reserved.
//

import Foundation

final class MockAuthInteractor: AuthInteractorProtocol, Sendable {

    func register(user: User) async throws {
        try await Task.sleep(for: .milliseconds(500))
    }

    func login(user: User) async throws -> AuthToken {
        try await Task.sleep(for: .milliseconds(500))
        return AuthToken(token: "mock_token_12345")
    }

    func renewToken(_ token: AuthToken) async throws -> AuthToken {
        try await Task.sleep(for: .milliseconds(500))
        return AuthToken(token: "mock_renewed_token_67890")
    }

    func logout() async throws {
        try await Task.sleep(for: .milliseconds(200))
    }

    func getSavedToken() async throws -> AuthToken? {
        nil
    }

    func getSavedEmail() async throws -> String? {
        nil
    }
}
