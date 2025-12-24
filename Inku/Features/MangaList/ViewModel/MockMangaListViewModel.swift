//
//  MockMangaListViewModel.swift
//  Inku
//
//  Created by Eduardo Andrade on 23/12/25.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2025 Eduardo Andrade. All rights reserved.
//

import Foundation
import Observation

@Observable
@MainActor
final class MockMangaListViewModel: MangaListViewModelProtocol {

    // MARK: - Properties

    var mangas: [Manga] = []
    var isLoading = false
    var isLoadingMore = false
    var errorMessage: String?
    var hasMorePages = true

    var genres: [Genre] = []
    var demographics: [Demographic] = []
    var themes: [Theme] = []

    var selectedGenre: String?
    var selectedDemographic: String?
    var selectedTheme: String?

    // MARK: - Computed Properties

    var isFilterActive: Bool {
        selectedGenre != nil || selectedDemographic != nil || selectedTheme != nil
    }

    // MARK: - Functions

    func loadMangas() async {
        // Mock implementation - no operation
    }

    func loadMoreMangas() async {
        // Mock implementation - no operation
    }

    func loadFilterOptions() async {
        // Mock implementation - no operation
    }

    func applyFilter(genre: String? = nil, demographic: String? = nil, theme: String? = nil) async {
        selectedGenre = genre
        selectedDemographic = demographic
        selectedTheme = theme
    }

    func clearFilters() async {
        selectedGenre = nil
        selectedDemographic = nil
        selectedTheme = nil
    }
}
