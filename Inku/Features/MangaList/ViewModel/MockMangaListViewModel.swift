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

    var selectedFilter: MangaFilter = .none
    var hasLoadedInitialData: Bool = false

    // MARK: - Computed Properties

    var isFilterActive: Bool {
        selectedFilter != .none
    }

    // MARK: - Functions

    func loadInitialDataIfNeeded() async {
        // Mock implementation - no operation
    }

    func loadMangas() async {
        mangas = [.testData]
    }

    func loadMoreMangas() async {
        // Mock implementation - no operation
    }

    func loadFilterOptions() async {
        genres = [
            "Action",
            "Adventure",
            "Award Winning",
            "Drama",
            "Fantasy",
            "Horror",
            "Supernatural",
            "Mystery",
            "Slice of Life",
            "Comedy",
            "Sci-Fi",
            "Suspense",
            "Sports",
            "Ecchi",
            "Romance",
            "Girls Love",
            "Boys Love",
            "Gourmet",
            "Erotica",
            "Hentai",
            "Avant Garde"
        ].map { .init(id: UUID().uuidString, genre: $0) }

        demographics = [
            "Seinen",
            "Shounen",
            "Shoujo",
            "Josei",
            "Kids"
        ].map { .init(id: UUID().uuidString, demographic: $0) }

        themes = [
            "Gore",
            "Military",
            "Mythology",
            "Psychological",
            "Historical",
            "Samurai",
            "Romantic Subtext",
            "School",
            "Adult Cast",
            "Parody",
            "Super Power",
            "Team Sports",
            "Delinquents",
            "Workplace",
            "Survival",
            "Childcare",
            "Iyashikei",
            "Reincarnation",
            "Showbiz",
            "Anthropomorphic",
            "Love Polygon",
            "Music",
            "Mecha",
            "Combat Sports",
            "Isekai",
            "Gag Humor",
            "Crossdressing",
            "Reverse Harem",
            "Martial Arts",
            "Visual Arts",
            "Harem",
            "Otaku Culture",
            "Time Travel",
            "Video Game",
            "Strategy Game",
            "Vampire",
            "Mahou Shoujo",
            "High Stakes Game",
            "CGDCT",
            "Organized Crime",
            "Detective",
            "Performing Arts",
            "Medical",
            "Space",
            "Memoir",
            "Villainess",
            "Racing",
            "Pets",
            "Magical Sex Shift",
            "Educational",
            "Idols (Female)",
            "Idols (Male)"
        ].map { .init(id: UUID().uuidString, theme: $0) }
    }

    func applyFilter(_ filter: MangaFilter) async {
        selectedFilter = filter
    }

    func clearFilters() async {
        await applyFilter(.none)
    }
}
