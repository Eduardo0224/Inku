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
            ScrollView {
                VStack(alignment: .leading, spacing: InkuSpacing.spacing16) {
                    if !filteredOptions.isEmpty {
                        FlowLayout(spacing: InkuSpacing.spacing8) {
                            ForEach(filteredOptions, id: \.self) { option in
                                InkuBadge(
                                    text: option,
                                    style: selectedItems.contains(option) ? .accent : .secondary
                                )
                                .onTapGesture {
                                    toggleSelection(for: option)
                                }
                            }
                        }
                        .padding(InkuSpacing.spacing16)
                    } else {
                        InkuEmptyView(
                            icon: "magnifyingglass",
                            iconSize: .medium,
                            title: L10n.AdvancedFilters.MultiSelect.noResults,
                            subtitle: L10n.AdvancedFilters.MultiSelect.tryDifferent
                        )
                        .padding(InkuSpacing.spacing32)
                    }
                }
            }
            .background(Color.inkuSurface)
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
                        Text(L10n.AdvancedFilters.MultiSelect.cancel)
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text(L10n.AdvancedFilters.MultiSelect.done)
                            .fontWeight(.semibold)
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

// MARK: - Flow Layout

private struct FlowLayout: Layout {

    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            let position = CGPoint(
                x: bounds.minX + result.positions[index].x,
                y: bounds.minY + result.positions[index].y
            )
            subview.place(at: position, proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }

                positions.append(CGPoint(x: x, y: y))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }

            self.size = CGSize(width: maxWidth, height: y + lineHeight)
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
