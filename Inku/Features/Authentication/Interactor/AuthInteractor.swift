//
//  AuthInteractor.swift
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

final class AuthInteractor: AuthInteractorProtocol, Sendable {

    // MARK: - Private Properties

    private let networkService: NetworkServiceProtocol
    private let keychainService: KeychainServiceProtocol

    // MARK: - Initializers

    init(
        networkService: NetworkServiceProtocol = NetworkService(),
        keychainService: KeychainServiceProtocol = KeychainService()
    ) {
        self.networkService = networkService
        self.keychainService = keychainService
    }

    // MARK: - Functions

    func register(user: User) async throws {
        let headers = ["App-Token": API.Constants.appToken]

        try await networkService.post(
            endpoint: API.Endpoints.registerUser,
            body: user,
            headers: headers
        )
    }

    func login(user: User) async throws -> AuthToken {
        let headers = ["Authorization": user.basicAuthCredentials]

        let response: TokenResponse = try await networkService.post(
            endpoint: API.Endpoints.loginUser,
            headers: headers
        )

        let authToken = AuthToken(token: response.token)

        try keychainService.save(token: authToken)
        try keychainService.save(email: user.email)

        return authToken
    }

    func renewToken(_ token: AuthToken) async throws -> AuthToken {
        let headers = ["Authorization": token.bearerToken]

        let response: TokenResponse = try await networkService.post(
            endpoint: API.Endpoints.renewToken,
            headers: headers
        )

        let newToken = AuthToken(token: response.token)
        try keychainService.save(token: newToken)

        return newToken
    }

    func logout() async throws {
        try keychainService.deleteAll()
    }

    func getSavedToken() async throws -> AuthToken? {
        try keychainService.getToken()
    }

    func getSavedEmail() async throws -> String? {
        try keychainService.getEmail()
    }

    func getCloudCollection(token: AuthToken) async throws -> [CloudCollectionManga] {
        let headers = ["Authorization": token.bearerToken]

        let collection: [CloudCollectionManga] = try await networkService.get(
            endpoint: API.Endpoints.collectionManga,
            headers: headers
        )

        return collection
    }

    func addToCloudCollection(token: AuthToken, manga: CreateCollectionMangaRequest) async throws {
        let headers = ["Authorization": token.bearerToken]

        try await networkService.post(
            endpoint: API.Endpoints.collectionManga,
            body: manga,
            headers: headers
        )
    }

    func deleteFromCloudCollection(token: AuthToken, mangaId: Int) async throws {
        let headers = ["Authorization": token.bearerToken]

        try await networkService.delete(
            endpoint: API.Endpoints.collectionManga(id: mangaId),
            headers: headers
        )
    }
}
