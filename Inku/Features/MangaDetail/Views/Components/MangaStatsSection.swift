//
//  MangaStatsSection.swift
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

struct MangaStatsSection: View {

    // MARK: - Properties

    let volumes: Int?
    let chapters: Int?
    let status: String?

    // MARK: - Computed Properties

    private var volumesValue: String {
        guard let volumes else { return L10n.MangaDetail.Publication.unknown }
        return "\(volumes)"
    }

    private var chaptersValue: String {
        guard let chapters else { return L10n.MangaDetail.Publication.unknown }
        return "\(chapters)"
    }

    private var statusValue: String {
        guard let status else { return L10n.MangaDetail.Publication.unknown }
        return Status(rawValue: status).displayText
    }

    private var statusColor: Color {
        guard let status else { return .gray }
        return Status(rawValue: status).color
    }

    // MARK: - Body

    var body: some View {
        HStack(spacing: InkuSpacing.spacing12) {
            InkuStatCard(
                icon: "book.fill",
                value: volumesValue,
                label: L10n.MangaDetail.Stats.volumes,
                accentColor: .blue
            )
            .inkuCard()

            InkuStatCard(
                icon: "doc.text.fill",
                value: chaptersValue,
                label: L10n.MangaDetail.Stats.chapters,
                accentColor: .green
            )
            .inkuCard()

            InkuStatCard(
                icon: "checkmark.circle.fill",
                value: statusValue,
                label: L10n.MangaDetail.Stats.status,
                accentColor: statusColor
            )
            .inkuCard()
        }
    }
}

// MARK: - Status

extension MangaStatsSection {

    enum Status {
        case publishing
        case completed
        case hiatus
        case discontinued
        case unknown

        init(rawValue: String) {
            switch rawValue.lowercased() {
            case "currently_publishing", "publishing", "ongoing":
                self = .publishing
            case "finished", "completed":
                self = .completed
            case "on_hiatus", "hiatus":
                self = .hiatus
            case "discontinued":
                self = .discontinued
            default:
                self = .unknown
            }
        }

        var displayText: String {
            switch self {
            case .publishing: return L10n.MangaDetail.Status.publishing
            case .completed: return L10n.MangaDetail.Status.completed
            case .hiatus: return L10n.MangaDetail.Status.hiatus
            case .discontinued: return L10n.MangaDetail.Status.discontinued
            case .unknown: return L10n.MangaDetail.Publication.unknown
            }
        }

        var color: Color {
            switch self {
            case .publishing: return .green
            case .completed: return .blue
            case .hiatus: return .orange
            case .discontinued: return .red
            case .unknown: return .gray
            }
        }
    }
}

// MARK: - Previews

#Preview("Stats - Full Data", traits: .sizeThatFitsLayout) {
    MangaStatsSection(
        volumes: 25,
        chapters: 1097,
        status: "Publishing"
    )
    .padding()
    .background(Color.inkuSurface)
}

#Preview("Stats - Partial Data", traits: .sizeThatFitsLayout) {
    MangaStatsSection(
        volumes: nil,
        chapters: nil,
        status: "Completed"
    )
    .padding()
    .background(Color.inkuSurface)
}

#Preview("Stats - No Data", traits: .sizeThatFitsLayout) {
    MangaStatsSection(
        volumes: nil,
        chapters: nil,
        status: nil
    )
    .padding()
    .background(Color.inkuSurface)
}
