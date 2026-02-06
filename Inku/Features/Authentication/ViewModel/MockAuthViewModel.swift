//
//  MockAuthViewModel.swift
//  Inku
//
//  Created by Eduardo Andrade on 30/01/26.
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
final class MockAuthViewModel: AuthViewModelProtocol {

    // MARK: - Properties

    var authState: AuthState
    var isLoading: Bool = false
    var errorMessage: String?
    var email: String = ""
    var password: String = ""
    var savedEmail: String?
    var cloudMangaCount: Int = 0
    var cloudMangaIds: Set<Int> = []
    var isSyncing: Bool = false
    var isLoadingCloud: Bool = false
    var syncProgress: String?
    var syncStatuses: [Int: SyncStatus] = [:]
    var showSessionExpiredAlert: Bool = false
    var collectionViewModel: CollectionViewModelProtocol?
    var isFormValid: Bool { true }
    var isAuthenticated: Bool {
        authState.isAuthenticated
    }

    // MARK: - Initializers

    init(authState: AuthState = .unauthenticated, email: String = "") {
        self.authState = authState
        self.email = email
        if case .authenticated = authState {
            self.savedEmail = email
        }
    }

    // MARK: - Functions

    func checkAuthenticationStatus() async {
        // No-op for mock
    }

    func register() async {
        isLoading = true
        authState = .authenticated(.init(token: "mock_token_12345"))
        savedEmail = email
        isLoading = false
    }

    func login() async {
        isLoading = true
        authState = .authenticated(.init(token: "mock_token_12345"))
        savedEmail = email
        isLoading = false
    }

    func logout() async {
        isLoading = true
        authState = .unauthenticated
        clearForm()
        isLoading = false
    }

    func renewTokenIfNeeded() async {
        // No-op for mock
    }

    func clearForm() {
        email = ""
        password = ""
        errorMessage = nil
    }

    func clearPassword() {
        password = ""
    }

    func clearError() {
        errorMessage = nil
    }

    func setCollectionViewModel(_ collectionViewModel: CollectionViewModelProtocol) {
        self.collectionViewModel = collectionViewModel
    }

    func fetchCloudCollection() async {
        cloudMangaCount = 3
    }

    func syncToCloud() async {
        guard let collectionViewModel else { return }

        isSyncing = true
        syncProgress = "Syncing..."
        let localMangas = (try? collectionViewModel.getAllLocalMangas()) ?? []
        cloudMangaCount = localMangas.count
        syncProgress = "Synced successfully"
        isSyncing = false
        syncProgress = nil
    }

    func downloadCloudToLocal() async {
        syncProgress = "Downloading from cloud..."
        syncProgress = "Downloaded successfully"
        syncProgress = nil
    }

    func fullSync() async {
        await syncToCloud()
        await downloadCloudToLocal()
    }

    func updateMangaInCollection(_ manga: CollectionManga) async throws {
        guard let collectionViewModel else {
            throw NSError(domain: "MockAuthViewModel", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "CollectionViewModel not available"
            ])
        }

        try collectionViewModel.updateCollection(manga)
    }

    func deleteMangaFromCollection(_ manga: CollectionManga) async throws {
        guard let collectionViewModel else {
            throw NSError(domain: "MockAuthViewModel", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "CollectionViewModel not available"
            ])
        }

        try collectionViewModel.removeFromCollection(manga)
    }

    // MARK: - Static Factory Methods

    static var unauthenticated: MockAuthViewModel {
        MockAuthViewModel(authState: .unauthenticated)
    }

    static var authenticated: MockAuthViewModel {
        MockAuthViewModel(
            authState: .authenticated(.init(token: "mock_token_12345")),
            email: "test@inku.com"
        )
    }

    static var loading: MockAuthViewModel {
        let mock = MockAuthViewModel(authState: .loading)
        mock.isLoading = true
        return mock
    }
}
