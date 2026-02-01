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

    func register(user: User) async throws { }

    func login(user: User) async throws -> AuthToken {
        .init(token: "mock_token_12345")
    }

    func renewToken(_ token: AuthToken) async throws -> AuthToken {
        .init(token: "mock_renewed_token_67890")
    }

    func logout() async throws { }

    func getSavedToken() async throws -> AuthToken? {
        nil
    }

    func getSavedEmail() async throws -> String? {
        nil
    }

    func getCloudCollection(token: AuthToken) async throws -> [CloudCollectionManga] {
        [
            CloudCollectionManga(
                id: "457DC69D-8942-4332-877D-ED6EE8B0614E",
                manga: .testData,
                user: CloudCollectionManga.UserInfo(id: "A912D794-D98B-4127-8F55-927E3BCA6AAF"),
                completeCollection: false,
                volumesOwned: [1, 2, 3],
                readingVolume: 2
            ),
            CloudCollectionManga(
                id: "8A3F2C1E-9D4B-4A5C-8E7F-1B2C3D4E5F6A",
                manga: .testData,
                user: CloudCollectionManga.UserInfo(id: "A912D794-D98B-4127-8F55-927E3BCA6AAF"),
                completeCollection: true,
                volumesOwned: [1, 2, 3, 4, 5],
                readingVolume: 5
            ),
            CloudCollectionManga(
                id: "B1C2D3E4-F5A6-4B7C-8D9E-0F1A2B3C4D5E",
                manga: .testData,
                user: CloudCollectionManga.UserInfo(id: "A912D794-D98B-4127-8F55-927E3BCA6AAF"),
                completeCollection: false,
                volumesOwned: [1],
                readingVolume: 1
            )
        ]
    }

    func addToCloudCollection(token: AuthToken, manga: CreateCollectionMangaRequest) async throws {
        // Mock: API returns 201 Created with empty body
    }
}
