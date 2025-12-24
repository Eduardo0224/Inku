//
//  MangaRowView.swift
//  Inku
//
//  Created by Eduardo Andrade on 23/12/25.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2025 Eduardo Andrade. All rights reserved.
//

import SwiftUI

struct MangaRowView: View {

    // MARK: - Properties

    let manga: Manga

    // MARK: - Computed Properties

    var firstThreeGenres: [Genre] {
        Array(manga.genres.prefix(3))
    }

    // MARK: - Body

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            coverImage
                .frame(width: 80, height: 120)
                .background(.secondary.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 8) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(manga.displayTitle)
                        .font(.headline)
                        .lineLimit(2)

                    if let japaneseTitle = manga.titleJapanese {
                        Text(japaneseTitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }

                if let score = manga.score {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundStyle(.yellow)
                        Text(score.formatted(.number.precision(.fractionLength(2))))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                genresView

                statusView
            }

            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
    }

    // MARK: - Private Views

    @ViewBuilder
    private var coverImage: some View {
        if let url = manga.coverImageURL {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    Image(systemName: "photo")
                        .foregroundStyle(.secondary)
                @unknown default:
                    EmptyView()
                }
            }
        } else {
            Image(systemName: "photo")
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private var genresView: some View {
        if !manga.genres.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(firstThreeGenres, id: \.id) { genre in
                        Text(genre.genre)
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.accentColor.opacity(0.2))
                            .foregroundStyle(Color.accentColor)
                            .clipShape(Capsule())
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var statusView: some View {
        if let status = manga.status {
            HStack(spacing: 4) {
                Circle()
                    .fill(statusColor(for: status))
                    .frame(width: 6, height: 6)
                Text(status)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Private Functions

    private func statusColor(for status: String) -> Color {
        switch status.lowercased() {
        case "publishing", "ongoing":
            return .green
        case "finished", "completed":
            return .blue
        case "on_hiatus", "hiatus":
            return .orange
        case "discontinued":
            return .red
        default:
            return .gray
        }
    }
}

// MARK: - Previews

#Preview(
    "Manga Row View Empty Data",
    traits: .sizeThatFitsLayout
) {
    MangaRowView(manga: .emptyData)
        .padding()
        .background(Color(.systemGroupedBackground))
}

#Preview(
    "Manga Row View Test Data",
    traits: .sizeThatFitsLayout
) {
    MangaRowView(manga: .testData)
        .padding()
        .background(Color(.systemGroupedBackground))
}
