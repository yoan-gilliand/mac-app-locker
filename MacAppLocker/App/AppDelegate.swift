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
        // Get container from the app
        guard let app = NSApp.delegate as? NSObject,
              let container = Mirror(reflecting: app).children.first(where: { $0.label == "container" })?.value as? DIContainer
        else {
            print("⚠️ Could not get DIContainer from app")
            return
        }

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
        return false
    }
}
