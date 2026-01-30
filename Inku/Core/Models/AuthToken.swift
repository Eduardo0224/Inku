//
//  AuthToken.swift
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

struct AuthToken: Codable, Sendable {

    // MARK: - Properties

    let token: String
    let expirationDate: Date

    // MARK: - Computed Properties

    var isExpired: Bool {
        Date.now > expirationDate
    }

    var bearerToken: String {
        "Bearer \(token)"
    }

    var daysUntilExpiration: Int {
        Calendar.current.dateComponents([.day], from: .now, to: expirationDate).day ?? 0
    }
}

// MARK: - Initializers

extension AuthToken {

    init(token: String) {
        self.token = token
        self.expirationDate = Calendar.current.date(byAdding: .day, value: 2, to: .now) ?? .now
    }
}
