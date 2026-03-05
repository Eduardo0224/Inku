//
//  Logger+Inku.swift
//  Inku
//
//  Created by Eduardo Andrade on 04/03/26.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2026 Eduardo Andrade. All rights reserved.
//

import Foundation
import os

extension Logger {

    // MARK: - Private Properties

    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.sdp26.inku"

    // MARK: - Feature Loggers

    /// Logger for MangaList feature
    static let mangaList = Logger(subsystem: subsystem, category: "MangaList")

    /// Logger for Search feature
    static let search = Logger(subsystem: subsystem, category: "Search")

    /// Logger for AdvancedFilters feature
    static let advancedFilters = Logger(subsystem: subsystem, category: "AdvancedFilters")

    /// Logger for Authentication feature
    static let auth = Logger(subsystem: subsystem, category: "Authentication")

    /// Logger for Core services
    static let core = Logger(subsystem: subsystem, category: "Core")
}
