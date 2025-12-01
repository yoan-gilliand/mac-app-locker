//
//  AppDelegate.swift
//  MacAppLocker
//
//  Created by Antigravity on 2025-12-01.
//  Application delegate for managing app lifecycle and menu bar.
//

import AppKit
import SwiftUI

/// Custom app delegate to manage lifecycle and menu bar.
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    // MARK: - Properties

    private var menuBarController: MenuBarController?
    private var container: DIContainer?

    // MARK: - Application Lifecycle

    func applicationDidFinishLaunching(_: Notification) {
        // Get container
        let container = DIContainer.shared
        self.container = container

        // Setup menu bar
        menuBarController = MenuBarController(container: container)
        menuBarController?.setupMenuBar()

        // Configure app to show in Dock when window is open (hybrid mode)
        NSApp.setActivationPolicy(.regular)
    }

    func applicationWillTerminate(_: Notification) {
        menuBarController?.tearDownMenuBar()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool {
        // Don't quit when window is closed - keep running in menu bar
        false
    }

    func applicationShouldHandleReopen(_: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            // If no windows are visible, show the dashboard
            NotificationCenter.default.post(name: NSNotification.Name("ShowDashboard"), object: nil)
        }
        return true
    }
}
