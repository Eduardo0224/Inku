//
//  MockCollectionInteractor.swift
//  Inku
//
//  Created by Eduardo Andrade on 20/01/26.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2026 Eduardo Andrade. All rights reserved.
//

import Foundation

final class MockCollectionInteractor: CollectionInteractorProtocol {

    // MARK: - Functions

    func getMangaById(_ id: Int) async throws -> Manga {
        .testData
    }
}
