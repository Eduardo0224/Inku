//
//  Manga.swift
//  Inku
//
//  Created by Eduardo Andrade on 22/12/25.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2025 Eduardo Andrade. All rights reserved.
//

import Foundation

struct Manga: Identifiable, Codable, Hashable, Sendable {

    // MARK: - Properties

    let id: Int
    let title: String
    let titleEnglish: String?
    let titleJapanese: String?
    let sypnosis: String?
    let background: String?
    let mainPicture: String?
    let url: String?
    let volumes: Int?
    let chapters: Int?
    let status: String?
    let score: Double?
    let startDate: Date?
    let endDate: Date?
    let authors: [Author]
    let genres: [Genre]
    let demographics: [Demographic]
    let themes: [Theme]

    // MARK: - Computed Properties

    var displayTitle: String {
        title
    }

    var coverImageURL: URL? {
        guard let mainPicture = mainPicture else { return nil }
        // Remove quotes if present in the JSON
        let cleanURL = mainPicture.replacingOccurrences(of: "\"", with: "")
        return URL(string: cleanURL)
    }

    var sortableScore: Double {
        score ?? 0.0
    }
}

// MARK: - Test Data

extension Manga {

    static let emptyData: Self = .init(
        id: 0,
        title: "",
        titleEnglish: nil,
        titleJapanese: nil,
        sypnosis: nil,
        background: nil,
        mainPicture: nil,
        url: nil,
        volumes: nil,
        chapters: nil,
        status: nil,
        score: nil,
        startDate: nil,
        endDate: nil,
        authors: [],
        genres: [],
        demographics: [],
        themes: []
    )

    static let testData: Self = .init(
        id: 1,
        title: "One Piece",
        titleEnglish: "One Piece",
        titleJapanese: "ワンピース",
        sypnosis: "Monkey D. Luffy refuses to let anyone or anything stand in the way of his quest to become the king of all pirates. With a course charted for the treacherous waters of the Grand Line and beyond, this is one captain who'll never give up until he's claimed the greatest treasure on Earth: the Legendary One Piece!",
        background: nil,
        mainPicture: "https://cdn.myanimelist.net/images/manga/3/216464.jpg",
        url: "https://myanimelist.net/manga/13/One_Piece",
        volumes: nil,
        chapters: nil,
        status: "Publishing",
        score: 9.21,
        startDate: nil,
        endDate: nil,
        authors: [],
        genres: [.testData],
        demographics: [.testData],
        themes: [.testData]
    )

    static let skeletonData: Self = .init(
        id: 0,
        title: "Loading Manga Title",
        titleEnglish: nil,
        titleJapanese: "読み込み中",
        sypnosis: nil,
        background: nil,
        mainPicture: nil,
        url: nil,
        volumes: nil,
        chapters: nil,
        status: "Publishing",
        score: 8.5,
        startDate: nil,
        endDate: nil,
        authors: [],
        genres: [
            Genre(id: "skeleton-1", genre: "Genre One"),
            Genre(id: "skeleton-2", genre: "Genre Two"),
            Genre(id: "skeleton-3", genre: "Genre Three")
        ],
        demographics: [.testData],
        themes: [.testData]
    )
}
