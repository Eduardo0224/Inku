//
//  SearchViewModelProtocol.swift
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

@MainActor
protocol SearchViewModelProtocol: Observable {

    // MARK: - Properties

    var searchText: String { get set }
    var searchScope: SearchScope { get set }
    var mangaResults: [Manga] { get }
    var authorResults: [Author] { get }
    var isSearching: Bool { get }
    var isLoadingMore: Bool { get }
    var errorMessage: String? { get set }
    var hasMorePages: Bool { get }

    var showsEmptyState: Bool { get }
    var showsNoResults: Bool { get }
    var hasResults: Bool { get }

    // MARK: - Functions

    func performSearch() async
    func loadMoreResults() async
    func clearSearch()
}
