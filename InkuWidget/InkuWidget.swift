//
//  InkuWidget.swift
//  Inku
//
//  Created by Eduardo Andrade on 10/02/26.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2026 Eduardo Andrade. All rights reserved.

import WidgetKit
import SwiftUI
import SwiftData
import InkuUI

// MARK: - Image Extensions (Multi-platform)

#if os(iOS) || os(visionOS)
import UIKit

extension UIImage {
    func resized(toMaxDimension maxDimension: CGFloat) -> UIImage? {
        let scale = min(maxDimension / size.width, maxDimension / size.height)

        guard scale < 1.0 else {
            return self
        }

        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)

        return renderer.image { context in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
#elseif os(macOS)
import AppKit

extension NSImage {
    func resized(toMaxDimension maxDimension: CGFloat) -> NSImage? {
        let scale = min(maxDimension / size.width, maxDimension / size.height)

        guard scale < 1.0 else {
            return self
        }

        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let resizedImage = NSImage(size: newSize)

        resizedImage.lockFocus()
        draw(in: NSRect(origin: .zero, size: newSize))
        resizedImage.unlockFocus()

        return resizedImage
    }

    var jpegData: Data? {
        guard let tiffData = tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData) else {
            return nil
        }
        return bitmap.representation(using: .jpeg, properties: [.compressionFactor: 0.8])
    }
}
#endif

// MARK: - URLSession Extension

extension URLSession {

    func dataWithTimeout(from url: URL, timeout: TimeInterval = 5.0) async throws -> (Data, URLResponse) {
        try await withThrowingTaskGroup(of: (Data, URLResponse).self) { group in

            group.addTask {
                try await self.data(from: url)
            }

            group.addTask {
                try await Task.sleep(for: .seconds(timeout))
                throw URLError(.timedOut)
            }

            guard let result = try await group.next() else {
                throw URLError(.unknown)
            }

            group.cancelAll()
            return result
        }
    }
}

// MARK: - Widget Entry

struct InkuWidgetEntry: TimelineEntry {

    // MARK: - Properties

    let date: Date
    let mangas: [WidgetMangaData]

    // MARK: - Computed Properties

    var isEmpty: Bool {
        mangas.isEmpty
    }
}

// MARK: - Widget Manga Data

struct WidgetMangaData: Identifiable {

    // MARK: - Properties

    let id: Int
    let title: String
    let japaneseTitle: String?
    let coverURL: String?
    let coverImageData: Data?
    let volumesOwned: Int
    let totalVolumes: Int?
    let currentReading: Int?
    let isComplete: Bool

    // MARK: - Computed Properties

    var coverImageURL: URL? {
        guard let coverURL else {
            return nil
        }

        let cleanURL = coverURL.replacingOccurrences(of: "\"", with: "")
        return URL(string: cleanURL)
    }

    var progress: Double? {
        guard let total = totalVolumes, total > 0 else {
            return nil
        }

        return Double(volumesOwned) / Double(total)
    }

    var isCurrentlyReading: Bool {
        currentReading != nil
    }
}

// MARK: - Timeline Provider

struct InkuWidgetProvider: TimelineProvider {

    // MARK: - Placeholder

    func placeholder(in context: Context) -> InkuWidgetEntry {
        InkuWidgetEntry(
            date: Date(),
            mangas: [
                WidgetMangaData(
                    id: 1,
                    title: "Naruto",
                    japaneseTitle: "NARUTO―ナルト―",
                    coverURL: "https://cdn.myanimelist.net/images/manga/3/249658l.jpg",
                    coverImageData: try? Data(contentsOf: URL(string: "https://cdn.myanimelist.net/images/manga/3/249658l.jpg")!),
                    volumesOwned: 50,
                    totalVolumes: 106,
                    currentReading: 51,
                    isComplete: false
                )
            ]
        )
    }

    // MARK: - Snapshot

    func getSnapshot(in context: Context, completion: @escaping (InkuWidgetEntry) -> Void) {
        Task {
            let entry: InkuWidgetEntry

            if context.isPreview {
                entry = placeholder(in: context)
            } else {
                entry = await fetchMangas()
            }

            completion(entry)
        }
    }

    // MARK: - Timeline

    func getTimeline(in context: Context, completion: @escaping (Timeline<InkuWidgetEntry>) -> Void) {
        Task {
            let entry = await fetchMangas()
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: .now) ?? Date().addingTimeInterval(600)
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
        }
    }

    // MARK: - Private Functions

    private func fetchMangas() async -> InkuWidgetEntry {
        let context = ModelContext(SharedModelContainer.shared)

        let descriptor = FetchDescriptor<CollectionManga>(
            sortBy: [
                SortDescriptor(\.lastModified, order: .reverse)
            ]
        )

        do {
            let mangas = try context.fetch(descriptor)

            let widgetData = await withTaskGroup(of: WidgetMangaData?.self) { group in
                for manga in mangas.prefix(6) {
                    group.addTask {
                        await self.loadMangaData(manga)
                    }
                }

                var results: [WidgetMangaData] = []
                for await result in group {
                    if let data = result {
                        results.append(data)
                    }
                }
                return results
            }

            return InkuWidgetEntry(date: Date(), mangas: widgetData)
        } catch {
            return InkuWidgetEntry(date: Date(), mangas: [])
        }
    }

    private func loadMangaData(_ manga: CollectionManga) async -> WidgetMangaData {
        var imageData: Data?

        if let urlString = manga.coverImageURL,
           let url = URL(string: urlString.replacingOccurrences(of: "\"", with: "")) {
            do {
                let (data, _) = try await URLSession.shared.dataWithTimeout(from: url, timeout: 5.0)

                #if os(iOS) || os(visionOS)
                if let originalImage = UIImage(data: data),
                   let resizedImage = originalImage.resized(toMaxDimension: 200) {
                    imageData = resizedImage.jpegData(compressionQuality: 0.8)
                } else {
                    imageData = data
                }
                #elseif os(macOS)
                if let originalImage = NSImage(data: data),
                   let resizedImage = originalImage.resized(toMaxDimension: 200) {
                    imageData = resizedImage.jpegData
                } else {
                    imageData = data
                }
                #endif
            } catch { }
        }

        return WidgetMangaData(
            id: manga.mangaId,
            title: manga.title,
            japaneseTitle: manga.japaneseTitle,
            coverURL: manga.coverImageURL,
            coverImageData: imageData,
            volumesOwned: manga.volumesOwnedCount,
            totalVolumes: manga.totalVolumes,
            currentReading: manga.currentReadingVolume,
            isComplete: manga.isComplete
        )
    }
}

// MARK: - Widget Configuration

struct InkuCollectionWidget: Widget {

    // MARK: - Properties

    let kind: String = "InkuCollectionWidget"

    // MARK: - Body

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: InkuWidgetProvider()) { entry in
            InkuWidgetEntryView(entry: entry)
                .containerBackground(Color.inkuSurface, for: .widget)
                .widgetURL(URL(string: "inku://collection"))
        }
        .configurationDisplayName(L10n.Widget.collection)
        .description(L10n.Widget.description)
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge])
    }
}
