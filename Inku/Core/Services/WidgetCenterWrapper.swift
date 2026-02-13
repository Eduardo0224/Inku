//
//  WidgetCenterWrapper.swift
//  Inku
//
//  Created by Eduardo Andrade on 12/02/26.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2026 Eduardo Andrade. All rights reserved.

import WidgetKit

final class WidgetCenterWrapper: WidgetCenterProtocol {

    // MARK: - Functions

    func refreshInkuWidgets() {
        WidgetCenter.shared.reloadAllTimelines()
    }
}
