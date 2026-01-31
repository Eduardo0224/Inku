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

    // MARK: - States

    @State private var showingLogin = false
    @State private var showingRegistration = false

    // MARK: - Properties

    @Bindable var authViewModel: T

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: InkuSpacing.spacing24) {
                    switch authViewModel.authState {
                    case .unauthenticated:
                        unauthenticatedContent
                    case .authenticated:
                        authenticatedContent
                    case .loading:
                        loadingContent
                    }
                }
                .padding(InkuSpacing.spacing24)
            }
            .background(Color.inkuSurface)
            .navigationTitle(L10n.Tabs.profile)
            .navigationBarTitleDisplayMode(.large)
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
        .task {
            await authViewModel.checkAuthenticationStatus()
        }
        .onChange(of: authViewModel.authState) { _, newValue in
            if case .authenticated = newValue {
                Task {
                    await authViewModel.fetchCloudCollection()
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
            accountSection
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

                        Text("\(localMangas.count) mangas")
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

                            Text("Local")
                                .font(.inkuBody)
                                .foregroundStyle(Color.inkuTextSecondary)
                        }

                        Text("\(localMangas.count) mangas")
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

                            Text("Cloud")
                                .font(.inkuBody)
                                .foregroundStyle(Color.inkuTextSecondary)
                        }

                        Text("\(authViewModel.cloudMangaCount) mangas")
                            .font(.inkuCaption)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.inkuText)
                    }
                }
                .padding(InkuSpacing.spacing16)
                .background(Color.inkuSurfaceSecondary)
                .clipShape(RoundedRectangle(cornerRadius: InkuRadius.radius12))

                Button {
                    // TODO: Implement sync functionality
                } label: {
                    Text(L10n.Profile.Sync.button)
                        .font(.inkuBody)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.inkuTextOnAccent)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.inkuAccent)
                        .clipShape(RoundedRectangle(cornerRadius: InkuRadius.radius12))
                }
            }
        }
    }

    private var accountSection: some View {
        VStack(alignment: .leading, spacing: InkuSpacing.spacing12) {
            Text(L10n.Profile.Section.account)
                .font(.inkuHeadline)
                .fontWeight(.semibold)
                .foregroundStyle(Color.inkuText)

            Button {
                Task {
                    await authViewModel.logout()
                }
            } label: {
                HStack {
                    Image(systemName: "arrow.right.square")
                        .font(.inkuBody)
                        .foregroundStyle(Color.red)

                    Text(L10n.Authentication.Actions.logout)
                        .font(.inkuBody)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.red)

                    Spacer()
                }
                .padding(InkuSpacing.spacing16)
                .background(Color.inkuSurfaceSecondary)
                .clipShape(RoundedRectangle(cornerRadius: InkuRadius.radius12))
            }
        }
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
