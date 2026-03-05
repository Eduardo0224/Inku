//
//  KeychainServiceTests.swift
//  InkuTests
//
//  Created by Eduardo Andrade on 04/03/26.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2026 Eduardo Andrade. All rights reserved.
//

import Testing
import Foundation
@testable import Inku

@Suite("KeychainService Tests", .serialized)
struct KeychainServiceTests {

    // MARK: - Subject Under Test

    let sut = KeychainService()

    // MARK: - AuthToken Tests

    @Test("Save and retrieve auth token successfully")
    func saveAndGetAuthToken() throws {
        // Given
        try? sut.deleteToken()
        let token = AuthToken(token: "test_auth_token_12345")
        // When
        try sut.save(token: token)
        let retrievedToken = try sut.getToken()
        // Then
        let unwrappedToken = try #require(retrievedToken)
        #expect(unwrappedToken.token == token.token)
        // Allow small difference in timestamps due to encoding/decoding
        let timeDifference = abs(unwrappedToken.expirationDate.timeIntervalSince1970 - token.expirationDate.timeIntervalSince1970)
        #expect(timeDifference < 1.0)
    }

    @Test("Update existing auth token")
    func updateAuthToken() throws {
        // Given
        try? sut.deleteToken()
        let originalToken = AuthToken(token: "original_token")
        let updatedToken = AuthToken(token: "updated_token")
        // When
        try sut.save(token: originalToken)
        try sut.save(token: updatedToken)
        let retrievedToken = try sut.getToken()
        // Then
        let unwrappedToken = try #require(retrievedToken)
        #expect(unwrappedToken.token == "updated_token")
    }

    @Test("Delete auth token successfully")
    func deleteAuthToken() throws {
        try? sut.deleteToken()
        // Given
        let token = AuthToken(token: "token_to_delete")
        try sut.save(token: token)
        // When
        try sut.deleteToken()
        let retrievedToken = try sut.getToken()
        // Then
        #expect(retrievedToken == nil)
    }

    @Test("Get auth token returns nil when not found")
    func getAuthTokenNotFound() throws {
        // Given
        try? sut.deleteToken()
        // When
        let token = try sut.getToken()
        // Then
        #expect(token == nil)
    }

    // MARK: - Email Tests

    @Test("Save and retrieve email successfully")
    func saveAndGetEmail() throws {
        // Given
        try? sut.deleteEmail()
        let email = "test@inku.com"
        // When
        try sut.save(email: email)
        let retrievedEmail = try sut.getEmail()
        // Then
        #expect(retrievedEmail == email)
    }

    @Test("Update existing email")
    func updateEmail() throws {
        // Given
        try? sut.deleteEmail()
        let originalEmail = "original@inku.com"
        let updatedEmail = "updated@inku.com"
        // When
        try sut.save(email: originalEmail)
        try sut.save(email: updatedEmail)
        let retrievedEmail = try sut.getEmail()
        // Then
        #expect(retrievedEmail == updatedEmail)
    }

    @Test("Delete email successfully")
    func deleteEmail() throws {
        // Given
        try? sut.deleteEmail()
        let email = "delete@inku.com"
        try sut.save(email: email)
        // When
        try sut.deleteEmail()
        let retrievedEmail = try sut.getEmail()
        // Then
        #expect(retrievedEmail == nil)
    }

    @Test("Get email returns nil when not found")
    func getEmailNotFound() throws {
        // Given
        try? sut.deleteEmail()
        // When
        let email = try sut.getEmail()
        // Then
        #expect(email == nil)
    }

    // MARK: - App Token Tests

    @Test("Save and retrieve app token successfully")
    func saveAndGetAppToken() throws {
        // Given
        try? deleteAppToken()
        let appToken = "test_app_token_xyz_12345"
        // When
        try sut.save(appToken: appToken)
        let retrievedAppToken = try sut.getAppToken()
        // Then
        #expect(retrievedAppToken == appToken)
    }

    @Test("Update existing app token")
    func updateAppToken() throws {
        // Given
        try? deleteAppToken()
        let originalAppToken = "original_app_token"
        let updatedAppToken = "updated_app_token"
        // When
        try sut.save(appToken: originalAppToken)
        try sut.save(appToken: updatedAppToken)
        let retrievedAppToken = try sut.getAppToken()
        // Then
        #expect(retrievedAppToken == updatedAppToken)
    }

    @Test("Get app token returns nil when not found")
    func getAppTokenNotFound() throws {
        // Given
        try? deleteAppToken()
        // When
        let appToken = try sut.getAppToken()
        // Then
        #expect(appToken == nil)
    }

    // MARK: - Delete All Tests

    @Test("Delete all removes auth token and email")
    func deleteAllSuccess() throws {
        // Given
        try? sut.deleteAll()
        let token = AuthToken(token: "test_token")
        let email = "test@inku.com"
        try sut.save(token: token)
        try sut.save(email: email)
        // When
        try sut.deleteAll()
        // Then
        let retrievedToken = try sut.getToken()
        let retrievedEmail = try sut.getEmail()
        #expect(retrievedToken == nil)
        #expect(retrievedEmail == nil)
    }

    @Test("Delete all succeeds even when items don't exist")
    func deleteAllWhenEmpty() throws {
        // Given
        try? sut.deleteToken()
        try? sut.deleteEmail()
        // When & Then
        try sut.deleteAll()
    }

    // MARK: - Error Handling Tests

    @Test("Save token with empty string")
    func saveEmptyToken() throws {
        // Given
        try? sut.deleteToken()
        let emptyToken = AuthToken(token: "")
        // When
        try sut.save(token: emptyToken)
        let retrievedToken = try sut.getToken()
        // Then
        let unwrappedToken = try #require(retrievedToken)
        #expect(unwrappedToken.token == "")
    }

    @Test("Save email with empty string")
    func saveEmptyEmail() throws {
        // Given
        try? sut.deleteEmail()
        let emptyEmail = ""
        // When
        try sut.save(email: emptyEmail)
        let retrievedEmail = try sut.getEmail()
        // Then
        #expect(retrievedEmail == "")
    }
}

// MARK: - Private Helper Functions

private extension KeychainServiceTests {

    func deleteAppToken() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "com.inku.app",
            kSecAttrAccount as String: "appToken"
        ]
        SecItemDelete(query as CFDictionary)
    }
}
