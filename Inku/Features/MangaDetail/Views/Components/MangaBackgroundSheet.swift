//
//  MangaBackgroundSheet.swift
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

struct MangaBackgroundSheet: View {

    // MARK: - Properties

    let title: String
    let background: String

    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: InkuSpacing.spacing16) {
                    Text(title)
                        .font(.inkuHeadline)
                        .foregroundStyle(Color.inkuText)

                    Text(background)
                        .font(.inkuBody)
                        .foregroundStyle(Color.inkuText)
                        .lineSpacing(InkuSpacing.spacing4)
                }
                .padding(InkuSpacing.spacing16)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.inkuSurface)
            .navigationTitle(L10n.MangaDetail.Background.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.Common.done, systemImage: "checkmark") {
                        dismiss()
                    }
                    .tint(Color.inkuAccentSoft)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Previews

#Preview {
    MangaBackgroundSheet(
        title: "One Piece",
        background: """
        Gol D. Roger was known as the "Pirate King," the strongest and most infamous being to have sailed the Grand Line. The capture and execution of Roger by the World Government brought a change throughout the world. His last words before his death revealed the existence of the greatest treasure in the world, One Piece.

        It was this revelation that brought about the Grand Age of Pirates, men who dreamed of finding One Piece—which promises an unlimited amount of riches and fame—and quite possibly the pinnacle of glory and the title of the Pirate King.

        Enter Monkey D. Luffy, a 17-year-old boy who defies your standard definition of a pirate. Rather than the popular persona of a wicked, hardened, toothless pirate ransacking villages for fun, Luffy's reason for being a pirate is one of pure wonder: the thought of an exciting adventure that leads him to intriguing people and ultimately, the promised treasure.
        """
    )
}
