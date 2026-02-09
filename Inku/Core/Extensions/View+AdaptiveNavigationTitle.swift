//
//  View+AdaptiveNavigationTitle.swift
//  Inku
//
//  Created by Eduardo Andrade on 09/02/26.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2026 Eduardo Andrade. All rights reserved.
//

import SwiftUI

extension View {
    /// Applies an adaptive navigation title that hides on iOS when the tab bar is in top placement
    /// and always shows on other platforms.
    ///
    /// - Parameter title: The title to display in the navigation bar
    /// - Returns: A view with the adaptive navigation title applied
    func adaptiveNavigationTitle(_ title: String) -> some View {
        modifier(AdaptiveNavigationTitleModifier(title: title))
    }
}

// MARK: - Adaptive Navigation Title Modifier

private struct AdaptiveNavigationTitleModifier: ViewModifier {
    let title: String

    #if os(iOS)
    @Environment(\.tabBarPlacement) private var tabBarPlacement
    #endif

    func body(content: Content) -> some View {
    #if os(iOS)
        content
            .navigationTitle(tabBarPlacement == .topBar ? "" : title)
    #else
        content
            .navigationTitle(title)
    #endif
    }
}
