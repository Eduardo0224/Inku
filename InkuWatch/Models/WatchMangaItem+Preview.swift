//
//  WatchMangaItem+Preview.swift
//  InkuWatch
//
//  Created by Eduardo Andrade on 02/06/26.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2026 Eduardo Andrade. All rights reserved.
//

import Foundation
import SwiftUI
import InkuUI

// MARK: - Preview Data

extension [WatchMangaItem] {

    /// Preview data with explicit `dateAdded` timestamps so items sort
    /// in a predictable order (most recently added first).
    /// Cover images are loaded from `PreviewAssets.xcassets`.
    static let watchPreview: [WatchMangaItem] = [
        .berserk,
        WatchMangaItem(
            mangaId: 2,
            title: "Naruto",
            japaneseTitle: "ナルト",
            coverImageData: coverData(named: "naruto"),
            volumesOwned: 72,
            totalVolumes: 72,
            hasCompleteCollection: true,
            dateAdded: Date(timeIntervalSinceNow: -3600)
        ),
        WatchMangaItem(
            mangaId: 3,
            title: "Death Note",
            japaneseTitle: "デスノート",
            coverImageData: coverData(named: "deathNote"),
            volumesOwned: 12,
            totalVolumes: 12,
            hasCompleteCollection: true,
            dateAdded: Date(timeIntervalSinceNow: -7200)
        ),
    ]
}

extension WatchMangaItem {

    static let berserk: WatchMangaItem = .init(
        mangaId: 1,
        title: "Berserk",
        japaneseTitle: "ベルセルク",
        coverImageData: coverData(named: "berserk"),
        score: 9.4,
        volumesOwned: 41,
        totalVolumes: 41,
        currentReadingVolume: nil,
        hasCompleteCollection: true,
        dateAdded: Date()
    )
}

// MARK: - Helpers

/// Loads a cover image from `PreviewAssets.xcassets` and returns
/// its JPEG data for use in `WatchMangaItem.coverImageData`.
private func coverData(named name: String) -> Data? {
    guard let image = PlatformImage(named: name) else { return nil }
    return image.jpegData(compressionQuality: 0.8)
}
