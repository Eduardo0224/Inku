//
//  KeychainServiceProtocol.swift
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

protocol KeychainServiceProtocol: Sendable {
    func save(token: AuthToken) throws
    func getToken() throws -> AuthToken?
    func deleteToken() throws
    func save(email: String) throws
    func getEmail() throws -> String?
    func deleteEmail() throws
    func deleteAll() throws
}
