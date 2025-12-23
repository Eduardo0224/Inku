//
//  Genre.swift
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

struct Genre: Identifiable, Codable, Hashable, Sendable {

    // MARK: - Properties

    let id: String
    let genre: String
}

// MARK: - Test Data

extension Genre {

    static let testData: Self = .init(
        id: "",
        genre: ""
    )
}
