//
//  EditCollectionSheet.swift
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

struct EditCollectionSheet: View {

    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss
    @Environment(\.collectionViewModel) private var viewModel

    // MARK: - Properties

    let collectionManga: CollectionManga

    // MARK: - States

    @State private var volumesOwnedCount: Int
    @State private var currentReadingVolume: String
    @State private var hasCompleteCollection: Bool

    // MARK: - Initializers

    init(collectionManga: CollectionManga) {
        self.collectionManga = collectionManga

        _volumesOwnedCount = State(initialValue: collectionManga.volumesOwnedCount)
        _currentReadingVolume = State(initialValue: collectionManga.currentReadingVolume?.description ?? "")
        _hasCompleteCollection = State(initialValue: collectionManga.hasCompleteCollection)
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                mangaInfoSection
                collectionDataSection
            }
            .scrollContentBackground(.hidden)
            .background(Color.inkuSurface)
            .navigationTitle(L10n.Collection.Edit.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarContent
            }
        }
    }

    // MARK: - Private Views

    private var mangaInfoSection: some View {
        Section {
            HStack(spacing: InkuSpacing.spacing12) {
                // Cover
                if let url = collectionManga.coverURL {
                    InkuCoverImage(url: url, cornerRadius: InkuRadius.radius8)
                        .frame(width: 60, height: 90)
                } else {
                    Rectangle()
                        .fill(Color.inkuSurfaceSecondary)
                        .frame(width: 60, height: 90)
                        .clipShape(RoundedRectangle(cornerRadius: InkuRadius.radius8))
                }

                // Title
                VStack(alignment: .leading, spacing: InkuSpacing.spacing4) {
                    Text(collectionManga.title)
                        .font(.inkuHeadline)
                        .foregroundStyle(Color.inkuText)

                    if let total = collectionManga.totalVolumes {
                        Text(L10n.Collection.Edit.totalVolumes(total))
                            .font(.inkuCaption)
                            .foregroundStyle(Color.inkuTextSecondary)
                    }
                }
            }
            .listRowBackground(Color.inkuSurfaceElevated)
        }
    }

    private var collectionDataSection: some View {
        Section {
            // Volumes Owned
            Stepper(
                L10n.Collection.Edit.volumesOwned(volumesOwnedCount),
                value: $volumesOwnedCount,
                in: 0...999
            )
            .listRowBackground(Color.inkuSurfaceElevated)

            // Current Reading Volume
            HStack {
                Text(L10n.Collection.Edit.currentVolume)
                    .foregroundStyle(Color.inkuText)

                Spacer()

                TextField(
                    L10n.Collection.Edit.volumePlaceholder,
                    text: $currentReadingVolume
                )
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: 100)
            }
            .listRowBackground(Color.inkuSurfaceElevated)

            // Complete Collection Toggle
            Toggle(
                L10n.Collection.Edit.completeCollection,
                isOn: $hasCompleteCollection
            )
            .listRowBackground(Color.inkuSurfaceElevated)
        } header: {
            Text(L10n.Collection.Edit.sectionTitle)
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(L10n.Common.cancel) {
                dismiss()
            }
        }

        ToolbarItem(placement: .confirmationAction) {
            Button(L10n.Common.done) {
                saveChanges()
            }
        }
    }

    // MARK: - Private Functions

    private func saveChanges() {
        // Update manga properties
        collectionManga.volumesOwnedCount = volumesOwnedCount
        collectionManga.currentReadingVolume = Int(currentReadingVolume)
        collectionManga.hasCompleteCollection = hasCompleteCollection

        // Persist changes through viewModel
        do {
            try viewModel.updateCollection(collectionManga)
            dismiss()
        } catch {
            print("[EditCollectionSheet] Error saving changes: \(error)")
        }
    }
}

// MARK: - Previews

#Preview("Edit Collection - Reading") {
    EditCollectionSheet(
        collectionManga: CollectionManga(
            mangaId: 1,
            title: "One Piece",
            coverImageURL: "https://cdn.myanimelist.net/images/manga/3/216460.jpg",
            totalVolumes: 106,
            volumesOwnedCount: 50,
            currentReadingVolume: 51,
            hasCompleteCollection: false
        )
    )
    .environment(\.collectionViewModel, MockCollectionViewModel.empty)
}

#Preview("Edit Collection - Complete") {
    EditCollectionSheet(
        collectionManga: CollectionManga(
            mangaId: 2,
            title: "Naruto",
            coverImageURL: "https://cdn.myanimelist.net/images/manga/3/249658.jpg",
            totalVolumes: 72,
            volumesOwnedCount: 72,
            currentReadingVolume: nil,
            hasCompleteCollection: true
        )
    )
    .environment(\.collectionViewModel, MockCollectionViewModel.empty)
}

#Preview("Edit Collection - No Image") {
    EditCollectionSheet(
        collectionManga: CollectionManga(
            mangaId: 3,
            title: "Ongoing Series Without Cover",
            coverImageURL: nil,
            totalVolumes: nil,
            volumesOwnedCount: 15,
            currentReadingVolume: 16,
            hasCompleteCollection: false
        )
    )
    .environment(\.collectionViewModel, MockCollectionViewModel.empty)
}
