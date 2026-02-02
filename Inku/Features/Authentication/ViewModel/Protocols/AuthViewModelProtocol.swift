//
//  AuthViewModelProtocol.swift
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

@MainActor
protocol AuthViewModelProtocol: AnyObject, Observable {

    var authState: AuthState { get }
    var isLoading: Bool { get }
    var errorMessage: String? { get }
    var email: String { get set }
    var password: String { get set }
    var savedEmail: String? { get }
    var isFormValid: Bool { get }
    var isAuthenticated: Bool { get }
    var cloudMangaCount: Int { get set }
    var cloudMangaIds: Set<Int> { get set }
    var isSyncing: Bool { get }
    var isLoadingCloud: Bool { get }
    var syncProgress: String? { get }
    var syncStatuses: [Int: SyncStatus] { get }
    var showSessionExpiredAlert: Bool { get set }
    var collectionViewModel: CollectionViewModelProtocol? { get set }

    func checkAuthenticationStatus() async
    func register() async
    func login() async
    func logout() async
    func renewTokenIfNeeded() async
    func fetchCloudCollection() async
    func setCollectionViewModel(_ collectionViewModel: CollectionViewModelProtocol)
    func syncToCloud() async
    func downloadCloudToLocal() async
    func fullSync() async
    func clearForm()
    func clearPassword()
    func clearError()
}
