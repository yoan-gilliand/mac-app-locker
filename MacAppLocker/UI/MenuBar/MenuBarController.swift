//
//  MenuBarController.swift
//  MacAppLocker
//
//  Created by Antigravity on 2025-12-01.
//  Manages the menu bar status item and its menu.
//

import AppKit
import Combine
import SwiftUI

/// Controller for the menu bar status item.
@MainActor
final class MenuBarController: ObservableObject {
    // MARK: - Properties

    private var statusItem: NSStatusItem?
    private let container: DIContainer

    // MARK: - Initialization

    init(container: DIContainer) {
        self.container = container
    }

    // MARK: - Public API

    /// Sets up the menu bar status item.
    func setupMenuBar() {
        // Create status item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        // Configure button
        if let button = statusItem?.button {
            button.image = NSImage(
                systemSymbolName: "lock.shield.fill",
                accessibilityDescription: "Mac App Locker"
            )
            button.image?.isTemplate = true // Allows proper light/dark mode
        }

        // Set up menu
        statusItem?.menu = createMenu()
    }

    /// Removes the menu bar status item.
    /// Removes the menu bar status item.
    func tearDownMenuBar() {
        if let statusItem {
            NSStatusBar.system.removeStatusItem(statusItem)
        }
        statusItem = nil
    }

    // MARK: - Private Methods

    private func createMenu() -> NSMenu {
        let menu = NSMenu()

        // Dashboard
        let showDashboard = NSMenuItem(
            title: "Show Dashboard",
            action: #selector(showDashboardWindow),
            keyEquivalent: ""
        )
        showDashboard.target = self
        menu.addItem(showDashboard)

        menu.addItem(.separator())

        // Locked apps count
        let lockedAppsCount = container.persistenceService.fetchLockedApps().count
        let statusItem = NSMenuItem(
            title: "\(lockedAppsCount) app\(lockedAppsCount == 1 ? "" : "s") locked",
            action: nil,
            keyEquivalent: ""
        )
        statusItem.isEnabled = false
        menu.addItem(statusItem)

        menu.addItem(.separator())

        // Preferences
        let preferences = NSMenuItem(
            title: "Preferences...",
            action: #selector(showPreferences),
            keyEquivalent: ","
        )
        preferences.target = self
        menu.addItem(preferences)

        menu.addItem(.separator())

        // Quit
        let quit = NSMenuItem(
            title: "Quit Mac App Locker",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        )
        menu.addItem(quit)

        return menu
    }

    @objc private func showDashboardWindow() {
        // Activate the app and show all windows
        NSApp.activate(ignoringOtherApps: true)

        // Find and show the main window
        if let window = NSApp.windows.first(where: { $0.identifier?.rawValue.contains("WindowGroup") ?? false }) {
            window.makeKeyAndOrderFront(nil)
        }
    }

    @objc private func showPreferences() {
        // Open Settings window by sending the standard preferences action
        NSApp.activate(ignoringOtherApps: true)
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
    }
}
