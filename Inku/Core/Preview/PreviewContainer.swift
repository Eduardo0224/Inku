//
//  PreviewContainer.swift
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
import SwiftData

struct PreviewContainer: PreviewModifier {

    // MARK: - Types

    enum DataContent {
        case empty
        case withData
    }

    // MARK: - Properties

    static var dataContent = DataContent.empty

    // MARK: - Functions

    static func makeSharedContext() async throws -> ModelContainer {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: CollectionManga.self, configurations: configuration)

        if case .withData = dataContent {
            let sampleMangas: [CollectionManga] = .previewData
            for manga in sampleMangas {
                container.mainContext.insert(manga)
            }
        }

        return container
    }

    func body(content: Content, context: ModelContainer) -> some View {
        content
            .modelContainer(context)
    }
}

// MARK: - PreviewTrait Extension

extension PreviewTrait where T == Preview.ViewTraits {

    @MainActor
    static func previewContainer(_ dataContent: PreviewContainer.DataContent) -> Self {
        PreviewContainer.dataContent = dataContent
        return .modifier(PreviewContainer())
    }
}
