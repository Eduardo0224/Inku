//
//  AuthenticationTests+Interactor.swift
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

import Testing
import Foundation
@testable import Inku

extension AuthenticationTests {
    
    @Suite("AuthInteractor Tests")
    struct InteractorTests {

        // MARK: - Subject Under Test

        let sut: AuthInteractor

        // MARK: - Spies

        let spyNetworkService: SpyNetworkService
        let spyKeychainService: SpyKeychainService

        // MARK: - Initializers

        init() {
            spyNetworkService = SpyNetworkService()
            spyKeychainService = SpyKeychainService()
            sut = AuthInteractor(
                networkService: spyNetworkService,
                keychainService: spyKeychainService
            )
        }

        // MARK: - Register Tests
        
        @Test("Register user successfully")
        func registerSuccess() async throws {
            // Given
            let user = User(email: "test@inku.com", password: "password123")
            // when
            try await sut.register(user: user)
            // Then
            #expect(spyNetworkService.postWasCalled)
            #expect(spyNetworkService.lastEndpoint == API.Endpoints.registerUser)
        }
        
        @Test("Register user fails with bad request")
        func registerFailure() async throws {
            // Given
            spyNetworkService.shouldThrowError = true
            spyNetworkService.errorToThrow = NetworkError.badRequest
            let user = User(email: "existing@inku.com", password: "password123")

            do {
                // When
                try await sut.register(user: user)
                // Then
                Issue.record("Expected error to be thrown")
            } catch {
                #expect(error is NetworkError)
            }
        }
        
        // MARK: - Login Tests
        
        @Test("Login successfully returns auth token")
        func loginSuccess() async throws {
            // Given
            spyNetworkService.dataToReturn = TokenResponse(token: "valid_auth_token_12345")
            let user = User(email: "test@inku.com", password: "password123")
            // When
            let token = try await sut.login(user: user)
            // Then
            #expect(spyNetworkService.postWasCalled)
            #expect(spyNetworkService.lastEndpoint == API.Endpoints.loginUser)
            #expect(token.token == "valid_auth_token_12345")
            #expect(spyKeychainService.saveTokenWasCalled)
            let authToken = try #require(spyKeychainService.savedAuthToken)
            #expect(authToken.token == "valid_auth_token_12345")
            #expect(spyKeychainService.saveEmailWasCalled)
            let email = try #require(spyKeychainService.savedEmail)
            #expect(email == "test@inku.com")
        }
        
        @Test("Login fails with unauthorized error")
        func loginUnauthorized() async throws {
            // Given
            spyNetworkService.shouldThrowError = true
            spyNetworkService.errorToThrow = NetworkError.unauthorized
            let user = User(email: "test@inku.com", password: "wrongpassword")
            
            do {
                // When
                _ = try await sut.login(user: user)
                // Then
                Issue.record("Expected error to be thrown")
            } catch {
                #expect(error as? NetworkError == .unauthorized)
            }
        }
        
        // MARK: - Token Renewal Tests
        
        @Test("Renew token successfully")
        func renewTokenSuccess() async throws {
            // Given
            spyNetworkService.dataToReturn = TokenResponse(token: "new_refreshed_token")
            let oldToken = AuthToken(token: "old_token")
            // When
            let newToken = try await sut.renewToken(oldToken)
            // Then
            #expect(spyNetworkService.postWasCalled)
            #expect(spyNetworkService.lastEndpoint == API.Endpoints.renewToken)
            #expect(newToken.token == "new_refreshed_token")
            #expect(spyKeychainService.saveTokenWasCalled)
            let authToken = try #require(spyKeychainService.savedAuthToken)
            #expect(authToken.token == "new_refreshed_token")
        }
        
        @Test("Renew token fails with expired token")
        func renewTokenExpired() async throws {
            // Given
            spyNetworkService.shouldThrowError = true
            spyNetworkService.errorToThrow = NetworkError.unauthorized
            let expiredToken = AuthToken(token: "expired_token")
            
            do {
                // When
                _ = try await sut.renewToken(expiredToken)
                // Then
                Issue.record("Expected error to be thrown")
            } catch {
                #expect(error as? NetworkError == .unauthorized)
            }
        }
        
        // MARK: - Logout Tests
        
        @Test("Logout successfully clears keychain")
        func logoutSuccess() async throws {
            // When
            try await sut.logout()
            // Then
            #expect(spyKeychainService.deleteAllWasCalled)
        }
        
        // MARK: - Keychain Tests
        
        @Test("Get saved token from keychain")
        func getSavedToken() async throws {
            // Given
            spyKeychainService.dataToReturn = AuthToken(token: "saved_token")
            // When
            let tokenResponse = try #require(await sut.getSavedToken())
            // Then
            #expect(spyKeychainService.getTokenWasCalled)
            #expect(tokenResponse.token == "saved_token")
        }
        
        @Test("Get saved token returns nil when not found")
        func getSavedTokenNil() async throws {
            // Given
            spyKeychainService.dataToReturn = nil
            // When
            let tokenResponse = try await sut.getSavedToken()
            // Then
            #expect(spyKeychainService.getTokenWasCalled)
            #expect(tokenResponse == nil)
        }
        
        @Test("Get saved email from keychain")
        func getSavedEmail() async throws {
            // Given
            spyKeychainService.dataToReturn = "saved@inku.com"
            // When
            let email = try #require(await sut.getSavedEmail())
            // Then
            #expect(spyKeychainService.getEmailWasCalled)
            #expect(email == "saved@inku.com")
        }
        
        // MARK: - Cloud Collection Tests
        
        @Test("Get cloud collection successfully")
        func getCloudCollectionSuccess() async throws {
            // Given
            spyNetworkService.dataToReturn = Self.mockCloudCollection
            let token = AuthToken(token: "valid_token")
            // When
            let collection = try await sut.getCloudCollection(token: token)
            // Then
            #expect(spyNetworkService.getWasCalled)
            #expect(spyNetworkService.lastEndpoint == API.Endpoints.collectionManga)
            #expect(collection.count == 1)
        }
        
        @Test("Get cloud collection fails with unauthorized")
        func getCloudCollectionUnauthorized() async throws {
            // Given
            spyNetworkService.shouldThrowError = true
            spyNetworkService.errorToThrow = NetworkError.unauthorized
            let token = AuthToken(token: "invalid_token")
            
            do {
                // When
                _ = try await sut.getCloudCollection(token: token)
                // Then
                Issue.record("Expected error to be thrown")
            } catch {
                #expect(error as? NetworkError == .unauthorized)
            }
        }
        
        // MARK: - Add to Cloud Collection Tests
        
        @Test("Add manga to cloud collection successfully")
        func addToCloudSuccess() async throws {
            // Given
            let token = AuthToken(token: "valid_token")
            let request = CreateCollectionMangaRequest(from: Self.mockCollectionManga)
            // When
            try await sut.addToCloudCollection(token: token, manga: request)
            // Then
            #expect(spyNetworkService.postWasCalled)
            #expect(spyNetworkService.lastEndpoint == API.Endpoints.collectionManga)
        }
        
        @Test("Add to cloud collection fails with network error")
        func addToCloudFailure() async throws {
            // Given
            spyNetworkService.shouldThrowError = true
            spyNetworkService.errorToThrow = NetworkError.serverError(500)
            let token = AuthToken(token: "valid_token")
            let request = CreateCollectionMangaRequest(from: Self.mockCollectionManga)
            
            do {
                // When
                try await sut.addToCloudCollection(token: token, manga: request)
                // Then
                Issue.record("Expected error to be thrown")
            } catch {
                #expect(error is NetworkError)
            }
        }
        
        // MARK: - Delete from Cloud Collection Tests
        
        @Test("Delete manga from cloud collection successfully")
        func deleteFromCloudSuccess() async throws {
            // Given
            let token = AuthToken(token: "valid_token")
            let mangaId = 123
            // When
            try await sut.deleteFromCloudCollection(token: token, mangaId: mangaId)
            // Then
            #expect(spyNetworkService.deleteWasCalled)
            #expect(spyNetworkService.lastEndpoint == API.Endpoints.collectionManga(id: mangaId))
        }
        
        @Test("Delete from cloud collection fails with not found")
        func deleteFromCloudNotFound() async throws {
            // Given
            spyNetworkService.shouldThrowError = true
            spyNetworkService.errorToThrow = NetworkError.notFound
            let token = AuthToken(token: "valid_token")
            let mangaId = 999
            
            do {
                // When
                try await sut.deleteFromCloudCollection(token: token, mangaId: mangaId)
                // Then
                Issue.record("Expected error to be thrown")
            } catch {
                #expect(error as? NetworkError == .notFound)
            }
        }
    }
}

// MARK: - Test Data

private extension AuthenticationTests.InteractorTests {

    private static let mockManga = Manga(
        id: 1,
        title: "Test Manga",
        titleEnglish: nil,
        titleJapanese: nil,
        sypnosis: nil,
        background: nil,
        mainPicture: nil,
        url: nil,
        volumes: 10,
        chapters: nil,
        status: nil,
        score: nil,
        startDate: nil,
        endDate: nil,
        authors: [],
        genres: [],
        demographics: [],
        themes: []
    )

    private static let mockCloudCollection = [
        CloudCollectionManga(
            id: "123",
            manga: mockManga,
            user: CloudCollectionManga.UserInfo(id: "user_123"),
            completeCollection: false,
            volumesOwned: [1, 2, 3],
            readingVolume: 3
        )
    ]

    private static let mockCollectionManga = CollectionManga(
        mangaId: 1,
        title: "Test Manga",
        coverImageURL: nil,
        totalVolumes: 10,
        volumesOwnedCount: 5,
        currentReadingVolume: 5,
        hasCompleteCollection: false
    )
}
