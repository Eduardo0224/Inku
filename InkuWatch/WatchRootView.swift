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

    // MARK: - Properties

    /// Snapshot of computed stats for the stats tab.
    /// Reading ViewModel properties here ensures `@Observable` tracks them,
    /// so the stats view re-renders when the underlying data changes.
    private var statsData: WatchStatsData {
        WatchStatsData(
            totalMangas: viewModel.totalMangas,
            totalVolumesOwned: viewModel.totalVolumesOwned,
            completedCount: viewModel.completedCount,
            readingCount: viewModel.readingCount,
            averageProgress: viewModel.averageProgress,
            completionPercentage: viewModel.completionPercentage
        )
    }

    /// Two-way binding that presents the alert when `errorMessage` is set
    /// and clears it on dismiss.
    private var errorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.clearError() } }
        )
    }

    // MARK: - Body

    var body: some View {
        TabView {
            NavigationStack {
                NowReadingView(mangas: viewModel.nowReadingDisplayItems)
            }
            .tabItem {
                Text(L10n.Watch.nowReading)
            }

            NavigationStack {
                CollectionListView(mangas: viewModel.allMangaDisplayItems)
            }
            .tabItem {
                Text(L10n.Watch.collection)
            }

            NavigationStack {
                WatchStatsView(data: statsData)
            }
            .tabItem {
                Text(L10n.Watch.stats)
            }
        }
        .inkuTabStyle()
        .background(Color.inkuSurface)
        .alert(
            L10n.Error.title,
            isPresented: errorBinding
        ) {
            Button(L10n.Common.ok, role: .cancel) {
                viewModel.clearError()
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .onAppear {
            viewModel.setModelContext(modelContext)
            viewModel.startReceivingSync()
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

    // MARK: - Initializers

    init() {
        self.viewModel = WatchCollectionViewModel()
    }

}
