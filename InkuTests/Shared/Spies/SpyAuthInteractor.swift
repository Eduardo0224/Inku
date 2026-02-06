//
//  SpyAuthInteractor.swift
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

final class SpyAuthInteractor: AuthInteractorProtocol, @unchecked Sendable {

    // MARK: - Properties (Spy Tracking)

    private(set) var registerWasCalled = false
    private(set) var loginWasCalled = false
    private(set) var renewTokenWasCalled = false
    private(set) var logoutWasCalled = false
    private(set) var getSavedTokenWasCalled = false
    private(set) var getSavedEmailWasCalled = false
    private(set) var getCloudCollectionWasCalled = false
    private(set) var addToCloudCollectionWasCalled = false
    private(set) var deleteFromCloudCollectionWasCalled = false

    private(set) var lastRegisterUser: User?
    private(set) var lastLoginUser: User?
    private(set) var lastRenewToken: AuthToken?
    private(set) var lastGetCloudCollectionToken: AuthToken?
    private(set) var lastAddToCloudToken: AuthToken?
    private(set) var lastAddToCloudManga: CreateCollectionMangaRequest?
    private(set) var lastDeleteFromCloudToken: AuthToken?
    private(set) var lastDeleteFromCloudMangaId: Int?

    // MARK: - Properties (Stub Data)

    var dataToReturn: Any?
    var shouldThrowError = false
    var errorToThrow: Error = NetworkError.unknown(0)

    // MARK: - AuthInteractorProtocol

    func register(user: User) async throws {
        registerWasCalled = true
        lastRegisterUser = user

        if shouldThrowError {
            throw errorToThrow
        }
    }

    func login(user: User) async throws -> AuthToken {
        loginWasCalled = true
        lastLoginUser = user

        if shouldThrowError {
            throw errorToThrow
        }

        guard let token = dataToReturn as? AuthToken else {
            throw NetworkError.invalidResponse
        }

        return token
    }

    func renewToken(_ token: AuthToken) async throws -> AuthToken {
        renewTokenWasCalled = true
        lastRenewToken = token

        if shouldThrowError {
            throw errorToThrow
        }

        guard let newToken = dataToReturn as? AuthToken else {
            throw NetworkError.invalidResponse
        }

        return newToken
    }

    func logout() async throws {
        logoutWasCalled = true

        if shouldThrowError {
            throw errorToThrow
        }
    }

    func getSavedToken() async throws -> AuthToken? {
        getSavedTokenWasCalled = true

        if shouldThrowError {
            throw errorToThrow
        }

        return dataToReturn as? AuthToken
    }

    func getSavedEmail() async throws -> String? {
        getSavedEmailWasCalled = true

        if shouldThrowError {
            throw errorToThrow
        }

        return dataToReturn as? String
    }

    func getCloudCollection(token: AuthToken) async throws -> [CloudCollectionManga] {
        getCloudCollectionWasCalled = true
        lastGetCloudCollectionToken = token

        if shouldThrowError {
            throw errorToThrow
        }

        guard let collection = dataToReturn as? [CloudCollectionManga] else {
            throw NetworkError.invalidResponse
        }

        return collection
    }

    func addToCloudCollection(token: AuthToken, manga: CreateCollectionMangaRequest) async throws {
        addToCloudCollectionWasCalled = true
        lastAddToCloudToken = token
        lastAddToCloudManga = manga

        if shouldThrowError {
            throw errorToThrow
        }
    }

    func deleteFromCloudCollection(token: AuthToken, mangaId: Int) async throws {
        deleteFromCloudCollectionWasCalled = true
        lastDeleteFromCloudToken = token
        lastDeleteFromCloudMangaId = mangaId

        if shouldThrowError {
            throw errorToThrow
        }
    }
}
