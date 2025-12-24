//
//  LoadingStateView.swift
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

struct LoadingStateView: View {

    // MARK: - Body

    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)

            Text(L10n.Common.loading)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Previews

#Preview {
    LoadingStateView()
}
