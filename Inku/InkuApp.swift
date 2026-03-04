//
//  InkuApp.swift
//  Inku
//
//  Created by Eduardo Andrade on 20/12/25.
//

import SwiftUI
import SwiftData
import InkuUI
import os

@main
struct InkuApp: App {

    // MARK: - Private Properties

    @AppStorage("hasSeededAppToken") private var hasSeededAppToken = false

    // MARK: - States

    @State private var collectionViewModel = CollectionViewModel()
    @State private var authViewModel = AuthViewModel(syncMessageDelay: .seconds(2))
    @State private var selectedTab: AppTab = .browse

    // MARK: - Body

    var body: some Scene {
        WindowGroup {
            if let modelContainer = SharedModelContainer.shared {
                TabView(selection: $selectedTab) {
                    Tab(L10n.Tabs.browse, systemImage: "books.vertical", value: .browse) {
                        MangaListView()
                    }

                    Tab(L10n.Tabs.collection, systemImage: "bookmark", value: .collection) {
                        CollectionView()
                    }

                    Tab(L10n.Tabs.search, systemImage: "magnifyingglass", value: .search, role: .search) {
                        SearchView()
                    }

                    Tab(L10n.Tabs.profile, systemImage: "person.circle", value: .profile) {
                        ProfileView(authViewModel: authViewModel)
                    }
                }
                .tabViewStyle(.sidebarAdaptable)
                .tabBarMinimizeBehaviorOnScrollDown()
                .environment(\.collectionViewModel, collectionViewModel)
                .environment(authViewModel)
                .inkuTabStyle()
                .onOpenURL { url in
                    handleDeepLink(url)
                }
                .onAppear {
                    setupViewModels()
                }
                .modelContainer(modelContainer)
            } else {
                ContentUnavailableView(
                    L10n.Error.title,
                    systemImage: "exclamationmark.triangle",
                    description: Text(L10n.Error.generic)
                )
            }
        }
    }

    // MARK: - Private Functions

    private func setupViewModels() {
        seedAppTokenIfNeeded()
        authViewModel.setCollectionViewModel(collectionViewModel)
    }

    private func seedAppTokenIfNeeded() {
        guard !hasSeededAppToken else { return }

        guard let appToken = Bundle.main.infoDictionary?["APP_TOKEN"] as? String,
              !appToken.isEmpty else {
            Logger.core.error("APP_TOKEN not found in Info.plist. Ensure Secrets.xcconfig is configured.")
            return
        }

        let keychainService = KeychainService()
        do {
            try keychainService.save(appToken: appToken)
            hasSeededAppToken = true
        } catch {
            Logger.core.error("Failed to seed app token: \(error, privacy: .private)")
        }
    }

    private func handleDeepLink(_ url: URL) {
        guard url.scheme == "inku" else { return }

        switch url.host {
        case "collection":
            selectedTab = .collection
        case "browse":
            selectedTab = .browse
        case "search":
            selectedTab = .search
        case "profile":
            selectedTab = .profile
        default:
            break
        }
    }
}

// MARK: - App Tab

enum AppTab: String, Hashable {
    case browse
    case collection
    case search
    case profile
}
