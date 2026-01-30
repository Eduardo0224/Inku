//
//  AuthViewModelProtocol.swift
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

@MainActor
protocol AuthViewModelProtocol {

    var authState: AuthState { get }
    var isLoading: Bool { get }
    var errorMessage: String? { get }
    var email: String { get set }
    var password: String { get set }
    var savedEmail: String? { get }
    var isFormValid: Bool { get }
    var isAuthenticated: Bool { get }

    func checkAuthenticationStatus() async
    func register() async
    func login() async
    func logout() async
    func renewTokenIfNeeded() async
    func clearForm()
    func clearPassword()
    func clearError()
}
