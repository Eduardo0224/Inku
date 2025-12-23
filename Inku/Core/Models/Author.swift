//
//  Author.swift
//  Inku
//
//  Created by Eduardo Andrade on 22/12/25.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2025 Eduardo Andrade. All rights reserved.
//

import Foundation

struct Author: Identifiable, Codable, Hashable, Sendable {

    // MARK: - Properties

    let id: String
    let firstName: String
    let lastName: String
    let role: String

    // MARK: - Computed Properties

    var fullName: String {
        "\(firstName) \(lastName)"
    }
}
