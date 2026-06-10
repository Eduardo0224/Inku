//
//  ComplicationEntryView.swift
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

import SwiftUI
import WidgetKit

// MARK: - Complication Entry View

struct ComplicationEntryView: View {

    // MARK: - Properties

    let entry: WatchWidgetEntry

    // MARK: - Environment

    @Environment(\.widgetFamily) private var family

    // MARK: - Body

    var body: some View {
        switch family {
        case .accessoryRectangular:
            RectangularComplicationView(entry: entry)
        case .accessoryCircular:
            CircularComplicationView(entry: entry)
        case .accessoryCorner:
            CornerComplicationView(entry: entry)
        case .accessoryInline:
            InlineComplicationView(entry: entry)
        default:
            RectangularComplicationView(entry: entry)
        }
    }
}
