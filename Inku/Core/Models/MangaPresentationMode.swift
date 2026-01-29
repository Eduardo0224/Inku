//
//  MangaPresentationMode.swift
//  Inku
//
//  Created by Eduardo Andrade on 28/01/26.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2026 Eduardo Andrade. All rights reserved.
//

import Foundation

enum MangaPresentationMode: String, CaseIterable, Identifiable, Sendable {
    case list
    case grid

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .list:
            "list.bullet"
        case .grid:
            "square.grid.2x2"
        }
    }
}
