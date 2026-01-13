//
//  CollectionItemCard.swift
//  Inku
//
//  Created by Eduardo Andrade on 08/01/26.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2026 Eduardo Andrade. All rights reserved.
//

import SwiftUI
import InkuUI

struct CollectionItemCard: View {

    // MARK: - Properties

    let collectionManga: CollectionManga
    let onEdit: () -> Void
    let onDelete: () -> Void

    // MARK: - States

    @State private var coverURLCache: URL?

    // MARK: - Body

    var body: some View {
        HStack(spacing: InkuSpacing.spacing12) {
            // Cover Image
            coverImage

            // Info
            VStack(alignment: .leading, spacing: InkuSpacing.spacing8) {
                // Title
                Text(collectionManga.title)
                    .font(.inkuHeadline)
                    .foregroundStyle(Color.inkuText)
                    .lineLimit(2)

                // Collection Info
                collectionInfo

                // Progress Bar
                if let progress = collectionManga.readingProgress {
                    InkuProgressBar(
                        progress: progress,
                        label: L10n.Collection.Card.progress
                    )
                }
            }

            Spacer()

            // Actions
            actionsMenu
        }
        .padding(InkuSpacing.spacing12)
        .inkuCard()
        .task(id: collectionManga.mangaId) {
            // Force SwiftData to load coverImageURL by accessing it
            // This ensures the @Transient computed property has data available
            _ = collectionManga.coverImageURL
            coverURLCache = collectionManga.coverURL
        }
    }

    // MARK: - Private Views

    @ViewBuilder
    private var coverImage: some View {
        if let url = coverURLCache {
            InkuCoverImage(url: url, cornerRadius: InkuRadius.radius8)
                .frame(width: 60, height: 90)
        } else {
            Rectangle()
                .fill(Color.inkuSurfaceSecondary)
                .overlay {
                    Image(systemName: "book.closed")
                        .foregroundStyle(Color.inkuTextTertiary)
                }
                .clipShape(RoundedRectangle(cornerRadius: InkuRadius.radius8))
                .frame(width: 60, height: 90)
        }
    }

    private var collectionInfo: some View {
        VStack(alignment: .leading, spacing: InkuSpacing.spacing4) {
            // Volumes Owned
            Label {
                Text("\(collectionManga.volumesOwnedCount) \(volumesLabel)")
                    .font(.inkuCaption)
                    .foregroundStyle(Color.inkuTextSecondary)
            } icon: {
                Image(systemName: "books.vertical.fill")
                    .font(.inkuCaptionSmall)
                    .foregroundStyle(Color.inkuAccent)
            }

            // Currently Reading
            if let currentVolume = collectionManga.currentReadingVolume {
                Label {
                    Text(L10n.Collection.Card.reading(currentVolume))
                        .font(.inkuCaption)
                        .foregroundStyle(Color.inkuTextSecondary)
                } icon: {
                    Image(systemName: "book.pages")
                        .font(.inkuCaptionSmall)
                        .foregroundStyle(Color.inkuAccent)
                }
            }

            // Complete Badge
            if collectionManga.hasCompleteCollection {
                InkuBadge(
                    text: L10n.Collection.Card.complete,
                    style: .accent
                )
            }
        }
    }

    private var actionsMenu: some View {
        Menu {
            Button {
                onEdit()
            } label: {
                Label(L10n.Collection.Card.edit, systemImage: "pencil")
            }

            Button(role: .destructive) {
                onDelete()
            } label: {
                Label(L10n.Collection.Card.delete, systemImage: "trash")
            }
        } label: {
            Image(systemName: "ellipsis.circle")
                .font(.title3)
                .foregroundStyle(Color.inkuTextSecondary)
        }
    }

    // MARK: - Computed Properties

    private var volumesLabel: String {
        collectionManga.volumesOwnedCount == 1
            ? L10n.Collection.Card.volumeSingular
            : L10n.Collection.Card.volumePlural
    }
}

// MARK: - Previews

#Preview("Collection Item - Reading Progress", traits: .sizeThatFitsLayout) {
    CollectionItemCard(
        collectionManga: CollectionManga(
            mangaId: 1,
            title: "One Piece",
            coverImageURL: "https://cdn.myanimelist.net/images/manga/3/216460.jpg",
            totalVolumes: 106,
            volumesOwnedCount: 50,
            currentReadingVolume: 51,
            hasCompleteCollection: false
        ),
        onEdit: { print("Edit") },
        onDelete: { print("Delete") }
    )
    .padding()
    .background(Color.inkuSurface)
}

#Preview("Collection Item - Complete", traits: .sizeThatFitsLayout) {
    CollectionItemCard(
        collectionManga: CollectionManga(
            mangaId: 2,
            title: "Naruto",
            coverImageURL: "https://cdn.myanimelist.net/images/manga/3/249658.jpg",
            totalVolumes: 72,
            volumesOwnedCount: 72,
            currentReadingVolume: nil,
            hasCompleteCollection: true
        ),
        onEdit: { print("Edit") },
        onDelete: { print("Delete") }
    )
    .padding()
    .background(Color.inkuSurface)
}

#Preview("Collection Item - No Progress", traits: .sizeThatFitsLayout) {
    CollectionItemCard(
        collectionManga: CollectionManga(
            mangaId: 3,
            title: "Attack on Titan",
            coverImageURL: "https://cdn.myanimelist.net/images/manga/2/37846.jpg",
            totalVolumes: 34,
            volumesOwnedCount: 10,
            currentReadingVolume: nil,
            hasCompleteCollection: false
        ),
        onEdit: { print("Edit") },
        onDelete: { print("Delete") }
    )
    .padding()
    .background(Color.inkuSurface)
}

#Preview("Collection Item - Unknown Total", traits: .sizeThatFitsLayout) {
    CollectionItemCard(
        collectionManga: CollectionManga(
            mangaId: 4,
            title: "Ongoing Series",
            coverImageURL: nil,
            totalVolumes: nil,
            volumesOwnedCount: 15,
            currentReadingVolume: 16,
            hasCompleteCollection: false
        ),
        onEdit: { print("Edit") },
        onDelete: { print("Delete") }
    )
    .padding()
    .background(Color.inkuSurface)
}
