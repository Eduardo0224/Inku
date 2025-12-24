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
protocol MangaListViewModelProtocol: AnyObject, Observable {

    // MARK: - Properties

    var mangas: [Manga] { get set }
    var isLoading: Bool { get set }
    var isLoadingMore: Bool { get set }
    var errorMessage: String? { get set }
    var hasMorePages: Bool { get set }

    var genres: [Genre] { get set }
    var demographics: [Demographic] { get set }
    var themes: [Theme] { get set }

    var selectedGenre: String? { get set }
    var selectedDemographic: String? { get set }
    var selectedTheme: String? { get set }

    var isFilterActive: Bool { get }

    // MARK: - Functions

    func loadMangas() async
    func loadMoreMangas() async
    func loadFilterOptions() async
    func applyFilter(genre: String?, demographic: String?, theme: String?) async
    func clearFilters() async
}
