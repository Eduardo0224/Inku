//
//  AuthenticationTests+ViewModel.swift
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

    @Suite("AuthViewModel Tests")
    @MainActor
    struct ViewModelTests {

        // MARK: - Subject Under Test

        let sut: AuthViewModel

        // MARK: - Spies

        let spyInteractor: SpyAuthInteractor

        // MARK: - Initializers

        init() {
            spyInteractor = SpyAuthInteractor()
            sut = AuthViewModel(interactor: spyInteractor)
        }

        // MARK: - Login Tests

        @Test("Login successfully with valid credentials")
        func loginSuccess() async {
            // Given
            sut.email = "test@inku.com"
            sut.password = "password123"
            spyInteractor.dataToReturn = AuthToken(token: "valid_token")
            // When
            await sut.login()
            // Then
            #expect(spyInteractor.loginWasCalled)
            #expect(spyInteractor.lastLoginUser?.email == "test@inku.com")
            #expect(sut.isAuthenticated == true)
            #expect(sut.password == "")
            #expect(sut.errorMessage == nil)
        }

        @Test("Login fails with invalid credentials")
        func loginFailure() async {
            // Given
            sut.email = "test@inku.com"
            sut.password = "wrongpassword"
            spyInteractor.shouldThrowError = true
            spyInteractor.errorToThrow = NetworkError.unauthorized
            // When
            await sut.login()
            // Then
            #expect(spyInteractor.loginWasCalled)
            #expect(sut.isAuthenticated == false)
            #expect(sut.authState == .unauthenticated)
            #expect(sut.errorMessage != nil)
        }

        @Test("Login fails with network error")
        func loginNetworkError() async {
            // Given
            sut.email = "test@inku.com"
            sut.password = "password123"
            spyInteractor.shouldThrowError = true
            spyInteractor.errorToThrow = URLError(.notConnectedToInternet)
            // When
            await sut.login()
            // Then
            #expect(spyInteractor.loginWasCalled)
            #expect(sut.isAuthenticated == false)
            #expect(sut.errorMessage != nil)
        }

        @Test("Login with invalid form shows error")
        func loginInvalidForm() async {
            // Given
            sut.email = "invalid-email"
            sut.password = "12345"
            // When
            await sut.login()
            // Then
            #expect(!spyInteractor.loginWasCalled)
            #expect(sut.errorMessage != nil)
            #expect(sut.authState == .unauthenticated)
        }

        // MARK: - Register Tests

        @Test("Register successfully with valid data")
        func registerSuccess() async {
            // Given
            sut.email = "newuser@inku.com"
            sut.password = "password123"
            spyInteractor.dataToReturn = AuthToken(token: "new_user_token")
            // When
            await sut.register()
            // Then
            #expect(spyInteractor.registerWasCalled)
            #expect(spyInteractor.loginWasCalled)
            #expect(sut.isAuthenticated == true)
        }

        @Test("Register fails with existing user")
        func registerExistingUser() async {
            // Given
            sut.email = "existing@inku.com"
            sut.password = "password123"
            spyInteractor.shouldThrowError = true
            spyInteractor.errorToThrow = NetworkError.badRequest
            // When
            await sut.register()
            // Then
            #expect(spyInteractor.registerWasCalled)
            #expect(sut.isAuthenticated == false)
            #expect(sut.errorMessage != nil)
        }

        @Test("Register with invalid form shows error")
        func registerInvalidForm() async {
            // Given
            sut.email = "invalid-email"
            sut.password = "short"
            // When
            await sut.register()
            // Then
            #expect(!spyInteractor.registerWasCalled)
            #expect(sut.errorMessage != nil)
            #expect(!sut.isAuthenticated)
        }

        // MARK: - Token Management Tests

        @Test("Renew token when expired")
        func renewExpiredToken() async {
            // Given
            let expiredToken = AuthToken(token: "expired_token", expirationDate: Date().addingTimeInterval(-3600))
            sut.authState = .authenticated(expiredToken)
            spyInteractor.dataToReturn = AuthToken(token: "renewed_token")
            // When
            await sut.renewTokenIfNeeded()
            // Then
            #expect(spyInteractor.renewTokenWasCalled)
            if case .authenticated(let token) = sut.authState {
                #expect(token.token == "renewed_token")
            } else {
                Issue.record("Expected authenticated state with renewed token")
            }
        }

        @Test("Renew token when not expired skips renewal")
        func renewTokenNotExpired() async {
            // Given
            let validToken = AuthToken(token: "valid_token", expirationDate: Date().addingTimeInterval(3600))
            sut.authState = .authenticated(validToken)
            // When
            await sut.renewTokenIfNeeded()
            // Then
            #expect(!spyInteractor.renewTokenWasCalled)
            if case .authenticated(let token) = sut.authState {
                #expect(token.token == "valid_token")
            } else {
                Issue.record("Expected authenticated state with same token")
            }
        }

        @Test("Renew token handles error and logs out")
        func renewTokenError() async {
            // Given
            let expiredToken = AuthToken(token: "expired_token", expirationDate: Date().addingTimeInterval(-3600))
            sut.authState = .authenticated(expiredToken)
            spyInteractor.shouldThrowError = true
            spyInteractor.errorToThrow = NetworkError.unauthorized
            // When
            await sut.renewTokenIfNeeded()
            // Then
            #expect(spyInteractor.renewTokenWasCalled)
            #expect(sut.authState == .unauthenticated)
            #expect(sut.errorMessage != nil)
        }

        @Test("Check authentication status with saved token")
        func checkAuthStatusWithToken() async {
            // Given
            spyInteractor.dataToReturn = AuthToken(token: "saved_token")
            // When
            await sut.checkAuthenticationStatus()
            // Then
            #expect(spyInteractor.getSavedTokenWasCalled)
            #expect(sut.isAuthenticated == true)
        }

        @Test("Check authentication status without saved token")
        func checkAuthStatusWithoutToken() async {
            // Given
            spyInteractor.dataToReturn = nil
            // When
            await sut.checkAuthenticationStatus()
            // Then
            #expect(spyInteractor.getSavedTokenWasCalled)
            #expect(sut.isAuthenticated == false)
            #expect(sut.authState == .unauthenticated)
        }

        @Test("Check authentication status handles error")
        func checkAuthStatusError() async {
            // Given
            spyInteractor.shouldThrowError = true
            spyInteractor.errorToThrow = NetworkError.unknown(0)
            // When
            await sut.checkAuthenticationStatus()
            // Then
            #expect(sut.authState == .unauthenticated)
            #expect(sut.errorMessage != nil)
        }

        // MARK: - Logout Tests

        @Test("Logout successfully")
        func logoutSuccess() async {
            // Given
            sut.authState = .authenticated(AuthToken(token: "token"))
            sut.email = "test@inku.com"
            sut.password = "password"
            // When
            await sut.logout()
            // Then
            #expect(spyInteractor.logoutWasCalled)
            #expect(sut.authState == .unauthenticated)
            #expect(sut.email == "")
            #expect(sut.password == "")
        }

        @Test("Logout handles error")
        func logoutError() async {
            // Given
            sut.authState = .authenticated(AuthToken(token: "token"))
            spyInteractor.shouldThrowError = true
            spyInteractor.errorToThrow = NetworkError.unknown(0)
            // When
            await sut.logout()
            // Then
            #expect(spyInteractor.logoutWasCalled)
            #expect(sut.errorMessage != nil)
        }

        // MARK: - Cloud Collection Tests

        @Test("Fetch cloud collection successfully")
        func fetchCloudCollectionSuccess() async {
            // Given
            let token = AuthToken(token: "valid_token")
            sut.authState = .authenticated(token)
            spyInteractor.dataToReturn = [Self.mockCloudManga]
            // When
            await sut.fetchCloudCollection()
            // Then
            #expect(spyInteractor.getCloudCollectionWasCalled)
            #expect(sut.cloudMangaCount == 1)
            #expect(sut.cloudMangaIds.count == 1)
        }

        @Test("Fetch cloud collection with unauthorized error")
        func fetchCloudCollectionUnauthorized() async {
            // Given
            let token = AuthToken(token: "invalid_token")
            sut.authState = .authenticated(token)
            spyInteractor.shouldThrowError = true
            spyInteractor.errorToThrow = NetworkError.unauthorized
            // When
            await sut.fetchCloudCollection()
            // Then
            #expect(spyInteractor.getCloudCollectionWasCalled)
            #expect(sut.authState == .unauthenticated)
            #expect(sut.showSessionExpiredAlert == true)
        }

        @Test("Fetch cloud collection when not authenticated clears data")
        func fetchCloudCollectionNotAuthenticated() async {
            // Given
            sut.authState = .unauthenticated
            sut.cloudMangaCount = 5
            sut.cloudMangaIds = [1, 2, 3]
            // When
            await sut.fetchCloudCollection()
            // Then
            #expect(!spyInteractor.getCloudCollectionWasCalled)
            #expect(sut.cloudMangaCount == 0)
            #expect(sut.cloudMangaIds.isEmpty)
        }

        // MARK: - Update Manga Tests

        @Test("Update manga in collection with cloud sync")
        func updateMangaWithCloudSync() async throws {
            // Given
            let token = AuthToken(token: "valid_token")
            sut.authState = .authenticated(token)
            sut.cloudMangaIds = [1]
            let mockCollectionViewModel = MockCollectionViewModel.empty
            sut.setCollectionViewModel(mockCollectionViewModel)
            // When
            try await sut.updateMangaInCollection(Self.mockCollectionManga)
            // Then
            #expect(spyInteractor.addToCloudCollectionWasCalled)
            #expect(spyInteractor.lastAddToCloudManga?.manga == 1)
        }

        @Test("Update manga without collection view model throws error")
        func updateMangaNoCollectionViewModel() async {
            // Given
            sut.authState = .authenticated(AuthToken(token: "token"))
            // When/Then
            do {
                try await sut.updateMangaInCollection(Self.mockCollectionManga)
                Issue.record("Expected error to be thrown")
            } catch {
                #expect(sut.errorMessage != nil)
            }
        }

        @Test("Update manga not in cloud skips cloud sync")
        func updateMangaNotInCloud() async throws {
            // Given
            let token = AuthToken(token: "valid_token")
            sut.authState = .authenticated(token)
            sut.cloudMangaIds = [99]
            let mockCollectionViewModel = MockCollectionViewModel.empty
            sut.setCollectionViewModel(mockCollectionViewModel)
            // When
            try await sut.updateMangaInCollection(Self.mockCollectionManga)
            // Then
            #expect(!spyInteractor.addToCloudCollectionWasCalled)
        }

        // MARK: - Delete Manga Tests

        @Test("Delete manga from collection with cloud sync")
        func deleteMangaWithCloudSync() async throws {
            // Given
            let token = AuthToken(token: "valid_token")
            sut.authState = .authenticated(token)
            sut.cloudMangaIds = [1]
            sut.cloudMangaCount = 1
            let mockCollectionViewModel = MockCollectionViewModel.empty
            sut.setCollectionViewModel(mockCollectionViewModel)
            // When
            try await sut.deleteMangaFromCollection(Self.mockCollectionManga)
            // Then
            #expect(spyInteractor.deleteFromCloudCollectionWasCalled)
            #expect(spyInteractor.lastDeleteFromCloudMangaId == 1)
            #expect(sut.cloudMangaCount == 0)
            #expect(!sut.cloudMangaIds.contains(1))
        }

        @Test("Delete manga without collection view model throws error")
        func deleteMangaNoCollectionViewModel() async {
            // Given
            sut.authState = .authenticated(AuthToken(token: "token"))
            // When/Then
            do {
                try await sut.deleteMangaFromCollection(Self.mockCollectionManga)
                Issue.record("Expected error to be thrown")
            } catch {
                #expect(sut.errorMessage != nil)
            }
        }

        @Test("Delete manga not in cloud skips cloud sync")
        func deleteMangaNotInCloud() async throws {
            // Given
            let token = AuthToken(token: "valid_token")
            sut.authState = .authenticated(token)
            sut.cloudMangaIds = [99]
            sut.cloudMangaCount = 1
            let mockCollectionViewModel = MockCollectionViewModel.empty
            sut.setCollectionViewModel(mockCollectionViewModel)
            // When
            try await sut.deleteMangaFromCollection(Self.mockCollectionManga)
            // Then
            #expect(!spyInteractor.deleteFromCloudCollectionWasCalled)
        }

        @Test(
            "Cloud operations handle unauthorized error",
            arguments: [
                .update,
                .delete
            ] as [CloudOperation]
        )
        func cloudOperationUnauthorized(operation: CloudOperation) async throws {
            // Given
            let token = AuthToken(token: "invalid_token")
            sut.authState = .authenticated(token)
            sut.cloudMangaIds = [1]
            if operation == .delete {
                sut.cloudMangaCount = 1
            }
            let mockCollectionViewModel = MockCollectionViewModel.empty
            sut.setCollectionViewModel(mockCollectionViewModel)
            spyInteractor.shouldThrowError = true
            spyInteractor.errorToThrow = NetworkError.unauthorized

            do {
                // When
                switch operation {
                case .update:
                    try await sut.updateMangaInCollection(Self.mockCollectionManga)
                case .delete:
                    try await sut.deleteMangaFromCollection(Self.mockCollectionManga)
                }
                // Then
                Issue.record("Expected error to be thrown")
            } catch {
                #expect(sut.authState == .unauthenticated)
                #expect(sut.showSessionExpiredAlert == true)
            }
        }

        // MARK: - Sync To Cloud Tests

        @Test("Sync to cloud when not authenticated shows error")
        func syncToCloudNotAuthenticated() async {
            // Given
            sut.authState = .unauthenticated
            let mockCollectionViewModel = MockCollectionViewModel.empty
            sut.setCollectionViewModel(mockCollectionViewModel)
            // When
            await sut.syncToCloud()
            // Then
            #expect(sut.errorMessage != nil)
            #expect(!sut.isSyncing)
        }

        @Test("Sync to cloud without collection view model shows error")
        func syncToCloudNoCollectionViewModel() async {
            // Given
            sut.authState = .authenticated(AuthToken(token: "token"))
            // When
            await sut.syncToCloud()
            // Then
            #expect(sut.errorMessage != nil)
            #expect(!sut.isSyncing)
        }

        @Test("Sync to cloud when all synced shows message")
        func syncToCloudAllSynced() async {
            // Given
            let token = AuthToken(token: "valid_token")
            sut.authState = .authenticated(token)
            let mockCollectionViewModel = MockCollectionViewModel.empty
            sut.setCollectionViewModel(mockCollectionViewModel)
            spyInteractor.dataToReturn = []
            // When
            await sut.syncToCloud()
            // Then
            #expect(spyInteractor.getCloudCollectionWasCalled)
            #expect(!sut.isSyncing)
        }

        @Test("Sync to cloud handles unauthorized error")
        func syncToCloudUnauthorized() async {
            // Given
            let token = AuthToken(token: "invalid_token")
            sut.authState = .authenticated(token)
            let mockCollectionViewModel = MockCollectionViewModel.empty
            sut.setCollectionViewModel(mockCollectionViewModel)
            spyInteractor.shouldThrowError = true
            spyInteractor.errorToThrow = NetworkError.unauthorized
            // When
            await sut.syncToCloud()
            // Then
            #expect(sut.authState == .unauthenticated)
            #expect(sut.showSessionExpiredAlert == true)
            #expect(!sut.isSyncing)
        }

        @Test("Sync to cloud uploads local mangas successfully")
        func syncToCloudUploadsMangas() async {
            // Given
            let token = AuthToken(token: "valid_token")
            sut.authState = .authenticated(token)
            sut.setCollectionViewModel(Self.mockCollectionViewModel)
            spyInteractor.dataToReturn = []
            // When
            await sut.syncToCloud()
            // Then
            #expect(spyInteractor.getCloudCollectionWasCalled)
            #expect(spyInteractor.addToCloudCollectionWasCalled)
            #expect(!sut.isSyncing)
        }

        @Test("Sync to cloud skips mangas already in cloud")
        func syncToCloudSkipsExistingMangas() async {
            // Given
            let token = AuthToken(token: "valid_token")
            sut.authState = .authenticated(token)
            sut.setCollectionViewModel(Self.mockCollectionViewModel)
            spyInteractor.dataToReturn = [Self.mockCloudManga]
            // When
            await sut.syncToCloud()
            // Then
            #expect(spyInteractor.getCloudCollectionWasCalled)
            #expect(!spyInteractor.addToCloudCollectionWasCalled)
            #expect(!sut.isSyncing)
        }

        // MARK: - Full Sync Tests

        @Test("Full sync calls sync to cloud and download cloud to local")
        func fullSyncExecutesBothOperations() async {
            // Given
            let token = AuthToken(token: "valid_token")
            sut.authState = .authenticated(token)
            let mockCollectionViewModel = MockCollectionViewModel.empty
            sut.setCollectionViewModel(mockCollectionViewModel)
            spyInteractor.dataToReturn = []
            // When
            await sut.fullSync()
            // Then
            #expect(spyInteractor.getCloudCollectionWasCalled)
            #expect(!sut.isSyncing)
        }

        // MARK: - Download Cloud To Local Tests

        @Test("Download cloud to local when not authenticated skips download")
        func downloadCloudToLocalNotAuthenticated() async {
            // Given
            sut.authState = .unauthenticated
            let mockCollectionViewModel = MockCollectionViewModel.empty
            sut.setCollectionViewModel(mockCollectionViewModel)
            // When
            await sut.downloadCloudToLocal()
            // Then
            #expect(!spyInteractor.getCloudCollectionWasCalled)
        }

        @Test("Download cloud to local without collection view model skips download")
        func downloadCloudToLocalNoCollectionViewModel() async {
            // Given
            sut.authState = .authenticated(AuthToken(token: "token"))
            // When
            await sut.downloadCloudToLocal()
            // Then
            #expect(!spyInteractor.getCloudCollectionWasCalled)
        }

        @Test("Download cloud to local successfully downloads mangas")
        func downloadCloudToLocalSuccess() async {
            // Given
            let token = AuthToken(token: "valid_token")
            sut.authState = .authenticated(token)
            let mockCollectionViewModel = MockCollectionViewModel.empty
            sut.setCollectionViewModel(mockCollectionViewModel)
            spyInteractor.dataToReturn = [Self.mockCloudManga]
            // When
            await sut.downloadCloudToLocal()
            // Then
            #expect(spyInteractor.getCloudCollectionWasCalled)
            #expect(spyInteractor.lastGetCloudCollectionToken?.token == token.token)
        }

        @Test("Download cloud to local handles unauthorized error")
        func downloadCloudToLocalUnauthorized() async {
            // Given
            let token = AuthToken(token: "invalid_token")
            sut.authState = .authenticated(token)
            let mockCollectionViewModel = MockCollectionViewModel.empty
            sut.setCollectionViewModel(mockCollectionViewModel)
            spyInteractor.shouldThrowError = true
            spyInteractor.errorToThrow = NetworkError.unauthorized
            // When
            await sut.downloadCloudToLocal()
            // Then
            #expect(sut.authState == .unauthenticated)
            #expect(sut.showSessionExpiredAlert == true)
        }

        @Test("Download cloud to local handles generic error")
        func downloadCloudToLocalGenericError() async {
            // Given
            let token = AuthToken(token: "valid_token")
            sut.authState = .authenticated(token)
            let mockCollectionViewModel = MockCollectionViewModel.empty
            sut.setCollectionViewModel(mockCollectionViewModel)
            spyInteractor.shouldThrowError = true
            spyInteractor.errorToThrow = NetworkError.unknown(0)
            // When
            await sut.downloadCloudToLocal()
            // Then
            #expect(sut.errorMessage != nil)
            #expect(sut.authState != .unauthenticated)
        }

        // MARK: - Error Handling Tests

        @Test("Clear error message resets error")
        func clearErrorMessage() {
            // Given
            sut.errorMessage = "Some error"
            // When
            sut.clearError()
            // Then
            #expect(sut.errorMessage == nil)
        }

        @Test(
            "Handle different network errors",
            arguments: [
                .init(error: .validationError, expectedContains: L10n.Error.generic),
                .init(error: .badRequest, expectedContains: L10n.Error.generic),
                .init(error: .notFound, expectedContains: L10n.Authentication.Error.invalidCredentials),
                .init(error: .unauthorized, expectedContains: L10n.Authentication.Error.invalidCredentials),
                .init(error: .invalidResponse, expectedContains: L10n.Error.generic)
            ] as [HandleErrorArgument]
        )
        func handleNetworkErrors(argument: HandleErrorArgument) async {
            // Given
            sut.email = "test@inku.com"
            sut.password = "password123"
            spyInteractor.shouldThrowError = true
            spyInteractor.errorToThrow = argument.error
            // When
            await sut.login()
            // Then
            #expect(sut.errorMessage != nil)
            #expect(sut.errorMessage?.localizedCaseInsensitiveContains(argument.expectedContains) == true)
            #expect(!sut.isAuthenticated)
        }

        @Test(
            "Handle URL errors",
            arguments: [
                .timedOut,
                .cannotFindHost,
                .badServerResponse
            ] as [URLError.Code]
        )
        func handleURLErrors(errorCode: URLError.Code) async {
            // Given
            sut.email = "test@inku.com"
            sut.password = "password123"
            spyInteractor.shouldThrowError = true
            spyInteractor.errorToThrow = URLError(errorCode)
            // When
            await sut.login()
            // Then
            #expect(sut.errorMessage != nil)
            #expect(!sut.isAuthenticated)
        }

        @Test("Handle cancelled error does not set error message")
        func handleCancelledError() async {
            // Given
            sut.email = "test@inku.com"
            sut.password = "password123"
            sut.errorMessage = nil
            spyInteractor.shouldThrowError = true
            spyInteractor.errorToThrow = URLError(.cancelled)
            // When
            await sut.login()
            // Then
            #expect(sut.errorMessage == nil)
            #expect(!sut.isAuthenticated)
        }

        @Test("Handle keychain error shows generic message")
        func handleKeychainError() async {
            // Given
            sut.email = "test@inku.com"
            sut.password = "password123"
            spyInteractor.shouldThrowError = true
            spyInteractor.errorToThrow = KeychainError.encodingError
            // When
            await sut.login()
            // Then
            #expect(sut.errorMessage != nil)
            #expect(!sut.isAuthenticated)
        }

        // MARK: - Form Management Tests

        @Test("Clear form resets all fields")
        func clearForm() {
            // Given
            sut.email = "test@inku.com"
            sut.password = "password123"
            sut.errorMessage = "Some error"
            sut.cloudMangaIds = [1, 2, 3]
            // When
            sut.clearForm()
            // Then
            #expect(sut.email == "")
            #expect(sut.password == "")
            #expect(sut.errorMessage == nil)
            #expect(sut.cloudMangaIds.isEmpty)
        }

        @Test("Clear password only resets password")
        func clearPassword() {
            // Given
            sut.email = "test@inku.com"
            sut.password = "password123"
            // When
            sut.clearPassword()
            // Then
            #expect(sut.email == "test@inku.com")
            #expect(sut.password == "")
        }

        @Test("Form validation with valid data")
        func formValidationValid() {
            // Given
            sut.email = "test@inku.com"
            sut.password = "password123"
            // Then
            #expect(sut.isFormValid == true)
        }

        @Test("Form validation with invalid email")
        func formValidationInvalidEmail() {
            // Given
            sut.email = "invalid-email"
            sut.password = "password123"

            // Then
            #expect(sut.isFormValid == false)
        }

        @Test("Form validation with short password")
        func formValidationShortPassword() {
            // Given
            sut.email = "test@inku.com"
            sut.password = "12345"
            // Then
            #expect(sut.isFormValid == false)
        }
    }
}
// MARK: - Test Data

extension AuthenticationTests.ViewModelTests {

    enum CloudOperation: String, CustomTestStringConvertible {
        case update
        case delete

        var testDescription: String {
            rawValue
        }
    }

    struct HandleErrorArgument: CustomTestStringConvertible {
        let error: NetworkError
        let expectedContains: String

        var testDescription: String {
            "\(String(describing: error)) → expects '\(expectedContains)'"
        }
    }
}

private extension AuthenticationTests.ViewModelTests {

    static let mockCollectionManga = CollectionManga(
        mangaId: 1,
        title: "Test Manga",
        coverImageURL: nil,
        totalVolumes: 10,
        volumesOwnedCount: 5,
        currentReadingVolume: 5,
        hasCompleteCollection: false
    )

    static let mockCollectionViewModel = MockCollectionViewModel(
        mangas: [mockCollectionManga]
    )

    static let mockCloudManga = CloudCollectionManga(
        id: "123",
        manga: .testData,
        user: .init(id: "user_123"),
        completeCollection: false,
        volumesOwned: [1, 2, 3],
        readingVolume: 3
    )
}
