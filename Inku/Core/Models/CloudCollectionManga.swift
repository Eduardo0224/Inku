//
//  CloudCollectionManga.swift
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

struct CloudCollectionManga: Codable, Sendable {

    // MARK: - Nested Types

    struct UserInfo: Codable, Sendable {
        let id: String
    }

    // MARK: - Properties

    let id: String
    let manga: Manga
    let user: UserInfo
    let completeCollection: Bool
    let volumesOwned: [Int]
    let readingVolume: Int?
}
