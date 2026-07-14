//
//  CollectionListView.swift
//  InkuWatch
//
//  Created by Eduardo Andrade on 02/06/26.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2026 Eduardo Andrade. All rights reserved.
//

import SwiftUI
import InkuUI

// MARK: - Collection List View

struct CollectionListView: View {

    // MARK: - Properties

    let mangas: [WatchMangaDisplayItem]

    // MARK: - Body

    var body: some View {
        Group {
            if mangas.isEmpty {
                emptyView
            } else {
                List(mangas, id: \.mangaId) { item in
                    NavigationLink(destination: MangaDetailView(item: item)) {
                        WatchMangaRow(item: item)
                    }
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: InkuRadius.radius12)
                            .fill(Color.inkuSurfaceElevated)
                            .padding(.horizontal, InkuSpacing.spacing4)
                    )
                }
                .listStyle(.carousel)
            }
        }
        .navigationTitle(L10n.Watch.collection)
        .background(Color.inkuSurface)
    }

    // MARK: - Private Views

    private var emptyView: some View {
        VStack(spacing: InkuSpacing.spacing8) {
            Image(systemName: "books.vertical")
                .font(.title2)
                .foregroundStyle(.secondary)

            Text(L10n.Watch.emptyTitle)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(L10n.Watch.emptyMessage)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.inkuSurface)
    }
}

// MARK: - Preview

#Preview("Collection with data") {
    CollectionListView(mangas: .watchPreview)
}

#Preview("Empty collection") {
    CollectionListView(mangas: [])
}
