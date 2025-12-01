//
// ******************************************************************************
// @file        SettingsService.swift
// @brief       File: SettingsService.swift
// @author      Yoan Gilliand
// @editor      Yoan Gilliand
// @date        01 Dec 2025
// ******************************************************************************
// @copyright   Copyright (c) 2025 Yoan Gilliand. All rights reserved.
// ******************************************************************************
// @details
// Service for managing user preferences and settings.
// ******************************************************************************
//
import AppKit
import Combine
import SwiftUI

@MainActor
final class SettingsService: ObservableObject {
    // MARK: - Properties

    private var cancellables = Set<AnyCancellable>()
    private let defaults: UserDefaults

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

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        launchAtLogin = defaults.bool(forKey: "launchAtLogin")
        showMenuBarIcon = defaults.object(forKey: "showMenuBarIcon") as? Bool ?? true
        showDockIcon = defaults.object(forKey: "showDockIcon") as? Bool ?? true

        updateDockVisibility()
    }

    // MARK: - Private Methods

    private func updateDockVisibility() {
        if showDockIcon {
            NSApp.setActivationPolicy(.regular)
        } else {
            NSApp.setActivationPolicy(.accessory)
        }

        if showDockIcon {
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    private func updateMenuBarVisibility() {
        NotificationCenter.default.post(name: NSNotification.Name("UpdateMenuBarVisibility"), object: nil)
    }
}
