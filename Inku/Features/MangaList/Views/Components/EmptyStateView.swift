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

struct EmptyStateView: View {

    // MARK: - Body

    var body: some View {
        ContentUnavailableView {
            Label(L10n.MangaList.Empty.title, systemImage: "books.vertical")
        } description: {
            Text(L10n.MangaList.Empty.subtitle)
        }
    }
}

// MARK: - Previews

#Preview {
    EmptyStateView()
}
