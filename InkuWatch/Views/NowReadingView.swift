//
//  NowReadingView.swift
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

// MARK: - Now Reading View

struct NowReadingView: View {

    // MARK: - Properties

    let mangas: [WatchMangaItem]

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
        .navigationTitle(L10n.Watch.nowReading)
        .background(Color.inkuSurface)
    }

    // MARK: - Private Views

    private var emptyView: some View {
        VStack(spacing: InkuSpacing.spacing8) {
            Image(systemName: "book.pages")
                .font(.title2)
                .foregroundStyle(.secondary)

            Text(L10n.Watch.noActiveReading)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(L10n.Watch.startReadingHint)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.inkuSurface)
    }
}

// MARK: - Preview

#Preview("Now Reading with data") {
    NavigationStack {
        NowReadingView(mangas: .watchPreview)
    }
}

#Preview("Now Reading empty") {
    NavigationStack {
        NowReadingView(mangas: [])
    }
}
