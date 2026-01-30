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

struct ProfileView: View {

    // MARK: - Properties

    @Bindable var authViewModel: AuthViewModel

    // MARK: - States

    @State private var showingLogin = false
    @State private var showingRegistration = false

    // MARK: - Environment

    @Environment(\.collectionViewModel) private var collectionViewModel
    @Query private var localMangas: [CollectionManga]

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
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            showingRegistration = true
                        }
                    }
                )
            }
        }
        .sheet(isPresented: $showingRegistration) {
            NavigationStack {
                RegistrationView(
                    viewModel: authViewModel,
                    onSwitchToLogin: {
                        showingRegistration = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            showingLogin = true
                        }
                    }
                )
            }
        }
        .task {
            await authViewModel.checkAuthenticationStatus()
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
        .padding(.top, InkuSpacing.spacing32)
    }

    private var localCollectionSection: some View {
        VStack(alignment: .leading, spacing: InkuSpacing.spacing12) {
            Text(L10n.Profile.LocalCollection.title)
                .font(.inkuHeadline)
                .fontWeight(.semibold)
                .foregroundStyle(Color.inkuText)

            VStack(spacing: InkuSpacing.spacing12) {
                HStack {
                    Image(systemName: "iphone")
                        .font(.inkuCaption)
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
        .padding(.top, InkuSpacing.spacing32)
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

                        Text("-- mangas")
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
    ProfileView(authViewModel: AuthViewModel(interactor: MockAuthInteractor()))
        .environment(\.collectionViewModel, MockCollectionViewModel.empty)
//        .modelContainer(for: CollectionManga.self, inMemory: true)
}

#Preview("Authenticated") {
    let viewModel = AuthViewModel(interactor: MockAuthInteractor())

    ProfileView(authViewModel: viewModel)
        .environment(\.collectionViewModel, MockCollectionViewModel.withData)
//        .modelContainer(for: CollectionManga.self, inMemory: true)
        .task {
            await viewModel.login()
        }
}
