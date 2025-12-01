//
//  SettingsService.swift
//  MacAppLocker
//
//  Created by Antigravity on 2025-12-01.
//  Service to observe and apply application settings.
//

import AppKit
import Combine
import SwiftUI

@MainActor
final class SettingsService: ObservableObject {
    // MARK: - Properties

    private var cancellables = Set<AnyCancellable>()
    private let defaults = UserDefaults.standard

    // MARK: - Published Settings

    @Published var launchAtLogin: Bool {
        didSet { defaults.set(launchAtLogin, forKey: "launchAtLogin") }
    }

    @Published var showMenuBarIcon: Bool {
        didSet {
            defaults.set(showMenuBarIcon, forKey: "showMenuBarIcon")
            updateMenuBarVisibility()
        }
    }

    @Published var showDockIcon: Bool {
        didSet {
            defaults.set(showDockIcon, forKey: "showDockIcon")
            updateDockVisibility()
        }
    }

    // MARK: - Initialization

    init() {
        launchAtLogin = defaults.bool(forKey: "launchAtLogin")
        showMenuBarIcon = defaults.object(forKey: "showMenuBarIcon") as? Bool ?? true
        showDockIcon = defaults.object(forKey: "showDockIcon") as? Bool ?? true

        // Apply initial state
        updateDockVisibility()
        // Menu bar visibility is handled by AppDelegate/MenuBarController via observation or direct call
    }

    // MARK: - Private Methods

    private func updateDockVisibility() {
        if showDockIcon {
            NSApp.setActivationPolicy(.regular)
        } else {
            NSApp.setActivationPolicy(.accessory)
        }

        // If we just showed the dock icon, we might want to activate the app
        if showDockIcon {
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    private func updateMenuBarVisibility() {
        // Post notification for AppDelegate/MenuBarController to handle
        NotificationCenter.default.post(name: NSNotification.Name("UpdateMenuBarVisibility"), object: nil)
    }
}
