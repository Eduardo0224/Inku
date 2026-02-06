//
//  User.swift
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

struct User: Codable, Sendable {

    // MARK: - Properties

    let email: String
    let password: String

    // MARK: - Computed Properties

    var isEmailValid: Bool {
        let emailRegex = /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/
        return email.wholeMatch(of: emailRegex) != nil
    }

    var isPasswordValid: Bool {
        password.count >= 8
    }

    var isValid: Bool {
        isEmailValid && isPasswordValid
    }

    var basicAuthCredentials: String {
        let credentials = "\(email):\(password)"
        guard let data = credentials.data(using: .utf8) else { return "" }
        return "Basic \(data.base64EncodedString())"
    }
}
