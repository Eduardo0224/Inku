//
//  SearchViewModel.swift
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
final class SearchViewModel: SearchViewModelProtocol {

    // MARK: - Private Properties

    @ObservationIgnored
    private let interactor: SearchInteractorProtocol

    @ObservationIgnored
    private var currentPage = 1

    @ObservationIgnored
    private let itemsPerPage = API.Constants.defaultPageSize

    @ObservationIgnored
    private var searchTask: Task<Void, Never>?

    // MARK: - Properties

    var searchText = "" {
        didSet {
            guard searchText != oldValue else { return }
            scheduleSearch()
        }
    }

    var searchScope: SearchScope = .title {
        didSet {
            guard searchScope != oldValue else { return }
            performSearchIfNeeded()
        }
    }

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

    // MARK: - Initializers

    init(interactor: SearchInteractorProtocol = SearchInteractor()) {
        self.interactor = interactor
    }

    // MARK: - Functions

    func performSearch() async {
        guard !searchText.isEmpty else {
            searchResults = []
            return
        }

        guard !isSearching else { return }

        isSearching = true
        currentPage = 1
        searchResults = []
        errorMessage = nil
        defer { isSearching = false }

        do {
            switch searchScope {
            case .title:
                let response = try await interactor.searchMangasByTitle(
                    searchText,
                    page: currentPage,
                    per: itemsPerPage
                )
                searchResults = response.items
                hasMorePages = response.metadata.hasMorePages

            case .author:
                let mangas = try await interactor.searchMangasByAuthor(searchText)
                searchResults = mangas
                hasMorePages = false
            }
        } catch {
            handleError(error)
        }
    }

    func loadMoreResults() async {
        guard !isLoadingMore, !isSearching, hasMorePages else { return }
        guard searchScope == .title else { return } // Only title search supports pagination

        isLoadingMore = true
        defer { isLoadingMore = false }

        let nextPage = currentPage + 1

        do {
            let response = try await interactor.searchMangasByTitle(
                searchText,
                page: nextPage,
                per: itemsPerPage
            )
            searchResults.append(contentsOf: response.items)
            currentPage = nextPage
            hasMorePages = response.metadata.hasMorePages
        } catch {
            handleError(error)
        }
    }

    func clearSearch() {
        searchTask?.cancel()
        searchText = ""
        searchResults = []
        errorMessage = nil
        currentPage = 1
        hasMorePages = true
    }

    // MARK: - Private Functions

    private func scheduleSearch() {
        searchTask?.cancel()

        guard !searchText.isEmpty else {
            searchResults = []
            return
        }

        searchTask = Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(300)) // Debouncing

            guard !Task.isCancelled else { return }

            await performSearch()
        }
    }

    private func performSearchIfNeeded() {
        guard !searchText.isEmpty else { return }

        searchTask?.cancel()

        searchTask = Task { @MainActor in
            await performSearch()
        }
    }

    private func handleError(_ error: Error) {
        if let networkError = error as? NetworkError {
            print("[SearchViewModel] NetworkError: \(networkError)")
            errorMessage = L10n.Error.generic
        } else if let urlError = error as? URLError {
            print("[SearchViewModel] URLError: \(urlError.code)")

            switch urlError.code {
            case .notConnectedToInternet:
                errorMessage = L10n.Error.network
            case .timedOut:
                errorMessage = L10n.Error.timeout
            case .cancelled:
                return
            default:
                errorMessage = L10n.Error.generic
            }
        } else {
            print("[SearchViewModel] Unknown error: \(error)")
            errorMessage = L10n.Error.generic
        }
    }
}
