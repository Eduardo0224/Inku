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
    let onTap: () -> Void

    // MARK: - States

    @State private var imageKey: UUID = UUID()

    // MARK: - Body

    var body: some View {
        cardContent
            .onTapGesture {
                onTap()
            }
    }

    // MARK: - Private Views

    private var cardContent: some View {
        HStack(alignment: .top, spacing: InkuSpacing.spacing12) {
            coverImage

            VStack(alignment: .leading, spacing: InkuSpacing.spacing8) {
                Text(collectionManga.title)
                    .font(.inkuHeadline)
                    .foregroundStyle(Color.inkuText)
                    .lineLimit(2)

                collectionInfo

                if let progress = collectionManga.readingProgress {
                    InkuProgressBar(
                        progress: progress,
                        label: L10n.Collection.Card.progress
                    )
                }
            }

            Spacer()

            actionsMenu
        }
        .padding(InkuSpacing.spacing12)
        .inkuCard()
        .onAppear {
            imageKey = UUID()
        }
    }

    @ViewBuilder
    private var coverImage: some View {
        if let url = collectionManga.coverURL {
            InkuCoverImage(url: url, cornerRadius: InkuRadius.radius8)
                .frame(width: 60, height: 90)
                .id(imageKey)
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
            Label {
                Text("\(collectionManga.volumesOwnedCount) \(volumesLabel)")
                    .font(.inkuCaption)
                    .foregroundStyle(Color.inkuTextSecondary)
            } icon: {
                Image(systemName: "books.vertical")
                    .symbolVariant(.fill)
                    .font(.inkuCaptionSmall)
                    .foregroundStyle(Color.inkuAccent)
            }

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
            Image(systemName: "ellipsis")
                .symbolVariant(.circle)
                .font(.title2)
                .foregroundStyle(Color.inkuAccent)
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
        onDelete: { print("Delete") },
        onTap: { print("Tap") }
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
        onDelete: { print("Delete") },
        onTap: { print("Tap") }
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
        onDelete: { print("Delete") },
        onTap: { print("Tap") }
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
        onDelete: { print("Delete") },
        onTap: { print("Tap") }
    )
    .padding()
    .background(Color.inkuSurface)
}
