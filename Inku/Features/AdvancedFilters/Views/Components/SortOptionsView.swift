//
//  SortOptionsView.swift
//  Inku
//
//  Created by Eduardo Andrade on 26/01/26.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2026 Eduardo Andrade. All rights reserved.
//

import SwiftUI
import InkuUI

struct SortOptionsView: View {

    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss

    // MARK: - Bindings

    @Binding var selectedOption: SearchSortOption

    // MARK: - Body

    var body: some View {
        NavigationStack {
            List {
                ForEach(SearchSortOption.allCases) { option in
                    SortOptionRow(
                        option: option,
                        isSelected: selectedOption == option
                    ) {
                        selectedOption = option
                        dismiss()
                    }
                }
            }
            .navigationTitle(L10n.AdvancedFilters.Sort.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.AdvancedFilters.MultiSelect.cancel) {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - SortOptionRow

private struct SortOptionRow: View {

    // MARK: - Properties

    let option: SearchSortOption
    let isSelected: Bool
    let action: () -> Void

    // MARK: - Body

    var body: some View {
        Button(action: action) {
            HStack(spacing: InkuSpacing.spacing12) {
                Image(systemName: option.iconName)
                    .foregroundStyle(Color.inkuAccent)
                    .frame(width: 24)

                Text(option.displayName)
                    .foregroundStyle(.primary)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .symbolVariant(.circle.fill)
                        .foregroundStyle(Color.inkuAccent)
                        .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Previews

#Preview("Sort Options - Score Selected") {
    @Previewable @State var selectedOption: SearchSortOption = .scoreDescending
    SortOptionsView(selectedOption: $selectedOption)
}

#Preview("Sort Options - Title Selected") {
    @Previewable @State var selectedOption: SearchSortOption = .titleAscending
    SortOptionsView(selectedOption: $selectedOption)
}

#Preview("Sort Options - Volumes Selected") {
    @Previewable @State var selectedOption: SearchSortOption = .volumesDescending
    SortOptionsView(selectedOption: $selectedOption)
}
