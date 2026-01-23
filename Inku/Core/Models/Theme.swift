//
//  Theme.swift
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

struct Theme: Identifiable, Codable, Hashable, Sendable {

    // MARK: - Properties

    let id: String
    let theme: String
}

// MARK: - Test Data

extension Theme {

    static let emptyData: Self = .init(
        id: "",
        theme: ""
    )

    static let testData: Self = .init(
        id: "82728A80-0DBE-4B64-A295-A25555A4A4A5",
        theme: "Gore"
    )
}
