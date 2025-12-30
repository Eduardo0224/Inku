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
import InkuUI

struct LoadingStateView: View {

    // MARK: - Body

    var body: some View {
        InkuLoadingView(message: L10n.Common.loading)
            .background(Color.inkuSurface)
    }
}

// MARK: - Previews

#Preview {
    LoadingStateView()
}
