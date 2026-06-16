//
//  WatchRootView.swift
//  InkuWatch
//
//  Created by Eduardo Andrade on 02/06/26.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2026 Eduardo Andrade. All rights reserved.
//

import SwiftUI
import SwiftData
import InkuUI

// MARK: - Watch Root View

struct WatchRootView: View {

    // MARK: - States

    @State private var viewModel: WatchCollectionViewModel
    @State private var didPerformInitialLoad = false

    // MARK: - Environment

    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase

    // MARK: - Initializers

    init(sessionManager: WatchSessionManagerProtocol = WatchSessionManager()) {
        self.viewModel = WatchCollectionViewModel(sessionManager: sessionManager)
    }

    // MARK: - Body

    var body: some View {
        TabView {
            NavigationStack {
                NowReadingView(mangas: viewModel.nowReading)
            }
            .tabItem {
                Text(L10n.Watch.nowReading)
            }

            NavigationStack {
                CollectionListView(mangas: viewModel.allMangas)
            }
            .tabItem {
                Text(L10n.Watch.collection)
            }

            NavigationStack {
                WatchStatsView(viewModel: viewModel)
            }
            .tabItem {
                Text(L10n.Watch.stats)
            }
        }
        .inkuTabStyle()
        .background(Color.inkuSurface)
        .task {
            viewModel.configureSession(with: modelContext.container)
            viewModel.checkSimulatorSync(context: modelContext)
            viewModel.loadMangas(context: modelContext)
            viewModel.syncFromiPhone()
            didPerformInitialLoad = true
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard didPerformInitialLoad, newPhase == .active else { return }
            viewModel.checkSimulatorSync(context: modelContext)
            viewModel.loadMangas(context: modelContext)
        }
    }
}
