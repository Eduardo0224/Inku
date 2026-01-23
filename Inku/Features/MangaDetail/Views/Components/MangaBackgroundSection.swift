//
//  MangaBackgroundSection.swift
//  Inku
//
//  Created by Eduardo Andrade on 22/01/26.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2026 Eduardo Andrade. All rights reserved.
//

import SwiftUI
import InkuUI

struct MangaBackgroundSection: View {

    // MARK: - Properties

    let background: String

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: InkuSpacing.spacing12) {
            Text(L10n.MangaDetail.Background.title)
                .font(.inkuHeadline)
                .foregroundStyle(Color.inkuText)

            Text(background)
                .font(.inkuBody)
                .foregroundStyle(Color.inkuTextSecondary)
        }
        .padding(InkuSpacing.spacing16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .inkuCard()
    }
}

// MARK: - Previews

#Preview("Background Section", traits: .sizeThatFitsLayout) {
    MangaBackgroundSection(
        background: "Gol D. Roger was known as the \"Pirate King,\" the strongest and most infamous being to have sailed the Grand Line. The capture and execution of Roger by the World Government brought a change throughout the world."
    )
    .padding()
    .background(Color.inkuSurface)
}
