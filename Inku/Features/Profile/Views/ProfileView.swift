//
//  ProfileView.swift
//  Inku
//
//  Created by Eduardo Andrade on 30/01/26.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2025 Eduardo Andrade. All rights reserved.
//

import SwiftUI
import SwiftData
import InkuUI

struct ProfileView<T: AuthViewModelProtocol>: View {

    // MARK: - Query

    @Query private var localMangas: [CollectionManga]

    // MARK: - Environment

    @Environment(\.modelContext) private var modelContext
    @Environment(\.collectionViewModel) private var collectionViewModel

    // MARK: - States

    @State private var showingLogin = false
    @State private var showingRegistration = false
    @State private var isSyncListExpanded = true

    // MARK: - Properties

    @Bindable var authViewModel: T

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                Color.inkuSurface
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: InkuSpacing.spacing24) {
                        switch authViewModel.authState {
                        case .unauthenticated:
                            unauthenticatedContent
                                .frame(maxWidth: 600)
                        case .authenticated:
                            authenticatedContent
                                .frame(maxWidth: 600)
                        case .loading:
                            loadingContent
                        }
                    }
                    .padding(InkuSpacing.spacing24)
                }
                .scrollIndicators(.hidden)
                .navigationTitle(L10n.Tabs.profile)
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    if case .authenticated = authViewModel.authState {
                        ToolbarItem(placement: .topBarTrailing) {
                            accountMenu
                        }
                    }
                }
            }
        }
        .overlay {
            if authViewModel.isLoadingCloud {
                loadingOverlay
            }
        }
        .sheet(isPresented: $showingLogin) {
            NavigationStack {
                LoginView(
                    viewModel: authViewModel,
                    onSwitchToRegister: {
                        showingLogin = false
                        showingRegistration = true
                    }
                )
            }
            .interactiveDismissDisabled(authViewModel.isLoading)
        }
        .sheet(isPresented: $showingRegistration) {
            NavigationStack {
                RegistrationView(
                    viewModel: authViewModel,
                    onSwitchToLogin: {
                        showingRegistration = false
                        showingLogin = true
                    }
                )
            }
            .interactiveDismissDisabled(authViewModel.isLoading)
        }
        .alert(L10n.Profile.SessionExpired.title, isPresented: $authViewModel.showSessionExpiredAlert) {
            Button(L10n.Profile.SessionExpired.okButton, role: .cancel) {
                authViewModel.showSessionExpiredAlert = false
            }
        } message: {
            Text(L10n.Profile.SessionExpired.message)
        }
        .task {
            collectionViewModel.setModelContext(modelContext)
            await authViewModel.checkAuthenticationStatus()
        }
        .onChange(of: authViewModel.authState) { _, newValue in
            if case .authenticated = newValue {
                Task {
                    await authViewModel.fetchCloudCollection()
                    await authViewModel.downloadCloudToLocal(collectionViewModel: collectionViewModel)
                }
            } else {
                authViewModel.cloudMangaCount = 0
            }
        }
    }

    // MARK: - Private Views

    private var unauthenticatedContent: some View {
        VStack(spacing: InkuSpacing.spacing32) {
            headerSection
            localCollectionSection
            authButtonsSection
        }
    }

    private var authenticatedContent: some View {
        VStack(spacing: InkuSpacing.spacing24) {
            authenticatedHeaderSection
            syncStatusSection
        }
    }

    private var loadingContent: some View {
        VStack(spacing: InkuSpacing.spacing16) {
            ProgressView()
                .tint(.inkuAccent)

            Text(L10n.Common.loading)
                .font(.inkuBody)
                .foregroundStyle(Color.inkuTextSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var headerSection: some View {
        VStack(spacing: InkuSpacing.spacing16) {
            Image(systemName: "person.crop.circle")
                .font(.system(size: 80))
                .foregroundStyle(Color.inkuAccent)

            VStack(spacing: InkuSpacing.spacing8) {
                Text(L10n.Profile.Unauthenticated.title)
                    .font(.inkuBody)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.inkuText)

                Text(L10n.Profile.Unauthenticated.subtitle)
                    .font(.inkuBody)
                    .foregroundStyle(Color.inkuTextSecondary)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private var localCollectionSection: some View {
        VStack(alignment: .leading, spacing: InkuSpacing.spacing12) {
            Text(L10n.Profile.LocalCollection.title)
                .font(.inkuHeadline)
                .fontWeight(.semibold)
                .foregroundStyle(Color.inkuText)

            VStack(spacing: InkuSpacing.spacing12) {
                HStack(alignment: .top) {
                    Image(systemName: "iphone")
                        .font(.inkuIconMedium)
                        .foregroundStyle(Color.inkuAccent)

                    VStack(alignment: .leading, spacing: InkuSpacing.spacing4) {
                        Text(L10n.Profile.LocalCollection.saved)
                            .font(.inkuBody)
                            .foregroundStyle(Color.inkuTextSecondary)

                        Text(L10n.Profile.Sync.mangasCount(localMangas.count))
                            .font(.inkuCaption)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.inkuText)
                    }

                    Spacer()
                }
                .padding(InkuSpacing.spacing16)
                .background(Color.inkuSurfaceSecondary)
                .clipShape(RoundedRectangle(cornerRadius: InkuRadius.radius12))
            }
        }
    }

    private var authButtonsSection: some View {
        VStack(spacing: InkuSpacing.spacing12) {
            Button {
                showingLogin = true
            } label: {
                Text(L10n.Authentication.Login.button)
                    .font(.inkuBody)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.inkuTextOnAccent)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.inkuAccent)
                    .clipShape(RoundedRectangle(cornerRadius: InkuRadius.radius12))
            }

            Button {
                showingRegistration = true
            } label: {
                Text(L10n.Authentication.Register.button)
                    .font(.inkuBody)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.inkuAccent)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.inkuSurfaceSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: InkuRadius.radius12))
                    .overlay {
                        RoundedRectangle(cornerRadius: InkuRadius.radius12)
                            .stroke(Color.inkuAccent, lineWidth: 2)
                    }
            }
        }
    }

    private var authenticatedHeaderSection: some View {
        VStack(spacing: InkuSpacing.spacing16) {
            ZStack {
                Circle()
                    .fill(Color.inkuAccent)
                    .frame(width: 80, height: 80)

                Text(authViewModel.email.prefix(1).uppercased())
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundStyle(Color.inkuTextOnAccent)
            }

            VStack(spacing: InkuSpacing.spacing4) {
                Text(L10n.Profile.Authenticated.welcome)
                    .font(.inkuBody)
                    .foregroundStyle(Color.inkuTextSecondary)

                Text(authViewModel.email)
                    .font(.inkuBody)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.inkuText)
            }
        }
    }

    private var syncStatusSection: some View {
        VStack(alignment: .leading, spacing: InkuSpacing.spacing12) {
            Text(L10n.Profile.Sync.title)
                .font(.inkuHeadline)
                .fontWeight(.semibold)
                .foregroundStyle(Color.inkuText)

            VStack(spacing: InkuSpacing.spacing12) {
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

                let mangasToSync = localMangas.filter { !authViewModel.cloudMangaIds.contains($0.mangaId) }

                if !mangasToSync.isEmpty {
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

                Button {
                    Task {
                        await authViewModel.fullSync(collectionViewModel: collectionViewModel)
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

                if let syncProgress = authViewModel.syncProgress {
                    Text(syncProgress)
                        .font(.inkuCaption)
                        .foregroundStyle(Color.inkuTextSecondary)
                        .multilineTextAlignment(.center)
                }
            }
        }
    }

    private var accountMenu: some View {
        Menu {
            if !authViewModel.email.isEmpty {
                Label(authViewModel.email, systemImage: "\(authViewModel.email.prefix(1)).circle")
                    .symbolVariant(.fill)
                    .foregroundStyle(Color.inkuTextSecondary)
            }

            Divider()

            VStack {
                Button(role: .destructive) {
                    Task {
                        await authViewModel.logout()
                    }
                } label: {
                    Label(L10n.Authentication.Actions.logout, systemImage: "arrow.right.square")
                }
                .buttonStyle(.bordered)

                Text(L10n.Profile.version(appVersion))
                    .font(.inkuCaptionSmall)
                    .foregroundStyle(Color.inkuTextSecondary)
            }

        } label: {
            Image(systemName: "info")
                .symbolVariant(.circle)
                .foregroundStyle(Color.inkuAccent)
        }
        .menuActionDismissBehavior(.enabled)
        .menuStyle(.button)
        .disabled(authViewModel.isSyncing || authViewModel.isLoadingCloud)
    }

    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            VStack(spacing: InkuSpacing.spacing16) {
                ProgressView()
                    .tint(Color.inkuAccent)
                    .scaleEffect(1.2)

                Text(L10n.Profile.Loading.cloudCollection)
                    .font(.inkuBody)
                    .foregroundStyle(Color.inkuText)
            }
            .padding(InkuSpacing.spacing32)
            .background(Color.inkuSurfaceSecondary)
            .clipShape(RoundedRectangle(cornerRadius: InkuRadius.radius16))
            .shadow(radius: 20)
        }
    }

    // MARK: - Computed Properties

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}

// MARK: - Preview

#Preview("Unauthenticated") {
    @Previewable @State var viewModel: MockAuthViewModel = .unauthenticated
    ProfileView(authViewModel: viewModel)
        .modelContainer(for: CollectionManga.self, inMemory: true)
}

#Preview("Authenticated") {
    @Previewable @State var viewModel: MockAuthViewModel = .authenticated
    ProfileView(authViewModel: viewModel)
        .modelContainer(for: CollectionManga.self, inMemory: true)
}
