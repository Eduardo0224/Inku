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
            // Reset manga search mode when clearing search
            if searchText.isEmpty && !oldValue.isEmpty {
                mangaSearchMode = .contains
            }
            scheduleSearch()
        }
    }

    var searchScope: SearchScope = .title {
        didSet {
            guard searchScope != oldValue else { return }
            // Reset manga search mode when switching to author scope
            if searchScope == .author {
                mangaSearchMode = .contains
            }
            performSearchIfNeeded()
        }
    }

    var mangaSearchMode: MangaSearchMode = .contains {
        didSet {
            guard mangaSearchMode != oldValue else { return }
            guard searchScope == .title else { return }
            performSearchIfNeeded()
        }
    }

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

    var groupedAuthors: [(key: String, value: [Author])] {
        // Group by first letter of firstName (or lastName if firstName is empty)
        let grouped = Dictionary(grouping: authorResults) { author in
            let nameForGrouping = author.firstName.isEmpty ? author.lastName : author.firstName
            let firstLetter = nameForGrouping.prefix(1).uppercased()

            if firstLetter.isEmpty {
                return "#"
            } else if firstLetter.rangeOfCharacter(from: .decimalDigits) != nil {
                return "0-9"
            } else if firstLetter.rangeOfCharacter(from: .letters) != nil {
                return firstLetter
            } else {
                return "#"
            }
        }

        // Sort each group by firstName (or lastName if firstName is empty), then lastName
        let sortedGroups = grouped.mapValues { authors in
            authors.sorted { lhs, rhs in
                let lhsFirst = lhs.firstName.isEmpty ? lhs.lastName : lhs.firstName
                let rhsFirst = rhs.firstName.isEmpty ? rhs.lastName : rhs.firstName
                return (lhsFirst, lhs.lastName) < (rhsFirst, rhs.lastName)
            }
        }

        // Sort sections: A-Z, then 0-9, then #
        return sortedGroups.sorted { lhs, rhs in
            let left = lhs.key
            let right = rhs.key

            // # always goes last
            if left == "#" { return false }
            if right == "#" { return true }

            // 0-9 comes after letters
            if left == "0-9" { return false }
            if right == "0-9" { return true }

            // Otherwise alphabetical
            return left < right
        }
    }

    // MARK: - Initializers

    init(interactor: SearchInteractorProtocol = SearchInteractor()) {
        self.interactor = interactor
    }

    // MARK: - Functions

    func performSearch() async {
        guard !searchText.isEmpty else {
            mangaResults = []
            authorResults = []
            return
        }

        guard !isSearching else { return }

        isSearching = true
        currentPage = 1
        mangaResults = []
        authorResults = []
        errorMessage = nil
        defer { isSearching = false }

        do {
            switch searchScope {
            case .title:
                switch mangaSearchMode {
                case .contains:
                    let response = try await interactor.searchMangasContains(
                        searchText,
                        page: currentPage,
                        per: itemsPerPage
                    )
                    // Sort only this page by score (descending)
                    mangaResults = response.items.sorted { $0.sortableScore > $1.sortableScore }
                    hasMorePages = response.metadata.hasMorePages

                case .beginsWith:
                    let mangas = try await interactor.searchMangasBeginsWith(searchText)
                    // Sort all results by score (descending)
                    mangaResults = mangas.sorted { $0.sortableScore > $1.sortableScore }
                    hasMorePages = false
                }

            case .author:
                let authors = try await interactor.searchAuthorsByName(searchText)
                authorResults = authors
                hasMorePages = false
            }
        } catch {
            handleError(error)
        }
    }

    func loadMoreResults() async {
        guard !isLoadingMore, !isSearching, hasMorePages else { return }
        guard searchScope == .title else { return } // Only title search supports pagination
        guard mangaSearchMode == .contains else { return } // Only 'contains' mode supports pagination

        isLoadingMore = true
        defer { isLoadingMore = false }

        let nextPage = currentPage + 1

        do {
            let response = try await interactor.searchMangasContains(
                searchText,
                page: nextPage,
                per: itemsPerPage
            )
            // Sort only this page by score (descending) before appending
            let sortedNewPage = response.items.sorted { $0.sortableScore > $1.sortableScore }
            mangaResults.append(contentsOf: sortedNewPage)
            currentPage = nextPage
            hasMorePages = response.metadata.hasMorePages
        } catch {
            handleError(error)
        }
    }

    func clearSearch() {
        searchTask?.cancel()
        searchText = ""
        mangaResults = []
        authorResults = []
        errorMessage = nil
        currentPage = 1
        hasMorePages = true
    }

    // MARK: - Private Functions

    private func scheduleSearch() {
        searchTask?.cancel()

        guard !searchText.isEmpty else {
            mangaResults = []
            authorResults = []
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
