//
//  AuthState.swift
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

enum AuthState: Sendable {
    case unauthenticated
    case authenticated(AuthToken)
    case loading

    // MARK: - Computed Properties

    var isAuthenticated: Bool {
        if case .authenticated = self {
            return true
        }
        return false
    }

    var token: AuthToken? {
        if case .authenticated(let token) = self {
            return token
        }
        return nil
    }

    var isLoading: Bool {
        if case .loading = self {
            return true
        }
        return false
    }
}
