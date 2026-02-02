//
//  SyncStatusSection.swift
//  Inku
//
//  Created by Eduardo Andrade on 01/02/26.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2026 Eduardo Andrade. All rights reserved.
//

import SwiftUI
import InkuUI

struct SyncStatusSection<T: AuthViewModelProtocol>: View {

    // MARK: - Bindings

    @Binding var isSyncListExpanded: Bool

    // MARK: - Properties

    let localMangas: [CollectionManga]
    @Bindable var authViewModel: T

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: InkuSpacing.spacing12) {
            Text(L10n.Profile.Sync.title)
                .font(.inkuHeadline)
                .fontWeight(.semibold)
                .foregroundStyle(Color.inkuText)

            VStack(spacing: InkuSpacing.spacing12) {
                syncCountsCard

                let mangasToSync = localMangas.filter { !authViewModel.cloudMangaIds.contains($0.mangaId) }

                if !mangasToSync.isEmpty && !authViewModel.cloudMangaIds.isEmpty {
                    mangasToSyncList(mangasToSync)
                }

                syncButton

                if let syncProgress = authViewModel.syncProgress {
                    Text(syncProgress)
                        .font(.inkuCaption)
                        .foregroundStyle(Color.inkuTextSecondary)
                        .multilineTextAlignment(.center)
                }
            }
        }
    }

    // MARK: - Private Views

    private var syncCountsCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: InkuSpacing.spacing8) {
                HStack {
                    Image(systemName: "iphone")
                        .font(.inkuBody)
                        .foregroundStyle(Color.inkuAccent)

                    Text(L10n.Profile.Labels.local)
                        .font(.inkuBody)
                        .foregroundStyle(Color.inkuTextSecondary)
                }

                Text(L10n.Profile.Sync.mangasCount(localMangas.count))
                    .font(.inkuCaption)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.inkuText)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: InkuSpacing.spacing8) {
                HStack {
                    Image(systemName: "cloud")
                        .font(.inkuBody)
                        .foregroundStyle(Color.inkuAccent)

                    Text(L10n.Profile.Labels.cloud)
                        .font(.inkuBody)
                        .foregroundStyle(Color.inkuTextSecondary)
                }

                Text(L10n.Profile.Sync.mangasCount(authViewModel.cloudMangaCount))
                    .font(.inkuCaption)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.inkuText)
            }
        }
        .padding(InkuSpacing.spacing16)
        .background(Color.inkuSurfaceSecondary)
        .clipShape(RoundedRectangle(cornerRadius: InkuRadius.radius12))
    }

    private func mangasToSyncList(_ mangasToSync: [CollectionManga]) -> some View {
        DisclosureGroup(isExpanded: $isSyncListExpanded) {
            VStack(spacing: 0) {
                ForEach(Array(mangasToSync.enumerated()), id: \.element.mangaId) { index, manga in
                    let status = authViewModel.syncStatuses[manga.mangaId] ?? .pending

                    SyncMangaRow(manga: manga, status: status)

                    if index < mangasToSync.count - 1 {
                        Divider()
                            .background(Color.inkuTextSecondary.opacity(0.2))
                    }
                }
            }
            .background(Color.inkuSurfaceSecondary)
            .clipShape(RoundedRectangle(cornerRadius: InkuRadius.radius12))
        } label: {
            HStack {
                Text(L10n.Profile.Sync.mangasToSync)
                    .font(.inkuCaption)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.inkuTextSecondary)

                Spacer()

                Text("\(mangasToSync.count)")
                    .font(.inkuCaption)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.inkuAccent)
            }
        }
        .tint(Color.inkuAccent)
    }

    private var syncButton: some View {
        Button {
            Task {
                await authViewModel.fullSync()
            }
        } label: {
            HStack {
                if authViewModel.isSyncing {
                    ProgressView()
                        .tint(Color.inkuTextOnAccent)
                }

                Text(authViewModel.isSyncing ? L10n.Common.loading : L10n.Profile.Sync.button)
                    .font(.inkuBody)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.inkuTextOnAccent)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(authViewModel.isSyncing ? Color.inkuAccent.opacity(0.6) : Color.inkuAccent)
            .clipShape(RoundedRectangle(cornerRadius: InkuRadius.radius12))
        }
        .disabled(authViewModel.isSyncing || authViewModel.isLoadingCloud)
    }
}

// MARK: - Preview

#Preview(
    "With Mangas to Sync",
    traits: .sizeThatFitsLayout
) {
    @Previewable @State var isSyncListExpanded = true

    let collectionViewModel = MockCollectionViewModel()
    let authViewModel: MockAuthViewModel = {
        let viewModel = MockAuthViewModel.authenticated
        viewModel.cloudMangaIds = [2]
        viewModel.cloudMangaCount = 1
        viewModel.setCollectionViewModel(collectionViewModel)
        return viewModel
    }()

    SyncStatusSection(
        isSyncListExpanded: $isSyncListExpanded,
        localMangas: .previewData,
        authViewModel: authViewModel
    )
    .padding()
    .background(Color.inkuSurface)
}
