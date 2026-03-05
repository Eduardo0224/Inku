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

// MARK: - EnvironmentValues Extension

extension EnvironmentValues {
    @Entry var collectionViewModel: (any CollectionViewModelProtocol)? = nil
}
