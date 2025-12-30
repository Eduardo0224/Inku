//
//  EmptyStateView.swift
//  Inku
//
//  Created by Eduardo Andrade on 23/12/25.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2025 Eduardo Andrade. All rights reserved.
//

import SwiftUI
import InkuUI

struct EmptyStateView: View {

    // MARK: - Body

    var body: some View {
        InkuEmptyView(
            icon: "books.vertical",
            title: L10n.MangaList.Empty.title,
            subtitle: L10n.MangaList.Empty.subtitle
        )
        .background(Color.inkuSurface)
    }
}

// MARK: - Previews

#Preview {
    EmptyStateView()
}
