//
//  InkuApp.swift
//  Inku
//
//  Created by Eduardo Andrade on 20/12/25.
//

import SwiftUI
import SwiftData
import InkuUI

@main
struct InkuApp: App {

    // MARK: - States

    @State private var collectionViewModel = CollectionViewModel()

    // MARK: - Body

    var body: some Scene {
        WindowGroup {
            TabView {
                Tab(L10n.Tabs.browse, systemImage: "books.vertical") {
                    MangaListView()
                }

                Tab(L10n.Search.Screen.title, systemImage: "magnifyingglass", role: .search) {
                    SearchView()
                }

                Tab(L10n.Tabs.collection, systemImage: "bookmark.fill") {
                    CollectionView()
                }
            }
            .environment(\.collectionViewModel, collectionViewModel)
            .inkuTabStyle()
        }
        .modelContainer(for: CollectionManga.self)
    }
}
