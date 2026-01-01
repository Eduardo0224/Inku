//
//  MangaAuthorsSection.swift
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

struct MangaAuthorsSection: View {

    // MARK: - Properties

    let authors: [Author]

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: InkuSpacing.spacing12) {
            Text(L10n.MangaDetail.Authors.title)
                .font(.inkuHeadline)
                .foregroundStyle(Color.inkuText)

            if !authors.isEmpty {
                VStack(alignment: .leading, spacing: InkuSpacing.spacing8) {
                    ForEach(authors) { author in
                        HStack {
                            Image(systemName: "person.circle")
                                .symbolVariant(.fill)
                                .foregroundStyle(Color.inkuTextSecondary)
                                .font(.inkuBody)

                            Text(author.fullName)
                                .font(.inkuBody)
                                .foregroundStyle(Color.inkuText)

                            Spacer()

                            InkuBadge(text: author.role, style: .secondary)
                        }
                    }
                }
            } else {
                Text(L10n.MangaDetail.Authors.empty)
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

// MARK: - Previews

#Preview("Authors - Multiple", traits: .sizeThatFitsLayout) {
    MangaAuthorsSection(
        authors: [
            Author(id: "1", firstName: "Eiichiro", lastName: "Oda", role: "Story & Art"),
            Author(id: "2", firstName: "Masashi", lastName: "Kishimoto", role: "Story"),
            Author(id: "3", firstName: "Akira", lastName: "Toriyama", role: "Art")
        ]
    )
    .padding()
    .background(Color.inkuSurface)
}

#Preview("Authors - Single", traits: .sizeThatFitsLayout) {
    MangaAuthorsSection(
        authors: [
            Author(id: "1", firstName: "Eiichiro", lastName: "Oda", role: "Story & Art")
        ]
    )
    .padding()
    .background(Color.inkuSurface)
}

#Preview("Authors - Empty", traits: .sizeThatFitsLayout) {
    MangaAuthorsSection(authors: [])
        .padding()
        .background(Color.inkuSurface)
}
