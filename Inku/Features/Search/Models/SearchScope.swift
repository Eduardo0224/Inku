//
//  SearchScope.swift
//  Inku
//
//  Created by Eduardo Andrade on 02/01/26.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2026 Eduardo Andrade. All rights reserved.
//

import Foundation

enum SearchScope: String, CaseIterable, Identifiable {
    case title
    case author

    var id: String { rawValue }

    var displayText: String {
        switch self {
        case .title:
            L10n.Search.Scope.title
        case .author:
            L10n.Search.Scope.author
        }
    }
}
