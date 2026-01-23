//
//  MangaFilter.swift
//  Inku
//
//  Created by Eduardo Andrade on 24/12/25.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2025 Eduardo Andrade. All rights reserved.
//

import Foundation

enum MangaFilter: Sendable, Equatable {
    case genre(String)
    case demographic(String)
    case theme(String)
    case none

    func matches(with inputValue: String) -> Bool {
        switch self {
        case .genre(let value), .demographic(let value), .theme(let value):
            value == inputValue
        case .none:
            false
        }
    }
}
