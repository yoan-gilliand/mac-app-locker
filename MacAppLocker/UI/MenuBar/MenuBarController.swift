//
// ******************************************************************************
// @file        MenuBarController.swift
// @brief       File: MenuBarController.swift
// @author      Yoan Gilliand
// @editor      Yoan Gilliand
// @date        01 Dec 2025
// ******************************************************************************
// @copyright   Copyright (c) 2025 Yoan Gilliand. All rights reserved.
// ******************************************************************************
// @details
// Controller for the menu bar status item and menu.
// ******************************************************************************
//
import AppKit
import Combine
import SwiftUI

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

    func setupMenuBar() {
        updateMenuBarVisibility()

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
            statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

            if let button = statusItem?.button {
                button.image = NSImage(
                    systemSymbolName: "lock.shield.fill",
                    accessibilityDescription: "Mac App Locker"
                )
                button.image?.isTemplate = true
            }

            statusItem?.menu = createMenu()
        } else if !shouldShow, let statusItem {
            NSStatusBar.system.removeStatusItem(statusItem)
            self.statusItem = nil
        }
    }

    func tearDownMenuBar() {
        if let statusItem {
            NSStatusBar.system.removeStatusItem(statusItem)
        }
        statusItem = nil
    }

    // MARK: - Private Methods

    private func createMenu() -> NSMenu {
        let menu = NSMenu()

        let showDashboard = NSMenuItem(
            title: "Show Dashboard",
            action: #selector(showDashboardWindow),
            keyEquivalent: ""
        )
        showDashboard.target = self
        menu.addItem(showDashboard)

        menu.addItem(.separator())

        let lockedAppsCount = container.persistenceService.fetchLockedApps().count
        let statusItem = NSMenuItem(
            title: "\(lockedAppsCount) app\(lockedAppsCount == 1 ? "" : "s") locked",
            action: nil,
            keyEquivalent: ""
        )
        statusItem.isEnabled = false
        menu.addItem(statusItem)

        menu.addItem(.separator())

        let preferences = NSMenuItem(
            title: "Preferences...",
            action: #selector(showPreferences),
            keyEquivalent: ","
        )
        preferences.target = self
        menu.addItem(preferences)

        menu.addItem(.separator())

        let quit = NSMenuItem(
            title: "Quit Mac App Locker",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        )
        menu.addItem(quit)

        return menu
    }

    @objc private func showDashboardWindow() {
        NSApp.activate(ignoringOtherApps: true)

        NotificationCenter.default.post(name: NSNotification.Name("ShowDashboard"), object: nil)
    }

    @objc private func showPreferences() {
        NSApp.activate(ignoringOtherApps: true)

        NotificationCenter.default.post(name: NSNotification.Name("ShowSettings"), object: nil)
    }
}
