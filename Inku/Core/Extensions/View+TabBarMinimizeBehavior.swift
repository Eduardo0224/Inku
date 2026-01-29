//
//  View+TabBarMinimizeBehavior.swift
//  Inku
//
//  Created by Eduardo Andrade on 29/01/26.
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
    /// Applies tabBarMinimizeBehavior(.onScrollDown) only on iOS 26+
    ///
    /// This modifier configures the tab bar to minimize when scrolling down,
    /// providing more screen real estate for content.
    /// Falls back to no-op on iOS 18.
    func tabBarMinimizeBehaviorOnScrollDown() -> some View {
        modifier(TabBarMinimizeBehaviorOnScrollDownModifier())
    }
}

// MARK: - View Modifier

/// ViewModifier to apply tabBarMinimizeBehavior only on iOS 26+
private struct TabBarMinimizeBehaviorOnScrollDownModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content.tabBarMinimizeBehavior(.onScrollDown)
        } else {
            content
        }
    }
}
