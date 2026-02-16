//
//  FilterDisclosureSection.swift
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

struct FilterDisclosureSection: View {

    // MARK: - Properties

    let title: String
    let icon: String
    let options: [String]
    @Binding var selectedItems: Set<String>
    @Binding var isExpanded: Bool

    // MARK: - Body

    var body: some View {
        if !options.isEmpty {
            DisclosureGroup(
                isExpanded: $isExpanded,
                content: {
                    FlowLayout(spacing: InkuSpacing.spacing8) {
                        ForEach(options, id: \.self) { option in
                            InkuBadge(
                                text: option,
                                style: selectedItems.contains(option) ? .accent : .secondary,
                                size: .medium
                            )
                            #if os(visionOS)
                            .scaleHoverEffect(value: 1.13)
                            #endif
                            .onTapGesture {
                                toggleSelection(for: option)
                            }
                        }
                    }
                    .padding(.vertical, InkuSpacing.spacing8)
                },
                label: {
                    HStack {
                        Image(systemName: icon)
                            .foregroundStyle(Color.inkuText)
                            .frame(width: 24)

                        Text(title)
                            .foregroundStyle(Color.inkuText)

                        Spacer()

                        if selectedItems.count > 0 {
                            Text("\(selectedItems.count)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .padding(.horizontal, InkuSpacing.spacing8)
                                .padding(.vertical, InkuSpacing.spacing4)
                                .background(Color.inkuAccentStrong)
                                .cornerRadius(InkuRadius.radius8)
                        }
                    }
                }
            )
            .accentColor(Color.inkuText)
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

#Preview("Expanded - With Selections", traits: .sizeThatFitsLayout) {
    @Previewable @State var selectedItems: Set<String> = ["Action", "Fantasy", "Shounen"]
    @Previewable @State var isExpanded: Bool = true

    FilterDisclosureSection(
        title: "Genres",
        icon: "theatermasks.fill",
        options: ["Action", "Adventure", "Comedy", "Drama", "Fantasy", "Romance", "Sci-Fi", "Shounen"],
        selectedItems: $selectedItems,
        isExpanded: $isExpanded
    )
    .padding(InkuSpacing.spacing16)
    .background(Color.inkuSurface)
    .inkuCard()
    .padding(InkuSpacing.spacing16)
}

#Preview("Expanded - No Selections", traits: .sizeThatFitsLayout) {
    @Previewable @State var selectedItems: Set<String> = []
    @Previewable @State var isExpanded: Bool = true

    FilterDisclosureSection(
        title: "Demographics",
        icon: "person.3.fill",
        options: ["Shounen", "Shoujo", "Seinen", "Josei"],
        selectedItems: $selectedItems,
        isExpanded: $isExpanded
    )
    .padding(InkuSpacing.spacing16)
    .background(Color.inkuSurface)
    .inkuCard()
    .padding(InkuSpacing.spacing16)
}

#Preview("Collapsed - With Selections", traits: .sizeThatFitsLayout) {
    @Previewable @State var selectedItems: Set<String> = ["Pirates", "Super Power"]
    @Previewable @State var isExpanded: Bool = false

    FilterDisclosureSection(
        title: "Themes",
        icon: "tag.fill",
        options: ["Pirates", "Super Power", "School", "Magic", "Sports"],
        selectedItems: $selectedItems,
        isExpanded: $isExpanded
    )
    .padding(InkuSpacing.spacing16)
    .background(Color.inkuSurface)
    .inkuCard()
    .padding(InkuSpacing.spacing16)
}

#Preview("Collapsed - No Selections", traits: .sizeThatFitsLayout) {
    @Previewable @State var selectedItems: Set<String> = []
    @Previewable @State var isExpanded: Bool = false

    FilterDisclosureSection(
        title: "Genres",
        icon: "theatermasks.fill",
        options: ["Action", "Adventure", "Comedy"],
        selectedItems: $selectedItems,
        isExpanded: $isExpanded
    )
    .padding(InkuSpacing.spacing16)
    .background(Color.inkuSurface)
    .inkuCard()
    .padding(InkuSpacing.spacing16)
}
