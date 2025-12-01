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

    // MARK: - Public API

    /// Sets up the menu bar status item.
    func setupMenuBar() {
        // Initial setup based on settings
        updateMenuBarVisibility()

        // Listen for changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateMenuBarVisibility),
            name: NSNotification.Name("UpdateMenuBarVisibility"),
            object: nil
        )
    }

    @objc private func updateMenuBarVisibility() {
        let shouldShow = container.settingsService.showMenuBarIcon

        if shouldShow, statusItem == nil {
            // Create status item
            statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

            // Configure button
            if let button = statusItem?.button {
                button.image = NSImage(
                    systemSymbolName: "lock.shield.fill",
                    accessibilityDescription: "Mac App Locker"
                )
                button.image?.isTemplate = true
            }

            // Set up menu
            statusItem?.menu = createMenu()
        } else if !shouldShow, let statusItem {
            // Remove status item
            NSStatusBar.system.removeStatusItem(statusItem)
            self.statusItem = nil
        }
    }

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
        // Activate the app
        NSApp.activate(ignoringOtherApps: true)

        // Post notification to show dashboard
        NotificationCenter.default.post(name: NSNotification.Name("ShowDashboard"), object: nil)
    }

    @objc private func showPreferences() {
        // Activate the app
        NSApp.activate(ignoringOtherApps: true)

        // Post notification to show settings
        NotificationCenter.default.post(name: NSNotification.Name("ShowSettings"), object: nil)
    }
}
