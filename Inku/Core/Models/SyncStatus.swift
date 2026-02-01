//
//  SyncStatus.swift
//  Inku
//
//  Created by Eduardo Andrade on 31/01/26.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2025 Eduardo Andrade. All rights reserved.
//

import Foundation

enum SyncStatus: Sendable {
    case pending
    case uploading
    case uploaded
    case failed
}
