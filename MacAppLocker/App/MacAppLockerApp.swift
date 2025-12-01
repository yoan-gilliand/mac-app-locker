//
// ******************************************************************************
// @file        MacAppLockerApp.swift
// @brief       File: MacAppLockerApp.swift
// @author      Yoan Gilliand
// @editor      Yoan Gilliand
// @date        01 Dec 2025
// ******************************************************************************
// @copyright   Copyright (c) 2025 Yoan Gilliand. All rights reserved.
// ******************************************************************************
// @details
// Entry point for the Mac App Locker application.
// ******************************************************************************
//
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

@main
struct MacAppLockerApp: App {
    // MARK: - Properties

    @StateObject private var container = DIContainer.shared

    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    // MARK: - Body

    var body: some Scene {
        WindowGroup {
            DashboardView(viewModel: container.makeDashboardViewModel())
                .environmentObject(container)
        }
        .windowStyle(.titleBar)
        .defaultSize(width: 800, height: 600)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("Add App to Lock...") {
                    openAppPicker()
                }
                .keyboardShortcut("n", modifiers: .command)
            }

            CommandGroup(replacing: .appInfo) {
                Button("About Mac App Locker") {
                    NotificationCenter.default.post(name: NSNotification.Name("ShowAbout"), object: nil)
                }
            }

            CommandGroup(replacing: .appSettings) {
                Button("Preferences...") {
                    NotificationCenter.default.post(name: NSNotification.Name("ShowSettings"), object: nil)
                }
                .keyboardShortcut(",", modifiers: .command)
            }

            CommandGroup(after: .sidebar) {
                Button("Refresh") {
                    refreshDashboard()
                }
                .keyboardShortcut("r", modifiers: .command)
            }

            CommandGroup(replacing: .help) {
                Button("Mac App Locker Help") {
                    if let url = URL(string: "https://github.com/yoan-gilliand/mac-app-locker") {
                        NSWorkspace.shared.open(url)
                    }
                }
            }
        }

        Window("Settings", id: "settings") {
            SettingsView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultPosition(.center)
        .keyboardShortcut(",", modifiers: .command)

        Window("About Mac App Locker", id: "about") {
            AboutView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultPosition(.center)
    }

    // MARK: - Helper Methods

    private func openAppPicker() {
        guard let window = NSApp.keyWindow ?? NSApp.mainWindow ?? NSApp.windows.first else {
            return
        }

        let panel = NSOpenPanel()
        panel.message = "Choose an application to lock"
        panel.prompt = "Lock App"
        panel.allowedContentTypes = [.application]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false

        panel.beginSheetModal(for: window) { response in
            guard response == .OK, let url = panel.url else { return }

            let appName = url.deletingPathExtension().lastPathComponent
            let bundleID = Bundle(url: url)?.bundleIdentifier ?? "unknown.app"

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
        NotificationCenter.default.post(name: NSNotification.Name("RefreshDashboard"), object: nil)
    }
}
