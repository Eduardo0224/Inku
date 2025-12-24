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
    private var currentPage = 1

    @ObservationIgnored
    private let itemsPerPage = API.Constants.defaultPageSize

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

    // MARK: - Initializers

    init(interactor: MangaListInteractorProtocol = MangaListInteractor()) {
        self.interactor = interactor
    }

    // MARK: - Functions

    func loadMangas() async {
        guard !isLoading else { return }

        isLoading = true
        currentPage = 1
        mangas = []
        errorMessage = nil
        defer { isLoading = false }

        do {
            let response = try await fetchCurrentFilter(page: currentPage, per: itemsPerPage)
            mangas = response.data
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
            mangas.append(contentsOf: response.data)
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

            genres = fetchedGenres
            demographics = fetchedDemographics
            themes = fetchedThemes
        } catch {
            handleError(error)
        }
    }

    func applyFilter(genre: String? = nil, demographic: String? = nil, theme: String? = nil) async {
        selectedGenre = genre
        selectedDemographic = demographic
        selectedTheme = theme
        await loadMangas()
    }

    func clearFilters() async {
        selectedGenre = nil
        selectedDemographic = nil
        selectedTheme = nil
        await loadMangas()
    }

    // MARK: - Private Functions

    private func fetchCurrentFilter(page: Int, per: Int) async throws -> MangaListResponse {
        if let genre = selectedGenre {
            return try await interactor.fetchMangasByGenre(genre, page: page, per: per)
        } else if let demographic = selectedDemographic {
            return try await interactor.fetchMangasByDemographic(
                demographic,
                page: page,
                per: per
            )
        } else if let theme = selectedTheme {
            return try await interactor.fetchMangasByTheme(theme, page: page, per: per)
        } else {
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
