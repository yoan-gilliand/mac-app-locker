//
//  MacAppLockerApp.swift
//  MacAppLocker
//
//  Created by Antigravity on 2025-12-01.
//  Entry point for the Mac App Locker application.
//

import SwiftData
import SwiftUI
import UniformTypeIdentifiers

@main
struct MacAppLockerApp: App {
    // MARK: - Properties

    /// The centralized container for all dependencies.
    @StateObject private var container = DIContainer()

    /// App delegate for lifecycle management
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    // Window state
    @State private var showingSettings = false
    @State private var showingAbout = false

    // MARK: - Body

    var body: some Scene {
        // Main Dashboard Window
        WindowGroup {
            DashboardView(viewModel: container.makeDashboardViewModel())
                .environmentObject(container)
        }
        .windowStyle(.titleBar)
        .defaultSize(width: 800, height: 600)
        .commands {
            // Replace default "New" with "Add App to Lock"
            CommandGroup(replacing: .newItem) {
                Button("Add App to Lock...") {
                    openAppPicker()
                }
                .keyboardShortcut("n", modifiers: .command)
            }

            // Add About and Preferences to App menu
            CommandGroup(replacing: .appInfo) {
                Button("About Mac App Locker") {
                    showingAbout = true
                }
            }

            CommandGroup(replacing: .appSettings) {
                Button("Preferences...") {
                    showingSettings = true
                }
                .keyboardShortcut(",", modifiers: .command)
            }

            // View menu
            CommandGroup(after: .sidebar) {
                Button("Refresh") {
                    refreshDashboard()
                }
                .keyboardShortcut("r", modifiers: .command)
            }

            // Keep standard edit, window, help menus
            CommandGroup(replacing: .help) {
                Button("Mac App Locker Help") {
                    if let url = URL(string: "https://github.com/yoan-gilliand/mac-app-locker") {
                        NSWorkspace.shared.open(url)
                    }
                }
            }
        }

        // Settings Window
        Window("Settings", id: "settings") {
            SettingsView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultPosition(.center)
        .keyboardShortcut(",", modifiers: .command)

        // About Window
        Window("About Mac App Locker", id: "about") {
            AboutView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultPosition(.center)
    }

    // MARK: - Helper Methods

    private func openAppPicker() {
        // Get main window
        guard let window = NSApp.windows.first(where: { $0.identifier?.rawValue.contains("WindowGroup") ?? false }) else {
            return
        }

        // Create file picker for .app bundles
        let panel = NSOpenPanel()
        panel.message = "Choose an application to lock"
        panel.prompt = "Lock App"
        panel.allowedContentTypes = [.application]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false

        panel.beginSheetModal(for: window) { response in
            guard response == .OK, let url = panel.url else { return }

            // Get app info
            let appName = url.deletingPathExtension().lastPathComponent
            let bundleID = Bundle(url: url)?.bundleIdentifier ?? "unknown.app"

            // Add to locked apps
            let newApp = LockedApp(
                bundleIdentifier: bundleID,
                name: appName,
                path: url.path
            )

            container.persistenceService.addLockedApp(newApp)
            refreshDashboard()
        }
    }

    private func refreshDashboard() {
        // Refresh the dashboard by posting a notification
        NotificationCenter.default.post(name: NSNotification.Name("RefreshDashboard"), object: nil)
    }
}
