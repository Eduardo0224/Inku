//
//  MultiSelectFilterView.swift
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

struct MultiSelectFilterView: View {

    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss

    // MARK: - Bindings

    @Binding var selectedItems: Set<String>

    // MARK: - Properties

    let title: String
    let options: [String]
    let icon: String

    // MARK: - States

    @State private var searchText: String = ""

    // MARK: - Computed Properties

    private var filteredOptions: [String] {
        if searchText.isEmpty {
            return options
        }
        return options.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredOptions, id: \.self) { option in
                    MultiSelectRow(
                        option: option,
                        isSelected: selectedItems.contains(option)
                    ) {
                        toggleSelection(for: option)
                    }
                }
            }
            .searchable(
                text: $searchText,
                prompt: Text("Search \(title.lowercased())")
            )
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                            .fontWeight(.semibold)
                    }
                }
            }
            .overlay {
                if filteredOptions.isEmpty {
                    ContentUnavailableView {
                        Label("No results", systemImage: "magnifyingglass")
                    } description: {
                        Text("Try a different search term")
                    }
                }
            }
        }
    }

    // MARK: - Private Functions

    private func toggleSelection(for option: String) {
        if selectedItems.contains(option) {
            selectedItems.remove(option)
        } else {
            selectedItems.insert(option)
        }
    }
}

// MARK: - MultiSelectRow

private struct MultiSelectRow: View {

    // MARK: - Properties

    let option: String
    let isSelected: Bool
    let action: () -> Void

    // MARK: - Body

    var body: some View {
        Button(action: action) {
            HStack {
                Text(option)
                    .foregroundStyle(.primary)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(Color.inkuAccent)
                        .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Previews

#Preview("With Selection") {
    @Previewable @State var selectedItems: Set<String> = ["Action", "Adventure"]
    MultiSelectFilterView(
        selectedItems: $selectedItems,
        title: "Genres",
        options: ["Action", "Adventure", "Comedy", "Drama", "Fantasy"],
        icon: "theatermasks.fill"
    )
}

#Preview("Demographics") {
    @Previewable @State var selectedItems: Set<String> = ["Shounen"]
    MultiSelectFilterView(
        selectedItems: $selectedItems,
        title: "Demographics",
        options: ["Shounen", "Shoujo", "Seinen", "Kids", "Josei"],
        icon: "person.3.fill"
    )
}
