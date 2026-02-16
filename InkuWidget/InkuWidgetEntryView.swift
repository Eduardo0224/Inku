//
//  InkuWidgetEntryView.swift
//  Inku
//
//  Created by Eduardo Andrade on 11/02/26.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2026 Eduardo Andrade. All rights reserved.

import SwiftUI
import WidgetKit

struct InkuWidgetEntryView: View {

    // MARK: - Environment

    @Environment(\.widgetFamily) private var widgetFamily

    // MARK: - Properties

    let entry: InkuWidgetEntry

    // MARK: - Body

    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        case .systemExtraLarge:
            ExtraLargeWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}
