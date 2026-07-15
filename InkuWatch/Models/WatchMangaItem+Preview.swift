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
import UIKit
import InkuUI

// MARK: - Preview Data

extension [WatchMangaDisplayItem] {

    /// Preview data with explicit `dateAdded` timestamps so items sort
    /// in a predictable order (most recently added first).
    /// Cover images are loaded from `PreviewAssets.xcassets`.
    ///
    /// Uses `static var` (computed) instead of `static let` (lazy) to
    /// avoid holding a `swift_once` lock on `@MainActor` while decoding
    /// JPEG images — which would cause a `RichCancelationError` timeout
    /// in the watchOS preview process.
    @MainActor
    static var watchPreview: [WatchMangaDisplayItem] {
        [
            .berserk,
            WatchMangaDisplayItem(
                mangaId: 2,
                title: "Naruto",
                japaneseTitle: "ナルト",
                coverImageData: coverData(named: "naruto"),
                score: nil,
                volumesOwned: 72,
                totalVolumes: 72,
                hasCompleteCollection: true,
                dateAdded: Date(timeIntervalSinceNow: -3600)
            ),
            WatchMangaDisplayItem(
                mangaId: 3,
                title: "Death Note",
                japaneseTitle: "デスノート",
                coverImageData: coverData(named: "deathNote"),
                score: nil,
                volumesOwned: 12,
                totalVolumes: 12,
                hasCompleteCollection: true,
                dateAdded: Date(timeIntervalSinceNow: -7200)
            ),
        ]
    }
}

extension WatchMangaDisplayItem {

    @MainActor
    static var berserk: WatchMangaDisplayItem {
        .init(
            mangaId: 1,
            title: "Berserk",
            japaneseTitle: "ベルセルク",
            coverImageData: coverData(named: "berserk"),
            score: 9.4,
            volumesOwned: 41,
            totalVolumes: 41,
            hasCompleteCollection: true,
            dateAdded: Date()
        )
    }
}

// MARK: - Helpers

/// Loads a cover image from `PreviewAssets.xcassets` and returns
/// its JPEG data for use in `WatchMangaDisplayItem.coverImageData`.
private func coverData(named name: String) -> Data? {
    guard let image = PlatformImage(named: name) else { return nil }
    return image.jpegData(compressionQuality: 0.8)
}
