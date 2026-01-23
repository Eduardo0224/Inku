//
//  MangaTagsSection.swift
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

struct MangaTagsSection: View {

    // MARK: - Properties

    let genres: [Genre]
    let demographics: [Demographic]
    let themes: [Theme]

    // MARK: - Computed Properties

    private var allTags: [String] {
        var tags: [String] = []
        tags.append(contentsOf: genres.map(\.genre))
        tags.append(contentsOf: demographics.map(\.demographic))
        tags.append(contentsOf: themes.map(\.theme))
        return tags
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: InkuSpacing.spacing12) {
            Text(L10n.MangaDetail.Tags.title)
                .font(.inkuHeadline)
                .foregroundStyle(Color.inkuText)

            if !allTags.isEmpty {
                FlowLayout(spacing: InkuSpacing.spacing8) {
                    ForEach(allTags, id: \.self) { tag in
                        InkuBadge(text: tag, style: .secondary)
                    }
                }
            } else {
                Text(L10n.MangaDetail.Tags.empty)
                    .font(.inkuBody)
                    .foregroundStyle(Color.inkuTextSecondary)
                    .italic()
            }
        }
        .padding(InkuSpacing.spacing16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .inkuCard()
    }
}

// MARK: - Flow Layout

private struct FlowLayout: Layout {

    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            let position = CGPoint(
                x: bounds.minX + result.positions[index].x,
                y: bounds.minY + result.positions[index].y
            )
            subview.place(at: position, proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }

                positions.append(CGPoint(x: x, y: y))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }

            self.size = CGSize(width: maxWidth, height: y + lineHeight)
        }
    }
}

// MARK: - Previews

#Preview("Tags - Full", traits: .sizeThatFitsLayout) {
    MangaTagsSection(
        genres: [
            Genre(id: "1", genre: "Shounen"),
            Genre(id: "2", genre: "Action"),
            Genre(id: "3", genre: "Adventure"),
            Genre(id: "4", genre: "Fantasy"),
            Genre(id: "5", genre: "Comedy")
        ],
        demographics: [
            Demographic(id: "1", demographic: "Shounen")
        ],
        themes: [
            Theme(id: "1", theme: "Pirates"),
            Theme(id: "2", theme: "Super Power")
        ]
    )
    .padding()
    .background(Color.inkuSurface)
}

#Preview("Tags - Genres Only", traits: .sizeThatFitsLayout) {
    MangaTagsSection(
        genres: [
            Genre(id: "1", genre: "Shounen"),
            Genre(id: "2", genre: "Action")
        ],
        demographics: [],
        themes: []
    )
    .padding()
    .background(Color.inkuSurface)
}

#Preview("Tags - Empty", traits: .sizeThatFitsLayout) {
    MangaTagsSection(
        genres: [],
        demographics: [],
        themes: []
    )
    .padding()
    .background(Color.inkuSurface)
}
