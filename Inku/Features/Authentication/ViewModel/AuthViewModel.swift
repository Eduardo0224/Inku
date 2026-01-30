//
//  AuthViewModel.swift
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
import Observation

@Observable
@MainActor
final class AuthViewModel {

    // MARK: - Private Properties

    @ObservationIgnored
    private let interactor: AuthInteractorProtocol

    // MARK: - Properties

    var authState: AuthState = .unauthenticated
    var isLoading = false
    var errorMessage: String?

    var email = ""
    var password = ""
    var savedEmail: String?

    // MARK: - Computed Properties

    var isFormValid: Bool {
        let user = User(email: email, password: password)
        return user.isValid
    }

    var isAuthenticated: Bool {
        authState.isAuthenticated
    }

    // MARK: - Initializers

    init(interactor: AuthInteractorProtocol = AuthInteractor()) {
        self.interactor = interactor
    }

    // MARK: - Functions

    func checkAuthenticationStatus() async {
        do {
            if let token = try await interactor.getSavedToken() {
                if token.isExpired {
                    let newToken = try await interactor.renewToken(token)
                    authState = .authenticated(newToken)
                } else {
                    authState = .authenticated(token)
                }
            } else {
                authState = .unauthenticated
            }

            savedEmail = try await interactor.getSavedEmail()
            if let savedEmail {
                email = savedEmail
            }
        } catch {
            authState = .unauthenticated
            errorMessage = error.localizedDescription
        }
    }

    func register() async {
        guard isFormValid else {
            errorMessage = "Invalid email or password"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let user = User(email: email, password: password)
            try await interactor.register(user: user)

            await login()
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }

    func login() async {
        guard isFormValid else {
            errorMessage = "Invalid email or password"
            return
        }

        isLoading = true
        errorMessage = nil
        authState = .loading

        do {
            let user = User(email: email, password: password)
            let token = try await interactor.login(user: user)
            authState = .authenticated(token)
            savedEmail = email
            isLoading = false
            clearPassword()
        } catch {
            isLoading = false
            authState = .unauthenticated
            errorMessage = error.localizedDescription
        }
    }

    func logout() async {
        isLoading = true
        errorMessage = nil

        do {
            try await interactor.logout()
            authState = .unauthenticated
            clearForm()
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }

    func renewTokenIfNeeded() async {
        guard case .authenticated(let token) = authState else { return }

        if token.isExpired {
            do {
                let newToken = try await interactor.renewToken(token)
                authState = .authenticated(newToken)
            } catch {
                authState = .unauthenticated
                errorMessage = error.localizedDescription
            }
        }
    }

    func clearForm() {
        email = ""
        password = ""
        errorMessage = nil
    }

    func clearPassword() {
        password = ""
    }

    func clearError() {
        errorMessage = nil
    }
}
