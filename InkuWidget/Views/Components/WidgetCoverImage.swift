//
//  WidgetCoverImage.swift
//  Inku
//
//  Created by Eduardo Andrade on 10/02/26.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2026 Eduardo Andrade. All rights reserved.

import SwiftUI
import InkuUI

struct WidgetCoverImage: View {

    // MARK: - Properties

    let imageData: Data?
    let url: URL?
    let cornerRadius: CGFloat

    // MARK: - Body

    var body: some View {
        if let imageData {
            #if os(iOS) || os(visionOS)
            if let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                    .shadow(color: .black.opacity(0.2), radius: 10)
            } else {
                placeholderView
                    .shadow(color: .black.opacity(0.2), radius: 10)
            }
            #elseif os(macOS)
            if let nsImage = NSImage(data: imageData) {
                Image(nsImage: nsImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                    .shadow(color: .black.opacity(0.2), radius: 10)
            } else {
                placeholderView
                    .shadow(color: .black.opacity(0.2), radius: 10)
            }
            #endif
        } else {
            placeholderView
                .shadow(color: .black.opacity(0.2), radius: 10)
        }
    }

    // MARK: - Private Views

    private var placeholderView: some View {
        Rectangle()
            .fill(Color.inkuSurfaceSecondary)
            .overlay {
                Image(systemName: "book.closed")
                    .foregroundStyle(Color.inkuTextTertiary)
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }

    private var errorView: some View {
        Rectangle()
            .fill(Color.inkuSurfaceSecondary)
            .overlay {
                VStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.caption)
                    Text("Error")
                        .font(.caption2)
                }
                .foregroundStyle(Color.inkuTextTertiary)
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}
