//
//  InkuMacApp.swift
//  Inku
//
//  Created by Eduardo Andrade on 6/02/26.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2026 Eduardo Andrade. All rights reserved.

import SwiftUI
import SwiftData
import InkuUI

@main
struct InkuMacApp: App {

    // MARK: - States

    @State private var collectionViewModel = CollectionViewModel()
    @State private var authViewModel = AuthViewModel(syncMessageDelay: .seconds(2))

    // MARK: - Body

    var body: some Scene {
        WindowGroup {
            MacOSRootView()
                .environment(\.collectionViewModel, collectionViewModel)
                .environment(authViewModel)
                .onAppear {
                    setupViewModels()
                }
        }
        .modelContainer(SharedModelContainer.shared)
        .commands {
            // Add macOS-specific menu commands
            CommandGroup(replacing: .sidebar) {
                Button {
                    NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
                } label: {
                    Label(L10n.Commands.toggleSidebar, systemImage: "sidebar.left")
                }
                .keyboardShortcut("s", modifiers: [.command, .option])
            }

            CommandGroup(after: .toolbar) {
                Button(L10n.Tabs.browse) {
                    NotificationCenter.default.post(name: .navigateToSection, object: NavigationSection.browse)
                }
                .keyboardShortcut("1", modifiers: .command)

                Button(L10n.Tabs.collection) {
                    NotificationCenter.default.post(name: .navigateToSection, object: NavigationSection.collection)
                }
                .keyboardShortcut("2", modifiers: .command)

                Button(L10n.Tabs.search) {
                    NotificationCenter.default.post(name: .navigateToSection, object: NavigationSection.search)
                }
                .keyboardShortcut("3", modifiers: .command)

                Button(L10n.Tabs.profile) {
                    NotificationCenter.default.post(name: .navigateToSection, object: NavigationSection.profile)
                }
                .keyboardShortcut("4", modifiers: .command)
            }
        }
    }

    // MARK: - Private Functions

    private func setupViewModels() {
        authViewModel.setCollectionViewModel(collectionViewModel)
    }
}

// MARK: - Navigation Section

enum NavigationSection: String, CaseIterable, Identifiable {
    case browse
    case collection
    case search
    case profile

    var id: String { rawValue }

    var title: String {
        switch self {
        case .browse: return L10n.Tabs.browse
        case .collection: return L10n.Tabs.collection
        case .search: return L10n.Tabs.search
        case .profile: return L10n.Tabs.profile
        }
    }

    var icon: String {
        switch self {
        case .browse: return "books.vertical"
        case .collection: return "bookmark"
        case .search: return "magnifyingglass"
        case .profile: return "person.circle"
        }
    }
}

// MARK: - Notification Name

extension Notification.Name {
    static let navigateToSection = Notification.Name("navigateToSection")
}

// MARK: - macOS Root View

struct MacOSRootView: View {

    // MARK: - States

    @State private var selectedSection: NavigationSection = .browse

    // MARK: - Environment

    @Environment(AuthViewModel.self) private var authViewModel

    // MARK: - Body

    var body: some View {
        NavigationSplitView {
            // Sidebar
            List(NavigationSection.allCases, selection: $selectedSection) { section in
                Label(section.title, systemImage: section.icon)
                    .tag(section)
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200, max: 250)
        } detail: {
            // Detail view
            detailView(for: selectedSection)
        }
        .frame(minWidth: 800, minHeight: 600)
        .onReceive(NotificationCenter.default.publisher(for: .navigateToSection)) { notification in
            if let section = notification.object as? NavigationSection {
                selectedSection = section
            }
        }
    }

    // MARK: - Private Views

    @ViewBuilder
    private func detailView(for section: NavigationSection) -> some View {
        switch section {
        case .browse:
            MangaListView()
        case .collection:
            CollectionView()
        case .search:
            SearchView()
        case .profile:
            ProfileView(authViewModel: authViewModel)
        }
    }
}
