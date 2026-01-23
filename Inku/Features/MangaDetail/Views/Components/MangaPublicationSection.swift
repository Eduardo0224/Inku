//
//  MangaPublicationSection.swift
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

struct MangaPublicationSection: View {

    // MARK: - Properties

    let startDate: Date?
    let endDate: Date?
    let status: String?

    // MARK: - Computed Properties

    private var publicationPeriod: String {
        guard let startDate else {
            return L10n.MangaDetail.Publication.unknown
        }

        let startText = startDate.formatted(.dateTime.month(.abbreviated).year())

        // Check if manga is still publishing
        let isPublishing = status?.lowercased().contains("publishing") ?? false
        let isOngoing = status?.lowercased().contains("ongoing") ?? false

        if isPublishing || isOngoing {
            return "\(startText) - \(L10n.MangaDetail.Publication.present)"
        }

        if let endDate {
            let endText = endDate.formatted(.dateTime.month(.abbreviated).year())
            return "\(startText) - \(endText)"
        }

        return "\(L10n.MangaDetail.Publication.since) \(startText)"
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: InkuSpacing.spacing12) {
            Text(L10n.MangaDetail.Publication.title)
                .font(.inkuHeadline)
                .foregroundStyle(Color.inkuText)

            HStack(spacing: InkuSpacing.spacing8) {
                Image(systemName: "calendar")
                    .foregroundStyle(Color.inkuTextSecondary)
                    .font(.title3)

                Text(publicationPeriod)
                    .font(.inkuBody)
                    .foregroundStyle(Color.inkuText)
            }
        }
        .padding(InkuSpacing.spacing16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .inkuCard()
    }
}

// MARK: - Previews

#Preview("Publication - Active", traits: .sizeThatFitsLayout) {
    MangaPublicationSection(
        startDate: Calendar.current.date(from: DateComponents(year: 1997, month: 7, day: 22)),
        endDate: nil,
        status: "Publishing"
    )
    .padding()
    .background(Color.inkuSurface)
}

#Preview("Publication - Completed", traits: .sizeThatFitsLayout) {
    MangaPublicationSection(
        startDate: Calendar.current.date(from: DateComponents(year: 2009, month: 9, day: 19)),
        endDate: Calendar.current.date(from: DateComponents(year: 2013, month: 4, day: 8)),
        status: "Finished"
    )
    .padding()
    .background(Color.inkuSurface)
}

#Preview("Publication - No Data", traits: .sizeThatFitsLayout) {
    MangaPublicationSection(
        startDate: nil,
        endDate: nil,
        status: nil
    )
    .padding()
    .background(Color.inkuSurface)
}
