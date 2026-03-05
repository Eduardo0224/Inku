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
    @Environment(AuthViewModel.self) private var authViewModel

    // MARK: - Properties

    let collectionManga: CollectionManga

    // MARK: - States

    @State private var volumesOwnedCount: Int
    @State private var currentReadingVolume: String
    @State private var hasCompleteCollection: Bool
    @State private var isUpdating: Bool = false

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
            #if os(macOS)
            .formStyle(.grouped)
            #endif
            .scrollContentBackground(.hidden)
            .background(Color.inkuSurface)
            .navigationTitle(L10n.Collection.Edit.title)
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                toolbarContent
            }
            .alert(
                L10n.Error.title,
                isPresented: .constant(viewModel?.errorMessage != nil),
                presenting: viewModel?.errorMessage
            ) { _ in
                Button(L10n.Common.ok, role: .cancel) {
                    viewModel?.clearError()
                }
            } message: { errorMessage in
                Text(errorMessage)
            }
            .overlay {
                if isUpdating {
                    loadingOverlay
                }
            }
        }
    }

    // MARK: - Private Views

    private var mangaInfoSection: some View {
        Section {
            HStack(spacing: InkuSpacing.spacing12) {
                if let url = collectionManga.coverURL {
                    InkuCoverImage(url: url, cornerRadius: InkuRadius.radius8, maxWidth: 60)
                        .frame(width: 60, height: 90)
                } else {
                    Rectangle()
                        .fill(Color.inkuSurfaceSecondary)
                        .frame(width: 60, height: 90)
                        .clipShape(RoundedRectangle(cornerRadius: InkuRadius.radius8))
                }

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
            Stepper(
                L10n.Collection.Edit.volumesOwned(volumesOwnedCount),
                value: $volumesOwnedCount,
                in: 0...999
            )
            .listRowBackground(Color.inkuSurfaceElevated)

            HStack {
                Text(L10n.Collection.Edit.currentVolume)
                    .foregroundStyle(Color.inkuText)

                Spacer()

                TextField(
                    L10n.Collection.Edit.volumePlaceholder,
                    text: $currentReadingVolume
                )
                #if os(iOS)
                .keyboardType(.numberPad)
                #endif
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: 100)
            }
            .listRowBackground(Color.inkuSurfaceElevated)

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
            .fontWeight(.medium)
            .tint(Color.inkuAccentStrong)
        }
    }

    // MARK: - Private Views

    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            InkuLoadingView(message: L10n.Common.updating)
                .padding(InkuSpacing.spacing32)
                .background {
                    RoundedRectangle(cornerRadius: InkuRadius.radius16)
                        .fill(.regularMaterial)
                }
                .frame(width: 150, height: 150)
        }
    }

    // MARK: - Private Functions

    private func saveChanges() {
        collectionManga.volumesOwnedCount = volumesOwnedCount
        collectionManga.currentReadingVolume = Int(currentReadingVolume)
        collectionManga.hasCompleteCollection = hasCompleteCollection

        isUpdating = true

        Task {
            do {
                try await authViewModel.updateMangaInCollection(collectionManga)
                dismiss()
            } catch {
                viewModel?.setError(error.localizedDescription)
            }
            isUpdating = false
        }
    }
}

// MARK: - Previews

#Preview("Edit Collection - Reading") {
    @Previewable @State var authViewModel = AuthViewModel()
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
    .environment(authViewModel)
}

#Preview("Edit Collection - Complete") {
    @Previewable @State var authViewModel = AuthViewModel()
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
    .environment(authViewModel)
}

#Preview("Edit Collection - No Image") {
    @Previewable @State var authViewModel = AuthViewModel()
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
    .environment(authViewModel)
}
