//
//  MangaListViewModelProtocol.swift
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

@MainActor
protocol MangaListViewModelProtocol: Observable {

    // MARK: - Properties

    var mangas: [Manga] { get }
    var isLoading: Bool { get }
    var isLoadingMore: Bool { get }
    var errorMessage: String? { get }
    var hasMorePages: Bool { get }

    var genres: [Genre] { get }
    var demographics: [Demographic] { get }
    var themes: [Theme] { get }

    var selectedFilter: MangaFilter { get }
    var hasLoadedInitialData: Bool { get }

    var isFilterActive: Bool { get }
    var isAdvancedFilterActive: Bool { get }
    var currentAdvancedSearch: CustomSearch? { get }
    var currentSortOption: SearchSortOption? { get }

    // MARK: - Functions

    func loadInitialDataIfNeeded() async
    func loadMangas() async
    func loadMoreMangas() async
    func loadFilterOptions() async
    func applyFilter(_ filter: MangaFilter) async
    func clearFilters() async
    func applyAdvancedSearch(_ search: CustomSearch, sortOption: SearchSortOption) async
}
