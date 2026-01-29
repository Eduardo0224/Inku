//
//  MangaGridSkeletonView.swift
//  Inku
//
//  Created by Eduardo Andrade on 28/01/26.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2026 Eduardo Andrade. All rights reserved.
//

import SwiftUI
import InkuUI

struct MangaGridSkeletonView: View {

    // MARK: - Environment

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    // MARK: - Computed Properties

    private func columnCount(for width: CGFloat) -> Int {
        if horizontalSizeClass == .regular {
            return width > 1000 ? 5 : 4
        }

        return 2
    }

    // MARK: - Body

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                LazyVGrid(
                    columns: Array(
                        repeating: GridItem(.flexible(), spacing: InkuSpacing.spacing16),
                        count: columnCount(for: geometry.size.width)
                    ),
                    spacing: InkuSpacing.spacing16
                ) {
                    ForEach(0..<20, id: \.self) { _ in
                        MangaCardView(
                            manga: .skeletonData,
                            isLoading: true
                        )
                    }
                }
                .padding(.horizontal, InkuSpacing.spacing16)
            }
            .scrollDisabled(true)
        }
        .background(Color.inkuSurface)
    }
}

// MARK: - Previews

#Preview("Manga Grid Skeleton") {
    MangaGridSkeletonView()
}
