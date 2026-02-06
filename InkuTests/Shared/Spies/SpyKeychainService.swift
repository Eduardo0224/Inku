//
//  SpyKeychainService.swift
//  InkuTests
//
//  Created by Eduardo Andrade on 03/02/26.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2026 Eduardo Andrade. All rights reserved.
//

import Foundation
@testable import Inku

final class SpyKeychainService: KeychainServiceProtocol, @unchecked Sendable {

    // MARK: - Properties (Spy Tracking)

    private(set) var saveTokenWasCalled = false
    private(set) var getTokenWasCalled = false
    private(set) var deleteTokenWasCalled = false
    private(set) var saveEmailWasCalled = false
    private(set) var getEmailWasCalled = false
    private(set) var deleteEmailWasCalled = false
    private(set) var deleteAllWasCalled = false

    private(set) var savedAuthToken: AuthToken?
    private(set) var savedEmail: String?

    // MARK: - Properties (Stub Data)

    var dataToReturn: Any?
    var shouldThrowError = false
    var errorToThrow: Error = KeychainError.encodingError

    // MARK: - KeychainServiceProtocol

    func save(token: AuthToken) throws {
        saveTokenWasCalled = true
        savedAuthToken = token

        if shouldThrowError {
            throw errorToThrow
        }
    }

    func getToken() throws -> AuthToken? {
        getTokenWasCalled = true

        if shouldThrowError {
            throw errorToThrow
        }

        return dataToReturn as? AuthToken
    }

    func deleteToken() throws {
        deleteTokenWasCalled = true

        if shouldThrowError {
            throw errorToThrow
        }
    }

    func save(email: String) throws {
        saveEmailWasCalled = true
        savedEmail = email

        if shouldThrowError {
            throw errorToThrow
        }
    }

    func getEmail() throws -> String? {
        getEmailWasCalled = true

        if shouldThrowError {
            throw errorToThrow
        }

        return dataToReturn as? String
    }

    func deleteEmail() throws {
        deleteEmailWasCalled = true

        if shouldThrowError {
            throw errorToThrow
        }
    }

    func deleteAll() throws {
        deleteAllWasCalled = true

        if shouldThrowError {
            throw errorToThrow
        }
    }
}
