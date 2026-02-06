//
//  AuthenticatedHeaderSection.swift
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

struct AuthenticatedHeaderSection: View {

    // MARK: - Properties

    let email: String

    // MARK: - Body

    var body: some View {
        VStack(spacing: InkuSpacing.spacing16) {
            ZStack {
                Circle()
                    .fill(Color.inkuAccent)
                    .frame(width: 80, height: 80)

                Text(email.prefix(1).uppercased())
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundStyle(Color.inkuTextOnAccent)
            }

            VStack(spacing: InkuSpacing.spacing4) {
                Text(L10n.Profile.Authenticated.welcome)
                    .font(.inkuBody)
                    .foregroundStyle(Color.inkuTextSecondary)

                Text(email)
                    .font(.inkuBody)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.inkuText)
            }
        }
    }
}

// MARK: - Previews

#Preview(traits: .sizeThatFitsLayout) {
    AuthenticatedHeaderSection(email: "test@inku.com")
        .padding()
        .background(Color.inkuSurface)
}
