//
//  InkuApp.swift
//  Inku
//
//  Created by Eduardo Andrade on 20/12/25.
//

import SwiftUI
import InkuUI

@main
struct InkuApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                Tab(L10n.Tabs.browse, systemImage: "books.vertical") {
                    MangaListView()
                }

                Tab(L10n.Search.Screen.title, systemImage: "magnifyingglass", role: .search) {
                    SearchView()
                }
            }
            .inkuTabStyle()
        }
    }
}
