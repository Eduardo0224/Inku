//
//  AuthViewModel.swift
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
final class AuthViewModel: AuthViewModelProtocol {

    // MARK: - Private Properties

    @ObservationIgnored
    private let interactor: AuthInteractorProtocol

    @ObservationIgnored
    private var cachedCloudCollection: [CloudCollectionManga]?

    @ObservationIgnored
    var collectionViewModel: CollectionViewModelProtocol?

    // MARK: - Properties

    var authState: AuthState = .unauthenticated
    var isLoading = false
    var errorMessage: String?

    var email = ""
    var password = ""
    var savedEmail: String?
    var cloudMangaCount: Int = 0
    var cloudMangaIds: Set<Int> = []
    var isSyncing: Bool = false
    var isLoadingCloud: Bool = false
    var syncProgress: String?
    var syncStatuses: [Int: SyncStatus] = [:]
    var showSessionExpiredAlert: Bool = false

    // MARK: - Computed Properties

    var isFormValid: Bool {
        let user = User(email: email, password: password)
        return user.isValid
    }

    var isAuthenticated: Bool {
        authState.isAuthenticated
    }

    // MARK: - Initializers

    init(interactor: AuthInteractorProtocol = AuthInteractor()) {
        self.interactor = interactor
    }

    // MARK: - Functions

    func checkAuthenticationStatus() async {
        do {
            if let token = try await interactor.getSavedToken() {
                if token.isExpired {
                    let newToken = try await interactor.renewToken(token)
                    authState = .authenticated(newToken)
                } else {
                    authState = .authenticated(token)
                }
            } else {
                authState = .unauthenticated
            }

            savedEmail = try await interactor.getSavedEmail()
            if let savedEmail {
                email = savedEmail
            }
        } catch {
            authState = .unauthenticated
            handleError(error)
        }
    }

    func register() async {
        guard isFormValid else {
            errorMessage = L10n.Error.generic
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let user = User(email: email, password: password)
            try await interactor.register(user: user)

            await login()
        } catch {
            isLoading = false
            handleError(error, isRegistration: true)
        }
    }

    func login() async {
        guard isFormValid else {
            errorMessage = L10n.Error.generic
            return
        }

        isLoading = true
        errorMessage = nil
        authState = .loading

        do {
            let user = User(email: email, password: password)
            let token = try await interactor.login(user: user)
            authState = .authenticated(token)
            savedEmail = email
            isLoading = false
            clearPassword()
        } catch {
            isLoading = false
            authState = .unauthenticated
            handleError(error)
        }
    }

    func logout() async {
        isLoading = true
        errorMessage = nil

        do {
            try await interactor.logout()
            authState = .unauthenticated
            clearForm()
            isLoading = false
        } catch {
            isLoading = false
            handleError(error)
        }
    }

    func renewTokenIfNeeded() async {
        guard case .authenticated(let token) = authState else { return }

        if token.isExpired {
            do {
                let newToken = try await interactor.renewToken(token)
                authState = .authenticated(newToken)
            } catch {
                authState = .unauthenticated
                handleError(error)
            }
        }
    }

    func clearForm() {
        email = ""
        password = ""
        errorMessage = nil
        cachedCloudCollection = nil
        cloudMangaIds = []
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
        guard case .authenticated(let token) = authState else {
            cloudMangaCount = 0
            cloudMangaIds = []
            cachedCloudCollection = nil
            isLoadingCloud = false
            return
        }

        isLoadingCloud = true

        do {
            let collection = try await interactor.getCloudCollection(token: token)
            cachedCloudCollection = collection
            cloudMangaCount = collection.count
            cloudMangaIds = Set(collection.map { $0.manga.id })
            isLoadingCloud = false
        } catch {
            cloudMangaCount = 0
            cloudMangaIds = []
            cachedCloudCollection = nil
            isLoadingCloud = false

            if let networkError = error as? NetworkError,
               case .unauthorized = networkError {
                authState = .unauthenticated
                showSessionExpiredAlert = true
                clearForm()
            }
        }
    }

    func syncToCloud() async {
        guard case .authenticated(let token) = authState,
              let collectionViewModel else {
            errorMessage = L10n.Error.generic
            return
        }

        isSyncing = true
        errorMessage = nil
        syncStatuses.removeAll()

        do {
            let localMangas = try collectionViewModel.getAllLocalMangas()

            syncProgress = L10n.Profile.Sync.fetchingCloud
            let cloudCollection = try await interactor.getCloudCollection(token: token)

            let cloudMangaIds = Set(cloudCollection.map { $0.manga.id })
            let mangasToUpload = localMangas.filter { !cloudMangaIds.contains($0.mangaId) }

            let localMangaIds = Set(localMangas.map { $0.mangaId })
            let mangasToDownload = cloudCollection.filter { !localMangaIds.contains($0.manga.id) }

            guard !mangasToUpload.isEmpty else {
                if mangasToDownload.isEmpty {
                    syncProgress = L10n.Profile.Sync.allSynced
                    try? await Task.sleep(for: .seconds(2))
                    syncProgress = nil
                }
                isSyncing = false
                return
            }

            for manga in mangasToUpload {
                syncStatuses[manga.mangaId] = .pending
            }

            syncProgress = L10n.Profile.Sync.uploadingCount(mangasToUpload.count)

            let uploadResults = await withTaskGroup(of: (Int, Result<Void, Error>).self) { group in
                for manga in mangasToUpload {
                    let mangaId = manga.mangaId
                    let request = CreateCollectionMangaRequest(from: manga)

                    group.addTask { [interactor] in
                        do {
                            try await interactor.addToCloudCollection(token: token, manga: request)
                            return (mangaId, .success(()))
                        } catch {
                            return (mangaId, .failure(error))
                        }
                    }

                    syncStatuses[mangaId] = .uploading
                }

                var results: [(Int, Result<Void, Error>)] = []
                for await result in group {
                    results.append(result)
                }
                return results
            }

            for (mangaId, result) in uploadResults {
                switch result {
                case .success:
                    syncStatuses[mangaId] = .uploaded
                case .failure:
                    syncStatuses[mangaId] = .failed
                }
            }

            let failedCount = syncStatuses.values.filter { $0 == .failed }.count
            if failedCount > 0 {
                throw NSError(domain: "AuthViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "\(failedCount) manga(s) failed to upload"])
            }

            await fetchCloudCollection()

            syncProgress = L10n.Profile.Sync.successCount(mangasToUpload.count)
            isSyncing = false

            try? await Task.sleep(for: .seconds(2))
            syncProgress = nil
            syncStatuses.removeAll()
        } catch {
            isSyncing = false
            syncProgress = nil

            if let networkError = error as? NetworkError, case .unauthorized = networkError {
                authState = .unauthenticated
                showSessionExpiredAlert = true
                clearForm()
                syncStatuses.removeAll()
            } else {
                handleError(error)
            }
        }
    }

    func fullSync() async {
        await syncToCloud()
        await downloadCloudToLocal()
    }

    func downloadCloudToLocal() async {
        guard case .authenticated(let token) = authState,
              let collectionViewModel else {
            return
        }

        syncProgress = L10n.Profile.Sync.downloadingFromCloud

        do {
            let cloudCollection: [CloudCollectionManga]

            if let cached = cachedCloudCollection {
                cloudCollection = cached
            } else {
                cloudCollection = try await interactor.getCloudCollection(token: token)
                cachedCloudCollection = cloudCollection
                cloudMangaCount = cloudCollection.count
                cloudMangaIds = Set(cloudCollection.map { $0.manga.id })
            }

            try collectionViewModel.addCloudMangasToLocal(cloudCollection)

            let localCount = (try? collectionViewModel.getLocalMangaIds())?.count ?? 0
            let addedCount = cloudCollection.count - localCount
            if addedCount > 0 {
                syncProgress = L10n.Profile.Sync.downloadedCount(addedCount)
            } else {
                syncProgress = L10n.Profile.Sync.allLocal
            }
            try? await Task.sleep(for: .seconds(2))
            syncProgress = nil
        } catch {
            syncProgress = nil

            if let networkError = error as? NetworkError, case .unauthorized = networkError {
                authState = .unauthenticated
                showSessionExpiredAlert = true
                clearForm()
            } else {
                errorMessage = L10n.Profile.Sync.errorDownload
            }
        }
    }

    // MARK: - Private Functions

    private func handleError(_ error: Error, isRegistration: Bool = false) {
        if let networkError = error as? NetworkError {
            print("[AuthViewModel] NetworkError: \(networkError)")

            switch networkError {
            case .badRequest:
                if isRegistration {
                    errorMessage = L10n.Authentication.Error.userExists
                } else {
                    errorMessage = L10n.Error.generic
                }
            case .unauthorized:
                errorMessage = L10n.Authentication.Error.invalidCredentials
            case .notFound:
                errorMessage = L10n.Authentication.Error.invalidCredentials
            case .validationError:
                errorMessage = L10n.Error.generic
            default:
                errorMessage = L10n.Error.generic
            }
        } else if let urlError = error as? URLError {
            print("[AuthViewModel] URLError: \(urlError.code)")

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
        } else if let keychainError = error as? KeychainError {
            print("[AuthViewModel] KeychainError: \(keychainError)")
            errorMessage = L10n.Error.generic
        } else {
            print("[AuthViewModel] Unknown error: \(error)")
            errorMessage = L10n.Error.generic
        }
    }
}
