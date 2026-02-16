//
//  InkuVisionApp.swift
//  InkuVision
//
//  Created by Eduardo Andrade on 09/02/26.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2026 Eduardo Andrade. All rights reserved.
//

import SwiftUI
import SwiftData

@main
struct InkuVisionApp: App {

    // MARK: - States

    @State private var collectionViewModel = CollectionViewModel()
    @State private var authViewModel = AuthViewModel(syncMessageDelay: .seconds(2))

    // MARK: - Body

    var body: some Scene {
        WindowGroup {
            TabView {
                Tab(L10n.Tabs.browse, systemImage: "books.vertical") {
                    MangaListView()
                }

                Tab(L10n.Tabs.collection, systemImage: "bookmark") {
                    CollectionView()
                }

                Tab(L10n.Tabs.search, systemImage: "magnifyingglass", role: .search) {
                    SearchView()
                }

                Tab(L10n.Tabs.profile, systemImage: "person.circle") {
                    ProfileView(authViewModel: authViewModel)
                }
            }
            .frame(minWidth: 800, minHeight: 600)
            .environment(\.collectionViewModel, collectionViewModel)
            .environment(authViewModel)
            .onAppear {
                setupViewModels()
            }
        }
        .windowStyle(.automatic)
        .windowResizability(.contentSize)
        .defaultSize(width: 1200, height: 800)
        .modelContainer(SharedModelContainer.shared)
    }

    // MARK: - Private Functions

    private func setupViewModels() {
        authViewModel.setCollectionViewModel(collectionViewModel)
    }
}
