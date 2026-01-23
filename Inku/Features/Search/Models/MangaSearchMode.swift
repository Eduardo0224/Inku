//
//  MangaSearchMode.swift
//  Inku
//
//  Created by Eduardo Andrade on 05/01/26.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2026 Eduardo Andrade. All rights reserved.
//

import Foundation

enum MangaSearchMode: String, CaseIterable, Identifiable {
    case contains
    case beginsWith

    var id: String { rawValue }

    var displayText: String {
        switch self {
        case .contains:
            L10n.Search.Mode.contains
        case .beginsWith:
            L10n.Search.Mode.beginsWith
        }
    }
}
