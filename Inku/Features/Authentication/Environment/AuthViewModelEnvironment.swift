//
//  AuthViewModelEnvironment.swift
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

import SwiftUI

// MARK: - AuthViewModelKey

private struct AuthViewModelKey: EnvironmentKey {
    nonisolated(unsafe) static let defaultValue = AuthViewModel()
}

// MARK: - EnvironmentValues Extension

extension EnvironmentValues {
    var authViewModel: AuthViewModel {
        get { self[AuthViewModelKey.self] }
        set { self[AuthViewModelKey.self] = newValue }
    }
}
