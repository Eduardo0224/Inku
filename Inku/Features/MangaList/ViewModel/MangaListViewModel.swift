//
//  MangaListViewModel.swift
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
final class MangaListViewModel: MangaListViewModelProtocol {

    // MARK: - Private Properties

    @ObservationIgnored
    private let interactor: MangaListInteractorProtocol

    @ObservationIgnored
    private let advancedFiltersInteractor: AdvancedFiltersInteractorProtocol

    @ObservationIgnored
    private var currentPage = 1

    @ObservationIgnored
    private let itemsPerPage = API.Constants.defaultPageSize
    
    @ObservationIgnored
    private var loadInitialTask: Task<Void, Never>?

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
    private(set) var hasLoadedInitialData = false

    // MARK: - Computed Properties

    var isFilterActive: Bool {
        switch selectedFilter {
        case .genre, .demographic, .theme:
            return true
        case .advanced, .none:
            return false
        }
    }

    var isAdvancedFilterActive: Bool {
        if case .advanced = selectedFilter {
            return true
        }
        return false
    }

    var currentAdvancedSearch: CustomSearch? {
        if case .advanced(let search, _) = selectedFilter {
            return search
        }
        return nil
    }

    var currentSortOption: SearchSortOption? {
        if case .advanced(_, let sortOption) = selectedFilter {
            return sortOption
        }
        return nil
    }

    // MARK: - Initializers

    init(
        interactor: MangaListInteractorProtocol = MangaListInteractor(),
        advancedFiltersInteractor: AdvancedFiltersInteractorProtocol = AdvancedFiltersInteractor()
    ) {
        self.interactor = interactor
        self.advancedFiltersInteractor = advancedFiltersInteractor
    }

    // MARK: - Functions

    @discardableResult
    func loadInitialDataIfNeeded() -> Task<Void, Never> {
        guard !hasLoadedInitialData else {
            return Task { }
        }

        loadInitialTask?.cancel()

        let task = Task { @MainActor in
            guard !Task.isCancelled else { return }

            async let mangasTask: Void = loadMangas()
            async let filtersTask: Void = loadFilterOptions()

            _ = await (mangasTask, filtersTask)

            guard !Task.isCancelled else { return }

            hasLoadedInitialData = true
        }

        loadInitialTask = task
        return task
    }

    func loadMangas() async {
        guard !isLoading else { return }

        isLoading = true
        currentPage = 1
        mangas = []
        errorMessage = nil
        defer { isLoading = false }

        do {
            let response = try await fetchCurrentFilter(page: currentPage, per: itemsPerPage)
            mangas = response.items
            hasMorePages = response.metadata.hasMorePages
        } catch {
            handleError(error)
        }
    }

    func loadMoreMangas() async {
        guard !isLoadingMore, !isLoading, hasMorePages else { return }

        isLoadingMore = true
        defer { isLoadingMore = false }

        let nextPage = currentPage + 1

        do {
            let response = try await fetchCurrentFilter(page: nextPage, per: itemsPerPage)
            mangas.append(contentsOf: response.items)
            currentPage = nextPage
            hasMorePages = response.metadata.hasMorePages
        } catch {
            handleError(error)
        }
    }

    func loadFilterOptions() async {
        do {
            async let genresResult = interactor.fetchGenres()
            async let demographicsResult = interactor.fetchDemographics()
            async let themesResult = interactor.fetchThemes()

            let (fetchedGenres, fetchedDemographics, fetchedThemes) = try await (
                genresResult,
                demographicsResult,
                themesResult
            )

            genres = fetchedGenres.map { .init(id: UUID().uuidString, genre: $0) }
            demographics = fetchedDemographics.map { .init(id: UUID().uuidString, demographic: $0) }
            themes = fetchedThemes.map { .init(id: UUID().uuidString, theme: $0) }
        } catch {
            handleError(error)
        }
    }

    func applyFilter(_ filter: MangaFilter) async {
        selectedFilter = filter
        await loadMangas()
    }

    func clearFilters() async {
        await applyFilter(.none)
    }

    func applyAdvancedSearch(_ search: CustomSearch, sortOption: SearchSortOption) async {
        selectedFilter = .advanced(search, sortOption)
        await loadMangas()
    }

    // MARK: - Private Functions

    private func fetchCurrentFilter(page: Int, per: Int) async throws -> MangaListResponse {
        switch selectedFilter {
        case .genre(let value):
            return try await interactor.fetchMangasByGenre(value, page: page, per: per)
        case .demographic(let value):
            return try await interactor.fetchMangasByDemographic(value, page: page, per: per)
        case .theme(let value):
            return try await interactor.fetchMangasByTheme(value, page: page, per: per)
        case .advanced(let search, let sortOption):
            let response = try await advancedFiltersInteractor.searchMangas(search, page: page, per: per)
            let sortedMangas = sortOption.sort(response.items)
            return MangaListResponse(items: sortedMangas, metadata: response.metadata)
        case .none:
            return try await interactor.fetchMangas(page: page, per: per)
        }
    }

    private func handleError(_ error: Error) {
        // Log detailed error for debugging
        if let networkError = error as? NetworkError {
            // TODO: Use swift-log or OSLog for production logging
            print("[MangaListViewModel] NetworkError: \(networkError)")

            // Generic message to user (security)
            errorMessage = L10n.Error.generic
        } else if let urlError = error as? URLError {
            print("[MangaListViewModel] URLError: \(urlError.code)")

            // Specific messages only for connectivity issues
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
            print("[MangaListViewModel] Unknown error: \(error)")
            errorMessage = L10n.Error.generic
        }
    }
}
