//
//  AuthInteractorProtocol.swift
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

protocol AuthInteractorProtocol: Sendable {
    func register(user: User) async throws
    func login(user: User) async throws -> AuthToken
    func renewToken(_ token: AuthToken) async throws -> AuthToken
    func logout() async throws
    func getSavedToken() async throws -> AuthToken?
    func getSavedEmail() async throws -> String?
    func getCloudCollection(token: AuthToken) async throws -> [CloudCollectionManga]
}
