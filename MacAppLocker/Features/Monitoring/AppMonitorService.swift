//
// ******************************************************************************
// @file        AppMonitorService.swift
// @brief       File: AppMonitorService.swift
// @author      Yoan Gilliand
// @editor      Yoan Gilliand
// @date        01 Dec 2025
// ******************************************************************************
// @copyright   Copyright (c) 2025 Yoan Gilliand. All rights reserved.
// ******************************************************************************
// @details
// Service for monitoring running applications and enforcing locks.
// ******************************************************************************
//
import AppKit
import Combine
import Foundation

@MainActor
final class AppMonitorService: ObservableObject {
    // MARK: - Properties

    private let logger: LoggerService
    private let persistenceService: PersistenceService
    private let authenticationService: AuthenticationService
    private let lockScreenController: LockScreenWindowController
    private var cancellables = Set<AnyCancellable>()

    private var unlockedSessionBundleID: String?

    private var currentlyLockedApps: Set<NSRunningApplication> = []

    // MARK: - Initialization

    init(logger: LoggerService, persistenceService: PersistenceService, authenticationService: AuthenticationService) {
        self.logger = logger
        self.persistenceService = persistenceService
        self.authenticationService = authenticationService
        lockScreenController = LockScreenWindowController(logger: logger)

        startEnforcer()
    }

    // MARK: - Public API

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

    func stopMonitoring() {
        logger.info("AppMonitorService: Stopping monitoring.")
        cancellables.removeAll()
        currentlyLockedApps.removeAll()
    }

    // MARK: - Private Helpers

    private func startEnforcer() {
        Task { @MainActor in
            while true {
                try? await Task.sleep(nanoseconds: 500_000_000)

                for app in currentlyLockedApps {
                    if !app.isTerminated, !app.isHidden {
                        logger.debug("Enforcer: Re-hiding \(app.localizedName ?? "App")")
                        app.hide()

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

        if bundleIdentifier == unlockedSessionBundleID {
            logger.debug("App \(bundleIdentifier) is currently unlocked. Allowing access.")
            return
        }

        logger.debug("App activated: \(bundleIdentifier)")

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

        if bundleIdentifier == unlockedSessionBundleID {
            logger.info("Unlocked app \(bundleIdentifier) deactivated. Locking session.")
            unlockedSessionBundleID = nil
        }
    }

    @MainActor
    private func lockApp(_ app: NSRunningApplication) async {
        let appName = app.localizedName ?? "App"

        currentlyLockedApps.insert(app)

        NSApp.activate(ignoringOtherApps: true)

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
        let authenticated = await authenticationService.authenticate()

        if authenticated {
            logger.info("Authentication successful. Unlocking \(app.localizedName ?? "Unknown")")

            currentlyLockedApps.remove(app)

            unlockedSessionBundleID = app.bundleIdentifier

            lockScreenController.hide()

            app.unhide()
            app.activate(options: .activateIgnoringOtherApps)
        } else {
            logger.warning("Authentication failed. Keeping \(app.localizedName ?? "Unknown") locked.")
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}
