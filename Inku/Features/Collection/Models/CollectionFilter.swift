//
//  CollectionFilter.swift
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

enum CollectionFilter: CaseIterable, Identifiable {

    // MARK: - Cases

    case all
    case reading
    case complete
    case incomplete

    // MARK: - Properties

    var id: Self { self }

    var displayText: String {
        switch self {
        case .all:
            return L10n.Collection.Filter.all
        case .reading:
            return L10n.Collection.Filter.reading
        case .complete:
            return L10n.Collection.Filter.complete
        case .incomplete:
            return L10n.Collection.Filter.incomplete
        }
    }

    var icon: String {
        switch self {
        case .all:
            return "books.vertical"
        case .reading:
            return "book.pages"
        case .complete:
            return "checkmark.circle.fill"
        case .incomplete:
            return "circle.dotted"
        }
    }
}
