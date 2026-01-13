//
//  CollectionStatsView.swift
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

struct CollectionStatsView: View {

    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss
    @Environment(\.collectionViewModel) private var viewModel

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: InkuSpacing.spacing24) {
                    statsGrid
                }
                .padding(InkuSpacing.spacing16)
            }
            .background(Color.inkuSurface)
            .navigationTitle(L10n.Collection.Stats.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color.inkuTextSecondary)
                    }
                }
            }
        }
    }

    // MARK: - Private Views

    private var statsGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ],
            spacing: InkuSpacing.spacing16
        ) {
            InkuStatCard(
                icon: "books.vertical.fill",
                value: "\(viewModel.getTotalMangas())",
                label: L10n.Collection.Stats.totalMangas,
                size: .large,
                accentColor: .inkuAccent
            )

            InkuStatCard(
                icon: "book.fill",
                value: "\(viewModel.getTotalVolumesOwned())",
                label: L10n.Collection.Stats.totalVolumes,
                size: .large,
                accentColor: .inkuAccentStrong
            )
        }
    }
}

// MARK: - Previews

#Preview("Collection Stats - Empty") {
    CollectionStatsView()
        .environment(\.collectionViewModel, MockCollectionViewModel.empty)
}

#Preview("Collection Stats - With Data") {
    CollectionStatsView()
        .environment(\.collectionViewModel, MockCollectionViewModel.withData)
}
