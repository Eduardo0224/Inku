//
//  APIEndpoints.swift
//  Inku
//
//  Created by Eduardo Andrade on 23/12/25.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2025 Eduardo Andrade. All rights reserved.
//

import Foundation

enum API {

    static let baseURL = "https://mymanga-acacademy-5607149ebe3d.herokuapp.com"

    enum Endpoints {

        // MARK: - Manga List

        static let listMangas = "/list/mangas"
        static let listGenres = "/list/genres"
        static let listDemographics = "/list/demographics"
        static let listThemes = "/list/themes"

        // MARK: - Manga Filtering

        static func listMangaByGenre(_ genre: String) -> String {
            "/list/mangaByGenre/\(genre)"
        }

        static func listMangaByDemographic(_ demographic: String) -> String {
            "/list/mangaByDemographic/\(demographic)"
        }

        static func listMangaByTheme(_ theme: String) -> String {
            "/list/mangaByTheme/\(theme)"
        }

        // MARK: - Search

        static func searchManga(id: Int) -> String {
            "/search/manga/\(id)"
        }

        static func searchMangaContains(_ text: String) -> String {
            "/search/mangasContains/\(text)"
        }

        static func searchMangaBeginsWith(_ text: String) -> String {
            "/search/mangasBeginsWith/\(text)"
        }

        static func searchAuthor(_ name: String) -> String {
            "/search/author/\(name)"
        }

        static let searchCustom = "/search/manga"

        // MARK: - Authentication

        static let registerUser = "/users"
        static let loginUser = "/users/login"
        static let renewToken = "/users/renew"

        // MARK: - Collection

        static let collectionManga = "/collection/manga"

        static func collectionManga(id: Int) -> String {
            "\(collectionManga)/\(id)"
        }
    }

    enum Constants {
        static let defaultPageSize = 20
        static let maxPageSize = 100
    }
}
