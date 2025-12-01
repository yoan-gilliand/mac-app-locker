//
//  AppMonitorService.swift
//  MacAppLocker
//
//  Created by Antigravity on 2025-12-01.
//  Service responsible for monitoring running applications and detecting activation of locked apps.
//

import AppKit
import Combine
import Foundation

/// Service that monitors system application events.
@MainActor
final class AppMonitorService: ObservableObject {
    // MARK: - Properties

    private let logger: LoggerService
    private let persistenceService: PersistenceService
    private let authenticationService: AuthenticationService
    private let lockScreenController: LockScreenWindowController
    private var cancellables = Set<AnyCancellable>()

    /// Tracks the bundle identifier of the currently unlocked app to prevent re-locking loop.
    private var unlockedSessionBundleID: String?

    /// Set of apps that are currently locked and should be kept hidden.
    private var currentlyLockedApps: Set<NSRunningApplication> = []

    // MARK: - Initialization

    init(logger: LoggerService, persistenceService: PersistenceService, authenticationService: AuthenticationService) {
        self.logger = logger
        self.persistenceService = persistenceService
        self.authenticationService = authenticationService
        lockScreenController = LockScreenWindowController(logger: logger)

        // Start the enforcer loop
        startEnforcer()
    }

    // MARK: - Public API

    /// Starts monitoring for application activation events.
    func startMonitoring() {
        logger.info("AppMonitorService: Starting monitoring...")

        NSWorkspace.shared.notificationCenter.publisher(for: NSWorkspace.didActivateApplicationNotification)
            .sink { [weak self] notification in
                self?.handleAppActivation(notification)
            }
            .store(in: &cancellables)

        NSWorkspace.shared.notificationCenter.publisher(for: NSWorkspace.didDeactivateApplicationNotification)
            .sink { [weak self] notification in
                self?.handleAppDeactivation(notification)
            }
            .store(in: &cancellables)
    }

    /// Stops monitoring.
    func stopMonitoring() {
        logger.info("AppMonitorService: Stopping monitoring.")
        cancellables.removeAll()
        currentlyLockedApps.removeAll()
    }

    // MARK: - Private Helpers

    private func startEnforcer() {
        Task { @MainActor in
            while true {
                // Check every 0.5 seconds
                try? await Task.sleep(nanoseconds: 500_000_000)

                for app in currentlyLockedApps {
                    if !app.isTerminated, !app.isHidden {
                        logger.debug("Enforcer: Re-hiding \(app.localizedName ?? "App")")
                        app.hide()

                        // Ensure our lock screen is top if we are re-hiding
                        // This handles the case where user clicked the app in Dock
                        NSApp.activate(ignoringOtherApps: true)
                        lockScreenController.show(
                            appName: app.localizedName ?? "App",
                            onUnlock: { [weak self] in
                                Task { await self?.performUnlock(for: app) }
                            },
                            onQuit: { [weak self] in
                                self?.performQuit(for: app)
                            }
                        )
                    }
                }

                // Cleanup terminated apps
                currentlyLockedApps = currentlyLockedApps.filter { !$0.isTerminated }
            }
        }
    }

    private func handleAppActivation(_ notification: Notification) {
        guard let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
              let bundleIdentifier = app.bundleIdentifier
        else {
            return
        }

        // If this app is currently in an unlocked session, ignore.
        if bundleIdentifier == unlockedSessionBundleID {
            logger.debug("App \(bundleIdentifier) is currently unlocked. Allowing access.")
            return
        }

        logger.debug("App activated: \(bundleIdentifier)")

        // Check if app is locked
        Task { @MainActor in
            if persistenceService.isAppLocked(bundleIdentifier: bundleIdentifier) {
                logger.warning("LOCKED APP DETECTED: \(bundleIdentifier)")
                await lockApp(app)
            }
        }
    }

    private func handleAppDeactivation(_ notification: Notification) {
        guard let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
              let bundleIdentifier = app.bundleIdentifier
        else {
            return
        }

        // If the unlocked app is deactivated (user switched away), clear the session.
        // Next time they come back, it will lock again.
        if bundleIdentifier == unlockedSessionBundleID {
            logger.info("Unlocked app \(bundleIdentifier) deactivated. Locking session.")
            unlockedSessionBundleID = nil
        }
    }

    @MainActor
    private func lockApp(_ app: NSRunningApplication) async {
        let appName = app.localizedName ?? "App"

        // Add to locked set for Enforcer
        currentlyLockedApps.insert(app)

        // 1. Steal focus IMMEDIATELY.
        NSApp.activate(ignoringOtherApps: true)

        // 2. Show Lock Screen Overlay
        lockScreenController.show(
            appName: appName,
            onUnlock: { [weak self] in
                Task {
                    await self?.performUnlock(for: app)
                }
            },
            onQuit: { [weak self] in
                self?.performQuit(for: app)
            }
        )

        // 3. Aggressively hide the app
        for _ in 1 ... 5 {
            if app.isHidden { break }
            app.hide()
            try? await Task.sleep(nanoseconds: 50_000_000)
        }
    }

    @MainActor
    private func performQuit(for app: NSRunningApplication) {
        logger.info("User requested to quit locked app: \(app.localizedName ?? "Unknown")")
        app.terminate()
        currentlyLockedApps.remove(app)
        lockScreenController.hide()
    }

    @MainActor
    private func performUnlock(for app: NSRunningApplication) async {
        // 4. Authenticate
        let authenticated = await authenticationService.authenticate()

        if authenticated {
            logger.info("Authentication successful. Unlocking \(app.localizedName ?? "Unknown")")

            // Remove from Enforcer
            currentlyLockedApps.remove(app)

            // 5. Set Session State to allow re-activation
            unlockedSessionBundleID = app.bundleIdentifier

            // 6. Hide Lock Screen
            lockScreenController.hide()

            // 7. Unhide and Activate the app
            app.unhide()
            app.activate(options: .activateIgnoringOtherApps)
        } else {
            logger.warning("Authentication failed. Keeping \(app.localizedName ?? "Unknown") locked.")
            // Ensure we stay on top
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}
