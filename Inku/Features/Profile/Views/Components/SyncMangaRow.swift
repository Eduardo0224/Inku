//
//  SyncMangaRow.swift
//  Inku
//
//  Created by Eduardo Andrade on 31/01/26.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2025 Eduardo Andrade. All rights reserved.
//

import SwiftUI
import InkuUI

struct SyncMangaRow: View {

    // MARK: - Properties

    let manga: CollectionManga
    let status: SyncStatus

    // MARK: - Body

    var body: some View {
        HStack(spacing: InkuSpacing.spacing12) {
            VStack(alignment: .leading, spacing: InkuSpacing.spacing4) {
                Text(manga.title)
                    .font(.inkuSubheadline)
                    .foregroundStyle(Color.inkuText)
                    .lineLimit(1)
            }

            Spacer()

            statusIcon
                .font(.inkuBodySmall)
                .foregroundStyle(statusColor)
        }
        .padding(InkuSpacing.spacing12)
        .clipShape(RoundedRectangle(cornerRadius: InkuRadius.radius8))
    }

    // MARK: - Private Views

    @ViewBuilder
    private var statusIcon: some View {
        switch status {
        case .pending:
            Image(systemName: "icloud.slash")
        case .uploading:
            Image(systemName: "icloud.and.arrow.up")
                .symbolEffect(.pulse)
        case .uploaded:
            Image(systemName: "checkmark.icloud.fill")
        case .failed:
            Image(systemName: "exclamationmark.icloud.fill")
        }
    }

    private var statusColor: Color {
        switch status {
        case .pending:
            Color.inkuTextSecondary
        case .uploading:
            Color.inkuAccent
        case .uploaded:
            Color.green.opacity(0.8)
        case .failed:
            Color.red.opacity(0.85)
        }
    }
}

// MARK: - Preview

#Preview {
    VStack {
        SyncMangaRow(
            manga: CollectionManga(
                mangaId: 1,
                title: "One Piece",
                coverImageURL: "https://cdn.myanimelist.net/images/manga/3/216460.jpg",
                totalVolumes: 106,
                volumesOwnedCount: 50,
                currentReadingVolume: 51,
                hasCompleteCollection: false
            ),
            status: .pending
        )

        SyncMangaRow(
            manga: CollectionManga(
                mangaId: 2,
                title: "Naruto",
                coverImageURL: "https://cdn.myanimelist.net/images/manga/3/249658.jpg",
                totalVolumes: 72,
                volumesOwnedCount: 72,
                hasCompleteCollection: true
            ),
            status: .uploading
        )

        SyncMangaRow(
            manga: CollectionManga(
                mangaId: 3,
                title: "Bleach",
                coverImageURL: "https://cdn.myanimelist.net/images/manga/3/180031.jpg",
                totalVolumes: 74,
                volumesOwnedCount: 30,
                currentReadingVolume: 25,
                hasCompleteCollection: false
            ),
            status: .uploaded
        )

        SyncMangaRow(
            manga: CollectionManga(
                mangaId: 4,
                title: "Death Note",
                coverImageURL: "https://cdn.myanimelist.net/images/manga/2/253119.jpg",
                totalVolumes: 12,
                volumesOwnedCount: 12,
                hasCompleteCollection: true
            ),
            status: .failed
        )
    }
    .padding()
    .background(Color.inkuSurface)
}
