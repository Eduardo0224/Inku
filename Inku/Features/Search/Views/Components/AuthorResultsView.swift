//
//  AuthorResultsView.swift
//  Inku
//
//  Created by Eduardo Andrade on 04/01/26.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2026 Eduardo Andrade. All rights reserved.
//

import SwiftUI
import InkuUI

struct AuthorResultsView: View {

    // MARK: - Properties

    let groupedAuthors: [(key: String, value: [Author])]
    let searchText: String

    // MARK: - Computed Properties

    private var title: String {
        let count = groupedAuthors.reduce(0) { $0 + $1.value.count }
        let resultWord = count == 1 ? L10n.Search.Results.singular : L10n.Search.Results.plural
        return "\(count) \(resultWord)"
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: InkuSpacing.spacing8) {
                HStack(spacing: InkuSpacing.spacing8) {
                    Image(systemName: "person.text.rectangle")
                        .font(.inkuHeadline)
                        .foregroundStyle(Color.inkuAccent)

                    Text(title)
                        .font(.inkuDisplayMedium)
                        .foregroundStyle(Color.inkuText)
                }

                if !searchText.isEmpty {
                    Text(L10n.Search.Results.forQuery(searchText))
                        .font(.inkuBodySmall)
                        .foregroundStyle(Color.inkuTextSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, InkuSpacing.spacing16)
            .padding(.top, InkuSpacing.spacing16)
            .padding(.bottom, InkuSpacing.spacing12)

            Divider()
                .background(Color.inkuTextTertiary.opacity(0.2))

            // Sectioned List
            List {
                ForEach(groupedAuthors, id: \.key) { section in
                    Section {
                        ForEach(section.value) { author in
                            InkuAuthorResultCard(
                                firstName: author.firstName,
                                lastName: author.lastName,
                                role: author.role
                            )
                            .listRowInsets(
                                EdgeInsets(
                                    top: InkuSpacing.spacing8,
                                    leading: InkuSpacing.spacing16,
                                    bottom: InkuSpacing.spacing8,
                                    trailing: InkuSpacing.spacing16
                                )
                            )
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                        }
                    } header: {
                        Text(section.key)
                            .font(.inkuHeadline)
                            .foregroundStyle(Color.inkuAccent)
                    }
                    .listSectionSpacing(InkuSpacing.spacing2)
                    .sectionIndexWith(label: section.key)
                }
            }
            .listStyle(.plain)
            .scrollDismissesKeyboard(.immediately)
            .scrollContentBackground(.hidden)
            .background(Color.inkuSurface)
        }
        .background(Color.inkuSurface)
    }
}

// MARK: - Previews

#Preview("Author Results") {
    AuthorResultsView(
        groupedAuthors: [
            ("A", [.testData, .testData]),
            ("B", [.testData])
        ],
        searchText: "Oda"
    )
}

#Preview("Author Results - Empty Search") {
    AuthorResultsView(
        groupedAuthors: [
            ("A", [.testData]),
            ("E", [.testData, .testData, .testData])
        ],
        searchText: ""
    )
}
