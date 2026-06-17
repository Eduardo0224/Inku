//
//  InkuWatchWidget.swift
//  InkuWatchWidget
//
//  Created by Eduardo Andrade on 02/06/26.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2026 Eduardo Andrade. All rights reserved.
//

import WidgetKit
import SwiftUI
import SwiftData
import InkuUI

// MARK: - Timeline Entry

struct WatchWidgetEntry: TimelineEntry {
    let date: Date
    let currentlyReading: String?
    let currentChapter: String?
    let readingProgressFraction: Double?
    let latestCover: Data?
    let latestTitle: String?
    let readingCount: Int
    let totalCollectionCount: Int
}

// MARK: - Timeline Provider

@MainActor
struct WatchWidgetProvider: TimelineProvider {

    // MARK: - Placeholder

    func placeholder(in context: Context) -> WatchWidgetEntry {
        WatchWidgetEntry(
            date: Date(),
            currentlyReading: "One Piece",
            currentChapter: L10n.Watch.volumeWithTotalFormat(51, 106),
            readingProgressFraction: 0.48,
            latestCover: nil,
            latestTitle: "One Piece",
            readingCount: 3,
            totalCollectionCount: 47
        )
    }

    // MARK: - Snapshot

    func getSnapshot(in context: Context, completion: @escaping (WatchWidgetEntry) -> Void) {
        let entry = loadEntry()
        completion(entry)
    }

    // MARK: - Timeline

    func getTimeline(in context: Context, completion: @escaping (Timeline<WatchWidgetEntry>) -> Void) {
        let entry = loadEntry()
        let nextRefresh = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextRefresh))
        completion(timeline)
    }

    // MARK: - Private

    /// App Group store URL matching `WatchStoreConfiguration.storeURL`
    /// so the widget reads the same SQLite file as the main watch app.
    private static var storeURL: URL {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: "group.com.sdp26.inku")!
            .appendingPathComponent("InkuWatch.sqlite")
    }

    private func loadEntry() -> WatchWidgetEntry {
        let config = ModelConfiguration(
            "InkuWatch",
            url: Self.storeURL,
            cloudKitDatabase: .none
        )
        guard let container = try? ModelContainer(
            for: WatchMangaItem.self,
            configurations: config
        ) else {
            return WatchWidgetEntry(
                date: Date(),
                currentlyReading: nil,
                currentChapter: nil,
                readingProgressFraction: nil,
                latestCover: nil,
                latestTitle: nil,
                readingCount: 0,
                totalCollectionCount: 0
            )
        }
        let context = container.mainContext

        // Currently reading (most recently synced active manga)
        let readingDescriptor = FetchDescriptor<WatchMangaItem>(
            predicate: #Predicate { $0.currentReadingVolume != nil },
            sortBy: [SortDescriptor(\.lastSynced, order: .reverse)]
        )
        let readingMangas = (try? context.fetch(readingDescriptor)) ?? []
        let reading = readingMangas.first

        // Aggregate counts
        let readingCount = readingMangas.count

        let allDescriptor = FetchDescriptor<WatchMangaItem>()
        let totalCollectionCount = (try? context.fetch(allDescriptor).count) ?? 0

        // Latest added (most recent by sync date)
        let latestDescriptor = FetchDescriptor<WatchMangaItem>(
            sortBy: [SortDescriptor(\.lastSynced, order: .reverse)]
        )
        let latest = (try? context.fetch(latestDescriptor))?.first

        var currentChapter: String?
        var readingProgressFraction: Double?
        if let r = reading, let current = r.currentReadingVolume {
            if let total = r.totalVolumes, total > 0 {
                currentChapter = L10n.Watch.volumeWithTotalFormat(current, total)
                readingProgressFraction = Double(current) / Double(total)
            } else {
                currentChapter = L10n.Watch.volumeFormat(current)
            }
        }

        return WatchWidgetEntry(
            date: Date(),
            currentlyReading: reading?.title,
            currentChapter: currentChapter,
            readingProgressFraction: readingProgressFraction,
            latestCover: latest?.coverImageData,
            latestTitle: latest?.title,
            readingCount: readingCount,
            totalCollectionCount: totalCollectionCount
        )
    }
}

// MARK: - Widget Configuration

struct InkuWatchWidget: Widget {
    let kind = "com.sdp26-ea.Inku.watchkitapp.InkuWatchWidget.collection"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: WatchWidgetProvider()
        ) { entry in
            ComplicationEntryView(entry: entry)
        }
        .configurationDisplayName(L10n.Watch.inkuCollection)
        .description(L10n.Widget.description)
        .supportedFamilies([
            .accessoryRectangular,
            .accessoryCircular,
            .accessoryCorner,
            .accessoryInline
        ])
    }
}
