//
//  View+SectionIndex.swift
//  Inku
//
//  Created by Eduardo Andrade on 04/01/26.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2026 Eduardo Andrade. All rights reserved.
//

import SwiftUI

// MARK: - View Extension

extension View {
    func sectionIndexWith(label: String) -> some View {
        modifier(SectionIndexModifier(label: label))
    }
}

// MARK: - View Modifier

/// ViewModifier to apply sectionIndexLabel only on iOS 26+
private struct SectionIndexModifier: ViewModifier {
    let label: String

    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content.sectionIndexLabel(label)
        } else {
            content
        }
    }
}
