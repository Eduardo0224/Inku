//
//  PaginationMetadata.swift
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

struct PaginationMetadata: Codable, Hashable, Sendable {

    // MARK: - Properties

    let total: Int
    let page: Int
    let per: Int

    // MARK: - Computed Properties

    var totalPages: Int {
        guard per > 0 else { return 0 }
        return (total + per - 1) / per
    }

    var hasMorePages: Bool {
        page < totalPages
    }
}
