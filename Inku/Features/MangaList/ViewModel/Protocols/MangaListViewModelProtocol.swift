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

    var mangas: [Manga] { get }
    var isLoading: Bool { get }
    var isLoadingMore: Bool { get }
    var errorMessage: String? { get }
    var hasMorePages: Bool { get }

    var genres: [Genre] { get }
    var demographics: [Demographic] { get }
    var themes: [Theme] { get }

    var selectedFilter: MangaFilter { get }

    var isFilterActive: Bool { get }

    // MARK: - Functions

    func loadMangas() async
    func loadMoreMangas() async
    func loadFilterOptions() async
    func applyFilter(_ filter: MangaFilter) async
    func clearFilters() async
}
