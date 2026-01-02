//
//  MangaSynopsisSection.swift
//  Inku
//
//  Created by Eduardo Andrade on 30/12/25.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2025 Eduardo Andrade. All rights reserved.
//

import SwiftUI
import InkuUI

struct MangaSynopsisSection: View {

    // MARK: - Properties

    let synopsis: String?
    let background: String?
    let title: String

    // MARK: - States

    @State private var isExpanded: Bool = false
    @State private var showingBackground: Bool = false

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: InkuSpacing.spacing12) {
            Text(L10n.MangaDetail.Synopsis.title)
                .font(.inkuHeadline)
                .foregroundStyle(Color.inkuText)

            if let synopsis, !synopsis.isEmpty {
                Text(synopsis)
                    .font(.inkuBody)
                    .foregroundStyle(Color.inkuTextSecondary)
                    .lineLimit(isExpanded ? nil : 4)
                    .animation(.easeInOut, value: isExpanded)

                HStack(spacing: InkuSpacing.spacing12) {
                    Button {
                        isExpanded.toggle()
                    } label: {
                        Text(isExpanded ? L10n.MangaDetail.Synopsis.readLess : L10n.MangaDetail.Synopsis.readMore)
                            .font(.inkuBodySmall)
                            .foregroundStyle(Color.inkuAccent)
                    }

                    if let background, !background.isEmpty {
                        Text("•")
                            .font(.inkuBodySmall)
                            .foregroundStyle(Color.inkuTextSecondary)

                        Button {
                            showingBackground = true
                        } label: {
                            Text(L10n.MangaDetail.Background.button)
                                .font(.inkuBodySmall)
                                .foregroundStyle(Color.inkuAccent)
                        }
                    }
                }
            } else {
                Text(L10n.MangaDetail.Synopsis.empty)
                    .font(.inkuBody)
                    .foregroundStyle(Color.inkuTextSecondary)
                    .italic()
            }
        }
        .padding(InkuSpacing.spacing16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .inkuCard()
        .sheet(isPresented: $showingBackground) {
            if let background {
                MangaBackgroundSheet(title: title, background: background)
            }
        }
    }
}

// MARK: - Previews

#Preview("Synopsis - With Text", traits: .sizeThatFitsLayout) {
    MangaSynopsisSection(
        synopsis: "Monkey D. Luffy refuses to let anyone or anything stand in the way of his quest to become the king of all pirates. With a course charted for the treacherous waters of the Grand Line and beyond, this is one captain who'll never give up until he's claimed the greatest treasure on Earth: the Legendary One Piece!",
        background: nil,
        title: "One Piece"
    )
    .padding()
    .background(Color.inkuSurface)
}

#Preview("Synopsis - With Background", traits: .sizeThatFitsLayout) {
    MangaSynopsisSection(
        synopsis: "Monkey D. Luffy refuses to let anyone or anything stand in the way of his quest to become the king of all pirates.",
        background: "Gol D. Roger was known as the \"Pirate King,\" the strongest and most infamous being to have sailed the Grand Line. The capture and execution of Roger by the World Government brought a change throughout the world.",
        title: "One Piece"
    )
    .padding()
    .background(Color.inkuSurface)
}

#Preview("Synopsis - Empty", traits: .sizeThatFitsLayout) {
    MangaSynopsisSection(synopsis: nil, background: nil, title: "Unknown")
        .padding()
        .background(Color.inkuSurface)
}
