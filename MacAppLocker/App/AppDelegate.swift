//
// ******************************************************************************
// @file        AppDelegate.swift
// @brief       File: AppDelegate.swift
// @author      Yoan Gilliand
// @editor      Yoan Gilliand
// @date        01 Dec 2025
// ******************************************************************************
// @copyright   Copyright (c) 2025 Yoan Gilliand. All rights reserved.
// ******************************************************************************
// @details
// Application delegate for managing app lifecycle and menu bar.
// ******************************************************************************
//
import AppKit
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    // MARK: - Properties

    private var menuBarController: MenuBarController?
    private var container: DIContainer?

    // MARK: - Application Lifecycle

    func applicationDidFinishLaunching(_: Notification) {
        let container = DIContainer.shared
        self.container = container

        menuBarController = MenuBarController(container: container)
        menuBarController?.setupMenuBar()

        NSApp.setActivationPolicy(.regular)
    }

    func applicationWillTerminate(_: Notification) {
        menuBarController?.tearDownMenuBar()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool {
        false
    }

    func applicationShouldHandleReopen(_: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            NotificationCenter.default.post(name: NSNotification.Name("ShowDashboard"), object: nil)
        }
        return true
    }
}
