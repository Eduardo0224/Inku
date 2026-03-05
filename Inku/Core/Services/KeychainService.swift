//
//  KeychainService.swift
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
import Security

final class KeychainService: KeychainServiceProtocol, Sendable {

    // MARK: - Private Properties

    private let service = "com.inku.app"
    private let tokenKey = "authToken"
    private let emailKey = "userEmail"
    private let appTokenKey = "appToken"

    // MARK: - Token Management

    func save(token: AuthToken) throws {
        let data = try JSONEncoder().encode(token)
        try save(data: data, key: tokenKey)
    }

    func getToken() throws -> AuthToken? {
        guard let data = try getData(key: tokenKey) else { return nil }
        return try JSONDecoder().decode(AuthToken.self, from: data)
    }

    func deleteToken() throws {
        try delete(key: tokenKey)
    }

    // MARK: - Email Management

    func save(email: String) throws {
        guard let data = email.data(using: .utf8) else {
            throw KeychainError.encodingError
        }
        try save(data: data, key: emailKey)
    }

    func getEmail() throws -> String? {
        guard let data = try getData(key: emailKey) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    func deleteEmail() throws {
        try delete(key: emailKey)
    }

    // MARK: - App Token Management

    func save(appToken: String) throws {
        guard let data = appToken.data(using: .utf8) else {
            throw KeychainError.encodingError
        }
        try save(data: data, key: appTokenKey)
    }

    func getAppToken() throws -> String? {
        guard let data = try getData(key: appTokenKey) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    // MARK: - Cleanup

    func deleteAll() throws {
        try deleteToken()
        try deleteEmail()
    }

    // MARK: - Private Functions

    private func save(data: Data, key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        if status == errSecDuplicateItem {
            let updateQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: key
            ]
            let attributesToUpdate: [String: Any] = [
                kSecValueData as String: data,
                kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
            ]
            let updateStatus = SecItemUpdate(updateQuery as CFDictionary, attributesToUpdate as CFDictionary)
            guard updateStatus == errSecSuccess else {
                throw KeychainError.updateFailed(updateStatus)
            }
        } else if status != errSecSuccess {
            throw KeychainError.saveFailed(status)
        }
    }

    private func getData(key: String) throws -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecItemNotFound {
            return nil
        }

        guard status == errSecSuccess else {
            throw KeychainError.retrievalFailed(status)
        }

        return result as? Data
    }

    private func delete(key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed(status)
        }
    }
}

// MARK: - KeychainError

enum KeychainError: LocalizedError {
    case encodingError
    case saveFailed(OSStatus)
    case updateFailed(OSStatus)
    case retrievalFailed(OSStatus)
    case deleteFailed(OSStatus)

    var errorDescription: String? {
        switch self {
        case .encodingError:
            "Failed to encode data"
        case .saveFailed(let status):
            "Failed to save to keychain. Status: \(status)"
        case .updateFailed(let status):
            "Failed to update keychain. Status: \(status)"
        case .retrievalFailed(let status):
            "Failed to retrieve from keychain. Status: \(status)"
        case .deleteFailed(let status):
            "Failed to delete from keychain. Status: \(status)"
        }
    }
}
