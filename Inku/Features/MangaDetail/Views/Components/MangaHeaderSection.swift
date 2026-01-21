//
//  MangaHeaderSection.swift
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

struct MangaHeaderSection: View {

    // MARK: - Properties

    let coverURL: URL?
    let title: String
    let japaneseTitle: String?
    let score: Double?

    // MARK: - Computed Properties

    private var scoreValue: String {
        guard let score else { return L10n.MangaDetail.Value.notAvailable }
        return score.formatted(.number.precision(.fractionLength(1)))
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: InkuSpacing.spacing16) {
            ZStack(alignment: .topTrailing) {
                InkuCoverImage(
                    url: coverURL,
                    cornerRadius: InkuRadius.radius12,
                    isLoading: false
                )
                .frame(width: 200, height: 300)
                .shadow(color: .black.opacity(0.2), radius: 10, y: 5)

                // Score badge overlay
                HStack(spacing: InkuSpacing.spacing4) {
                    Image(systemName: "star")
                        .symbolVariant(.fill)
                        .foregroundStyle(.yellow)
                        .font(.inkuCaption)

                    Text(scoreValue)
                        .font(.inkuBody)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.inkuText)
                }
                .padding(.horizontal, InkuSpacing.spacing8)
                .padding(.vertical, InkuSpacing.spacing4)
                .background {
                    if #available(iOS 26, *) {
                        RoundedRectangle(cornerRadius: InkuRadius.radius12)
                            .glassEffect(.regular)
                    } else {
                        Capsule()
                            .fill(.thinMaterial)
                    }
                }
                .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                .padding(InkuSpacing.spacing8)
            }

            VStack(spacing: InkuSpacing.spacing8) {
                Text(title)
                    .font(.inkuDisplayMedium)
                    .foregroundStyle(Color.inkuText)
                    .multilineTextAlignment(.center)

                if let japaneseTitle {
                    Text(japaneseTitle)
                        .font(.inkuSubheadline)
                        .foregroundStyle(Color.inkuTextSecondary)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .padding(.vertical, InkuSpacing.spacing24)
    }
}

// MARK: - Previews

#Preview("Header - Full", traits: .sizeThatFitsLayout) {
    MangaHeaderSection(
        coverURL: URL(string: "https://cdn.myanimelist.net/images/manga/3/216464.jpg"),
        title: "One Piece",
        japaneseTitle: "ワンピース",
        score: 9.21
    )
    .background(Color.inkuSurface)
}

#Preview("Header - No Japanese Title", traits: .sizeThatFitsLayout) {
    MangaHeaderSection(
        coverURL: URL(string: "https://cdn.myanimelist.net/images/manga/3/216464.jpg"),
        title: "Attack on Titan",
        japaneseTitle: nil,
        score: 8.54
    )
    .background(Color.inkuSurface)
}

#Preview("Header - No Score", traits: .sizeThatFitsLayout) {
    MangaHeaderSection(
        coverURL: URL(string: "https://cdn.myanimelist.net/images/manga/3/216464.jpg"),
        title: "New Manga",
        japaneseTitle: "新しい漫画",
        score: nil
    )
    .background(Color.inkuSurface)
}
