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
    var searchResults: [Manga] = []
    var isSearching = false
    var isLoadingMore = false
    var errorMessage: String?
    var hasMorePages = true

    // MARK: - Computed Properties

    var showsEmptyState: Bool {
        searchText.isEmpty && searchResults.isEmpty
    }

    var showsNoResults: Bool {
        !searchText.isEmpty && searchResults.isEmpty && !isSearching
    }

    // MARK: - Functions

    func performSearch() async {
        searchResults = [.testData]
    }

    func loadMoreResults() async {
        // Mock implementation - no operation
    }

    func clearSearch() {
        searchText = ""
        searchResults = []
    }
}
