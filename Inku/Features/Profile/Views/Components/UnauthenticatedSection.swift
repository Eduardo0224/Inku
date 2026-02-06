//
//  UnauthenticatedSection.swift
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

struct UnauthenticatedSection: View {

    // MARK: - Properties

    let localMangasCount: Int
    let onLoginTapped: () -> Void
    let onRegisterTapped: () -> Void

    // MARK: - Body

    var body: some View {
        VStack(spacing: InkuSpacing.spacing32) {
            headerSection
            localCollectionSection
            authButtonsSection
        }
    }

    // MARK: - Private Views

    private var headerSection: some View {
        VStack(spacing: InkuSpacing.spacing16) {
            Image(systemName: "person.crop")
                .symbolVariant(.circle)
                .font(.system(size: 80))
                .foregroundStyle(Color.inkuAccent)

            VStack(spacing: InkuSpacing.spacing8) {
                Text(L10n.Profile.Unauthenticated.title)
                    .font(.inkuBody)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.inkuText)

                Text(L10n.Profile.Unauthenticated.subtitle)
                    .font(.inkuBody)
                    .foregroundStyle(Color.inkuTextSecondary)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private var localCollectionSection: some View {
        VStack(alignment: .leading, spacing: InkuSpacing.spacing12) {
            Text(L10n.Profile.LocalCollection.title)
                .font(.inkuHeadline)
                .fontWeight(.semibold)
                .foregroundStyle(Color.inkuText)

            VStack(spacing: InkuSpacing.spacing12) {
                HStack(alignment: .top) {
                    Image(systemName: "iphone")
                        .font(.inkuIconMedium)
                        .foregroundStyle(Color.inkuAccent)

                    VStack(alignment: .leading, spacing: InkuSpacing.spacing4) {
                        Text(L10n.Profile.LocalCollection.saved)
                            .font(.inkuBody)
                            .foregroundStyle(Color.inkuTextSecondary)

                        Text(L10n.Profile.Sync.mangasCount(localMangasCount))
                            .font(.inkuCaption)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.inkuText)
                    }

                    Spacer()
                }
                .padding(InkuSpacing.spacing16)
                .background(Color.inkuSurfaceSecondary)
                .clipShape(RoundedRectangle(cornerRadius: InkuRadius.radius12))
            }
        }
    }

    private var authButtonsSection: some View {
        VStack(spacing: InkuSpacing.spacing12) {
            Button(action: onLoginTapped) {
                Text(L10n.Authentication.Login.button)
                    .font(.inkuBody)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.inkuTextOnAccent)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.inkuAccent)
                    .clipShape(RoundedRectangle(cornerRadius: InkuRadius.radius12))
            }

            Button(action: onRegisterTapped) {
                Text(L10n.Authentication.Register.button)
                    .font(.inkuBody)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.inkuAccent)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.inkuSurfaceSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: InkuRadius.radius12))
                    .overlay {
                        RoundedRectangle(cornerRadius: InkuRadius.radius12)
                            .stroke(Color.inkuAccent, lineWidth: 2)
                    }
            }
        }
    }
}

// MARK: - Previews

#Preview() {
    ZStack {
        Color.inkuSurface
            .ignoresSafeArea()
        
        ScrollView {
            UnauthenticatedSection(
                localMangasCount: 3,
                onLoginTapped: {
                    print("Login tapped")
                },
                onRegisterTapped: {
                    print("Register tapped")
                }
            )
            .padding()
        }
    }
}
