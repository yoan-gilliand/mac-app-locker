//
//  LockedApp.swift
//  MacAppLocker
//
//  Created by Antigravity on 2025-12-01.
//  SwiftData model representing an application that is locked.
//

import Foundation
import SwiftData

@Model
final class LockedApp {
    // MARK: - Properties

    /// The unique bundle identifier of the application (e.g., "com.apple.Safari").
    @Attribute(.unique) var bundleIdentifier: String

    /// The display name of the application.
    var name: String

    /// The path to the application bundle.
    var path: String

    /// Date when the app was added to the locker.
    var dateAdded: Date

    /// Whether the lock is currently active for this app.
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
