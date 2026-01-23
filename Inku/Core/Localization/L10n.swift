//
//  L10n.swift
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

enum L10n {

    // MARK: - Tabs (Localizable.xcstrings)

    enum Tabs {
        static let browse = String(localized: .tabBrowse)
        static let collection = String(localized: .tabCollection)
        static let search = String(localized: .tabSearch)
    }

    // MARK: - Common (Localizable.xcstrings)

    enum Common {
        static let ok = String(localized: .commonOk)
        static let cancel = String(localized: .commonCancel)
        static let done = String(localized: .commonDone)
        static let retry = String(localized: .commonRetry)
        static let loading = String(localized: .commonLoading)
    }

    // MARK: - Errors (Localizable.xcstrings)

    enum Error {
        static let title = String(localized: .errorTitle)
        static let generic = String(localized: .errorGeneric)
        static let network = String(localized: .errorNetwork)
        static let timeout = String(localized: .errorTimeout)
    }

    // MARK: - Manga List (MangaListLocalizable.xcstrings)

    enum MangaList {

        enum Screen {
            static let title = String(localized: .MangaListLocalizable.screenTitle)
        }

        enum Section {
            static let featured = String(localized: .MangaListLocalizable.sectionFeatured)
            static let recent = String(localized: .MangaListLocalizable.sectionRecent)
            static let popular = String(localized: .MangaListLocalizable.sectionPopular)
        }

        enum Placeholder {
            static let search = String(localized: .MangaListLocalizable.placeholderSearch)
        }

        enum Empty {
            static let title = String(localized: .MangaListLocalizable.emptyTitle)
            static let subtitle = String(localized: .MangaListLocalizable.emptySubtitle)
        }

        enum Filter {
            static let clear = String(localized: .MangaListLocalizable.filterClear)
            static let genre = String(localized: .MangaListLocalizable.filterGenre)
            static let demographic = String(localized: .MangaListLocalizable.filterDemographic)
            static let theme = String(localized: .MangaListLocalizable.filterTheme)
        }
    }

    // MARK: - Manga Detail (MangaDetailLocalizable.xcstrings)

    enum MangaDetail {

        enum Screen {
            static let title = String(localized: .MangaDetailLocalizable.screenTitle)
        }

        enum Stats {
            static let score = String(localized: .MangaDetailLocalizable.statsScore)
            static let volumes = String(localized: .MangaDetailLocalizable.statsVolumes)
            static let chapters = String(localized: .MangaDetailLocalizable.statsChapters)
            static let status = String(localized: .MangaDetailLocalizable.statsStatus)
        }

        enum Synopsis {
            static let title = String(localized: .MangaDetailLocalizable.synopsisTitle)
            static let readMore = String(localized: .MangaDetailLocalizable.synopsisReadMore)
            static let readLess = String(localized: .MangaDetailLocalizable.synopsisReadLess)
            static let empty = String(localized: .MangaDetailLocalizable.synopsisEmpty)
        }

        enum Authors {
            static let title = String(localized: .MangaDetailLocalizable.authorsTitle)
            static let empty = String(localized: .MangaDetailLocalizable.authorsEmpty)
        }

        enum Tags {
            static let title = String(localized: .MangaDetailLocalizable.tagsTitle)
            static let empty = String(localized: .MangaDetailLocalizable.tagsEmpty)
        }

        enum Publication {
            static let title = String(localized: .MangaDetailLocalizable.publicationTitle)
            static let unknown = String(localized: .MangaDetailLocalizable.publicationUnknown)
            static let present = String(localized: .MangaDetailLocalizable.publicationPresent)
            static let since = String(localized: .MangaDetailLocalizable.publicationSince)
        }

        enum Background {
            static let title = String(localized: .MangaDetailLocalizable.backgroundTitle)
            static let button = String(localized: .MangaDetailLocalizable.backgroundButton)
        }

        enum Status {
            static let publishing = String(localized: .MangaDetailLocalizable.statusPublishing)
            static let completed = String(localized: .MangaDetailLocalizable.statusCompleted)
            static let hiatus = String(localized: .MangaDetailLocalizable.statusHiatus)
            static let discontinued = String(localized: .MangaDetailLocalizable.statusDiscontinued)
        }

        enum Value {
            static let notAvailable = String(localized: .MangaDetailLocalizable.valueNotAvailable)
        }
    }

    // MARK: - Search (SearchLocalizable.xcstrings)

    enum Search {

        enum Screen {
            static let title = String(localized: .SearchLocalizable.screenTitle)
        }

        enum Scope {
            static let title = String(localized: .SearchLocalizable.scopeTitle)
            static let author = String(localized: .SearchLocalizable.scopeAuthor)
        }

        enum EmptyState {
            static let title = String(localized: .SearchLocalizable.emptyStateTitle)
            static let message = String(localized: .SearchLocalizable.emptyStateMessage)

            enum Manga {
                static let title = String(localized: .SearchLocalizable.emptyStateMangaTitle)
                static let message = String(localized: .SearchLocalizable.emptyStateMangaMessage)
            }

            enum Author {
                static let title = String(localized: .SearchLocalizable.emptyStateAuthorTitle)
                static let message = String(localized: .SearchLocalizable.emptyStateAuthorMessage)
            }
        }

        enum NoResults {
            static let title = String(localized: .SearchLocalizable.noResultsTitle)
            static let message = String(localized: .SearchLocalizable.noResultsMessage)

            enum Manga {
                static let title = String(localized: .SearchLocalizable.noResultsMangaTitle)
                static let message = String(localized: .SearchLocalizable.noResultsMangaMessage)
            }

            enum Author {
                static let title = String(localized: .SearchLocalizable.noResultsAuthorTitle)
                static let message = String(localized: .SearchLocalizable.noResultsAuthorMessage)
            }
        }

        enum Placeholder {
            static let search = String(localized: .SearchLocalizable.placeholder)
            static let manga = String(localized: .SearchLocalizable.placeholderManga)
            static let author = String(localized: .SearchLocalizable.placeholderAuthor)
        }

        enum Results {
            static let singular = String(localized: .SearchLocalizable.resultSingular)
            static let plural = String(localized: .SearchLocalizable.resultPlural)
            static func forQuery(_ query: String) -> String {
                String(localized: .SearchLocalizable.forQuery(query))
            }
            static let searching = String(localized: .SearchLocalizable.searching)
        }

        enum Mode {
            static let contains = String(localized: .SearchLocalizable.modeContains)
            static let beginsWith = String(localized: .SearchLocalizable.modeBeginsWith)
        }
    }

    // MARK: - Collection (CollectionLocalizable.xcstrings)

    enum Collection {

        enum Screen {
            static let title = String(localized: .CollectionLocalizable.screenTitle)
        }

        enum Filter {
            static let title = String(localized: .CollectionLocalizable.filterTitle)
            static let all = String(localized: .CollectionLocalizable.filterAll)
            static let reading = String(localized: .CollectionLocalizable.filterReading)
            static let complete = String(localized: .CollectionLocalizable.filterComplete)
            static let incomplete = String(localized: .CollectionLocalizable.filterIncomplete)
        }

        enum Sort {
            static let dateAdded = String(localized: .CollectionLocalizable.sortDateAdded)
            static let progress = String(localized: .CollectionLocalizable.sortProgress)
            static let title = String(localized: .CollectionLocalizable.sortTitle)
        }

        enum Actions {
            static let add = String(localized: .CollectionLocalizable.actionsAdd)
            static let manage = String(localized: .CollectionLocalizable.actionsManage)
        }

        enum Search {
            static let placeholder = String(localized: .CollectionLocalizable.searchPlaceholder)
            static let emptyTitle = String(localized: .CollectionLocalizable.searchEmptyTitle)
            static func emptyMessage(_ searchText: String) -> String {
                String(localized: .CollectionLocalizable.searchEmptyMessage(searchText))
            }
        }

        enum Empty {
            static let allTitle = String(localized: .CollectionLocalizable.emptyAllTitle)
            static let allMessage = String(localized: .CollectionLocalizable.emptyAllMessage)
            static let readingTitle = String(localized: .CollectionLocalizable.emptyReadingTitle)
            static let readingMessage = String(localized: .CollectionLocalizable.emptyReadingMessage)
            static let completeTitle = String(localized: .CollectionLocalizable.emptyCompleteTitle)
            static let completeMessage = String(localized: .CollectionLocalizable.emptyCompleteMessage)
            static let incompleteTitle = String(localized: .CollectionLocalizable.emptyIncompleteTitle)
            static let incompleteMessage = String(localized: .CollectionLocalizable.emptyIncompleteMessage)
        }

        enum Card {
            static let complete = String(localized: .CollectionLocalizable.cardComplete)
            static let volumeSingular = String(localized: .CollectionLocalizable.cardVolumeSingular)
            static let volumePlural = String(localized: .CollectionLocalizable.cardVolumePlural)
            static let progress = String(localized: .CollectionLocalizable.cardProgress)
            static let edit = String(localized: .CollectionLocalizable.cardEdit)
            static let delete = String(localized: .CollectionLocalizable.cardDelete)
            static func reading(_ volume: Int) -> String {
                String(localized: .CollectionLocalizable.cardReading(volume))
            }
        }

        enum Stats {
            static let title = String(localized: .CollectionLocalizable.statsTitle)
            static let totalMangas = String(localized: .CollectionLocalizable.statsTotalMangas)
            static let totalVolumes = String(localized: .CollectionLocalizable.statsTotalVolumes)
            static let completed = String(localized: .CollectionLocalizable.statsCompleted)
            static let reading = String(localized: .CollectionLocalizable.statsReading)
            static let averageProgress = String(localized: .CollectionLocalizable.statsAverageProgress)
            static let completionRate = String(localized: .CollectionLocalizable.statsCompletionRate)
            static let topSeries = String(localized: .CollectionLocalizable.statsTopSeries)
            static let recentlyAdded = String(localized: .CollectionLocalizable.statsRecentlyAdded)
            static let recentlyUpdated = String(localized: .CollectionLocalizable.statsRecentlyUpdated)
            static let overview = String(localized: .CollectionLocalizable.statsOverview)
            static let details = String(localized: .CollectionLocalizable.statsDetails)
        }

        enum Edit {
            static let title = String(localized: .CollectionLocalizable.editTitle)
            static let sectionTitle = String(localized: .CollectionLocalizable.editSectionTitle)
            static let currentVolume = String(localized: .CollectionLocalizable.editCurrentVolume)
            static let volumePlaceholder = String(localized: .CollectionLocalizable.editVolumePlaceholder)
            static let completeCollection = String(localized: .CollectionLocalizable.editCompleteCollection)
            static func volumesOwned(_ count: Int) -> String {
                String(localized: .CollectionLocalizable.editVolumesOwned(count))
            }
            static func totalVolumes(_ count: Int) -> String {
                String(localized: .CollectionLocalizable.editTotalVolumes(count))
            }
        }

        enum Delete {
            static let title = String(localized: .CollectionLocalizable.deleteTitle)
            static let confirm = String(localized: .CollectionLocalizable.deleteConfirm)
            static func message(_ title: String) -> String {
                String(localized: .CollectionLocalizable.deleteMessage(title))
            }
        }

        enum Error {
            static let contextNotAvailable = String(localized: .CollectionLocalizable.errorContextNotAvailable)
            static let alreadyExists = String(localized: .CollectionLocalizable.errorAlreadyExists)
            static let notFound = String(localized: .CollectionLocalizable.errorNotFound)
            static let saveFailed = String(localized: .CollectionLocalizable.errorSaveFailed)
            static let updateFailed = String(localized: .CollectionLocalizable.errorUpdateFailed)
            static let deleteFailed = String(localized: .CollectionLocalizable.errorDeleteFailed)
        }
    }
}
