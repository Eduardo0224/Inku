//
//  ProfileLoadingOverlay.swift
//  Inku
//
//  Created by Eduardo Andrade on 01/02/26.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2026 Eduardo Andrade. All rights reserved.
//

import SwiftUI
import InkuUI

struct ProfileLoadingOverlay: View {

    // MARK: - Body

    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            InkuLoadingView(message: L10n.Profile.Loading.cloudCollection)
                .padding(InkuSpacing.spacing16)
                .background {
                    RoundedRectangle(cornerRadius: InkuRadius.radius16)
                        .fill(.regularMaterial)
                }
                .frame(width: 280, height: 150)
                .shadow(radius: 20)
        }
    }
}

// MARK: - Previews

#Preview(traits: .sizeThatFitsLayout) {
    ProfileLoadingOverlay()
        .padding()
        .background(Color.inkuSurface)
}
