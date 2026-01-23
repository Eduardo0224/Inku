//
//  CollectionSortOption.swift
//  Inku
//
//  Created by Eduardo Andrade on 08/01/26.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2026 Eduardo Andrade. All rights reserved.
//

import Foundation

enum CollectionSortOption: String, CaseIterable, Identifiable {

    // MARK: - Cases

    case dateAdded
    case title
    case progress

    // MARK: - Properties

    var id: String { rawValue }

    var displayText: String {
        switch self {
        case .dateAdded:
            return L10n.Collection.Sort.dateAdded
        case .title:
            return L10n.Collection.Sort.title
        case .progress:
            return L10n.Collection.Sort.progress
        }
    }

    var icon: String {
        switch self {
        case .dateAdded:
            return "calendar"
        case .title:
            return "textformat"
        case .progress:
            return "chart.bar.fill"
        }
    }
}
