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
                            UnauthenticatedSection(
                                localMangasCount: localMangas.count,
                                onLoginTapped: {
                                    showingLogin = true
                                },
                                onRegisterTapped: {
                                    showingRegistration = true
                                }
                            )
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
                #if os(iOS)
                .navigationBarTitleDisplayMode(.large)
                #endif
                .toolbar {
                    #if os(iOS)
                    if case .authenticated = authViewModel.authState {
                        ToolbarItem(placement: .topBarTrailing) {
                            accountMenu
                        }
                    }
                    #else
                    if case .authenticated = authViewModel.authState {
                        ToolbarItem(placement: .automatic) {
                            accountMenu
                        }
                    }
                    #endif
                }
            }
        }
        .overlay {
            if authViewModel.isLoadingCloud && !authViewModel.isSyncing {
                ProfileLoadingOverlay()
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
            authViewModel.setCollectionViewModel(collectionViewModel)
            await authViewModel.checkAuthenticationStatus()
        }
        .onChange(of: authViewModel.authState) { _, newValue in
            if case .authenticated = newValue {
                Task {
                    await authViewModel.fetchCloudCollection()
                    await authViewModel.downloadCloudToLocal()
                }
            } else {
                authViewModel.cloudMangaCount = 0
            }
        }
    }

    // MARK: - Private Views

    private var authenticatedContent: some View {
        VStack(spacing: InkuSpacing.spacing24) {
            AuthenticatedHeaderSection(email: authViewModel.email)
            SyncStatusSection(
                isSyncListExpanded: $isSyncListExpanded,
                localMangas: localMangas,
                authViewModel: authViewModel
            )
        }
    }

    private var loadingContent: some View {
        InkuLoadingView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
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

                Text(L10n.Profile.version(Bundle.appVersion))
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
