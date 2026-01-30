//
//  EmptyAuthViewModel.swift
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

/// Default empty implementation for EnvironmentKey
/// This is a non-isolated placeholder that should never be used in production
final class EmptyAuthViewModel: AuthViewModelProtocol {

    var authState: AuthState = .unauthenticated
    var isLoading: Bool = false
    var errorMessage: String?
    var email: String = ""
    var password: String = ""
    var savedEmail: String?
    var isFormValid: Bool { false }
    var isAuthenticated: Bool { false }

    func checkAuthenticationStatus() async {
        // No-op: EmptyAuthViewModel is a placeholder
    }

    func register() async {
        fatalError("AuthViewModel not provided in environment")
    }

    func login() async {
        fatalError("AuthViewModel not provided in environment")
    }

    func logout() async {
        fatalError("AuthViewModel not provided in environment")
    }

    func renewTokenIfNeeded() async {
        // No-op: EmptyAuthViewModel is a placeholder
    }

    func clearForm() {
        // No-op: EmptyAuthViewModel is a placeholder
    }

    func clearPassword() {
        // No-op: EmptyAuthViewModel is a placeholder
    }

    func clearError() {
        // No-op: EmptyAuthViewModel is a placeholder
    }
}
