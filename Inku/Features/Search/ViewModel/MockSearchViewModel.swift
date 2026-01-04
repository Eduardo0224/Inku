//
//  MockSearchViewModel.swift
//  Inku
//
//  Created by Eduardo Andrade on 02/01/26.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2026 Eduardo Andrade. All rights reserved.
//

import Foundation
import Observation

@Observable
@MainActor
final class MockSearchViewModel: SearchViewModelProtocol {

    // MARK: - Properties

    var searchText = ""
    var searchScope: SearchScope = .title
    var mangaResults: [Manga] = []
    var authorResults: [Author] = []
    var isSearching = false
    var isLoadingMore = false
    var errorMessage: String?
    var hasMorePages = true

    // MARK: - Computed Properties

    var showsEmptyState: Bool {
        searchText.isEmpty && mangaResults.isEmpty && authorResults.isEmpty
    }

    var showsNoResults: Bool {
        !searchText.isEmpty && mangaResults.isEmpty && authorResults.isEmpty && !isSearching
    }

    var hasResults: Bool {
        !mangaResults.isEmpty || !authorResults.isEmpty
    }

    var groupedAuthors: [(key: String, value: [Author])] {
        // Group by first letter of firstName (or lastName if firstName is empty)
        let grouped = Dictionary(grouping: authorResults) { author in
            let nameForGrouping = author.firstName.isEmpty ? author.lastName : author.firstName
            let firstLetter = nameForGrouping.prefix(1).uppercased()

            if firstLetter.isEmpty {
                return "#"
            } else if firstLetter.rangeOfCharacter(from: .decimalDigits) != nil {
                return "0-9"
            } else if firstLetter.rangeOfCharacter(from: .letters) != nil {
                return firstLetter
            } else {
                return "#"
            }
        }

        // Sort each group by firstName (or lastName if firstName is empty), then lastName
        let sortedGroups = grouped.mapValues { authors in
            authors.sorted { lhs, rhs in
                let lhsFirst = lhs.firstName.isEmpty ? lhs.lastName : lhs.firstName
                let rhsFirst = rhs.firstName.isEmpty ? rhs.lastName : rhs.firstName
                return (lhsFirst, lhs.lastName) < (rhsFirst, rhs.lastName)
            }
        }

        // Sort sections: A-Z, then 0-9, then #
        return sortedGroups.sorted { lhs, rhs in
            let left = lhs.key
            let right = rhs.key

            // # always goes last
            if left == "#" { return false }
            if right == "#" { return true }

            // 0-9 comes after letters
            if left == "0-9" { return false }
            if right == "0-9" { return true }

            // Otherwise alphabetical
            return left < right
        }
    }

    // MARK: - Functions

    func performSearch() async {
        switch searchScope {
        case .title:
            mangaResults = [.testData]
            authorResults = []
        case .author:
            mangaResults = []
            authorResults = [.testData]
        }
    }

    func loadMoreResults() async {
        // Mock implementation - no operation
    }

    func clearSearch() {
        searchText = ""
        mangaResults = []
        authorResults = []
    }
}
