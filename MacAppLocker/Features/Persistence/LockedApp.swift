//
// ******************************************************************************
// @file        LockedApp.swift
// @brief       File: LockedApp.swift
// @author      Yoan Gilliand
// @editor      Yoan Gilliand
// @date        01 Dec 2025
// ******************************************************************************
// @copyright   Copyright (c) 2025 Yoan Gilliand. All rights reserved.
// ******************************************************************************
// @details
// Data model representing a locked application.
// ******************************************************************************
//
import Foundation
import SwiftData

@Model
final class LockedApp {
    // MARK: - Properties

    @Attribute(.unique) var bundleIdentifier: String

    var name: String

    var path: String

    var dateAdded: Date

    var isLocked: Bool

    // MARK: - Initialization

    init(bundleIdentifier: String, name: String, path: String, isLocked: Bool = true) {
        self.bundleIdentifier = bundleIdentifier
        self.name = name
        self.path = path
        dateAdded = Date()
        self.isLocked = isLocked
    }
}
