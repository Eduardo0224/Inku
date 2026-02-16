//
//  SpyWidgetCenter.swift
//  InkuTests
//
//  Created by Eduardo Andrade on 12/02/26.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2026 Eduardo Andrade. All rights reserved.

import Foundation
@testable import Inku

final class SpyWidgetCenter: WidgetCenterProtocol {

    // MARK: - Properties

    private(set) var refreshInkuWidgetsWasCalled = false

    // MARK: - Functions

    func refreshInkuWidgets() {
        refreshInkuWidgetsWasCalled = true
    }

    func reset() {
        refreshInkuWidgetsWasCalled = false
    }
}
