//
//  MockSearchViewModel.swift
//  Inku
//
//  Created by Eduardo Andrade on 02/01/26.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2026 Eduardo Andrade. All rights reserved.
//

import Foundation
import Observation

@Observable
@MainActor
final class MockSearchViewModel: SearchViewModelProtocol {

    // MARK: - Properties

    var searchText = ""
    var searchScope: SearchScope = .title
    var mangaResults: [Manga] = []
    var authorResults: [Author] = []
    var isSearching = false
    var isLoadingMore = false
    var errorMessage: String?
    var hasMorePages = true

    // MARK: - Computed Properties

    var showsEmptyState: Bool {
        searchText.isEmpty && mangaResults.isEmpty && authorResults.isEmpty
    }

    var showsNoResults: Bool {
        !searchText.isEmpty && mangaResults.isEmpty && authorResults.isEmpty && !isSearching
    }

    var hasResults: Bool {
        !mangaResults.isEmpty || !authorResults.isEmpty
    }

    // MARK: - Functions

    func performSearch() async {
        switch searchScope {
        case .title:
            mangaResults = [.testData]
            authorResults = []
        case .author:
            mangaResults = []
            authorResults = [.testData]
        }
    }

    func loadMoreResults() async {
        // Mock implementation - no operation
    }

    func clearSearch() {
        searchText = ""
        mangaResults = []
        authorResults = []
    }
}
