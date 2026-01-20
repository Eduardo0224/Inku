//
//  CollectionViewModelEnvironment.swift
//  Inku
//
//  Created by Eduardo Andrade on 13/01/26.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2026 Eduardo Andrade. All rights reserved.
//

import SwiftUI

// MARK: - CollectionViewModelKey

private struct CollectionViewModelKey: EnvironmentKey {
    nonisolated(unsafe) static let defaultValue: any CollectionViewModelProtocol = EmptyCollectionViewModel()
}

// MARK: - EnvironmentValues Extension

extension EnvironmentValues {
    var collectionViewModel: any CollectionViewModelProtocol {
        get { self[CollectionViewModelKey.self] }
        set { self[CollectionViewModelKey.self] = newValue }
    }
}
