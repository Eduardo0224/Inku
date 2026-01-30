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
final class AuthViewModel: AuthViewModelProtocol {

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
            handleError(error)
        }
    }

    func register() async {
        guard isFormValid else {
            errorMessage = L10n.Error.generic
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
            handleError(error, isRegistration: true)
        }
    }

    func login() async {
        guard isFormValid else {
            errorMessage = L10n.Error.generic
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
            handleError(error)
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
            handleError(error)
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
                handleError(error)
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

    // MARK: - Private Functions

    private func handleError(_ error: Error, isRegistration: Bool = false) {
        if let networkError = error as? NetworkError {
            print("[AuthViewModel] NetworkError: \(networkError)")

            switch networkError {
            case .badRequest:
                if isRegistration {
                    errorMessage = L10n.Authentication.Error.userExists
                } else {
                    errorMessage = L10n.Error.generic
                }
            case .unauthorized:
                errorMessage = L10n.Authentication.Error.invalidCredentials
            case .notFound:
                errorMessage = L10n.Authentication.Error.invalidCredentials
            case .validationError:
                errorMessage = L10n.Error.generic
            default:
                errorMessage = L10n.Error.generic
            }
        } else if let urlError = error as? URLError {
            print("[AuthViewModel] URLError: \(urlError.code)")

            switch urlError.code {
            case .notConnectedToInternet:
                errorMessage = L10n.Error.network
            case .timedOut:
                errorMessage = L10n.Error.timeout
            case .cancelled:
                return
            default:
                errorMessage = L10n.Error.generic
            }
        } else if let keychainError = error as? KeychainError {
            print("[AuthViewModel] KeychainError: \(keychainError)")
            errorMessage = L10n.Error.generic
        } else {
            print("[AuthViewModel] Unknown error: \(error)")
            errorMessage = L10n.Error.generic
        }
    }
}
