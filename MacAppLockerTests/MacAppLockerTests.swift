//
// ******************************************************************************
// @file        MacAppLockerTests.swift
// @brief       File: MacAppLockerTests.swift
// @author      Yoan Gilliand
// @editor      Yoan Gilliand
// @date        01 Dec 2025
// ******************************************************************************
// @copyright   Copyright (c) 2025 Yoan Gilliand. All rights reserved.
// ******************************************************************************
// @details
// Unit tests for MacAppLocker.
// ******************************************************************************
//
@testable import MacAppLocker
import SwiftData
import XCTest

@MainActor
final class MacAppLockerTests: XCTestCase {
    // MARK: - Properties

    var persistenceService: PersistenceService?
    var settingsService: SettingsService?
    var logger: LoggerService?

    // MARK: - Setup

    override func setUp() {
        super.setUp()
        logger = LoggerService()
        // Use in-memory storage for testing
        if let logger {
            persistenceService = PersistenceService(logger: logger, inMemory: true)
        }
        // Use ephemeral UserDefaults
        if let defaults = UserDefaults(suiteName: "TestDefaults") {
            settingsService = SettingsService(defaults: defaults)
            defaults.removePersistentDomain(forName: "TestDefaults")
        }
    }

    override func tearDown() {
        persistenceService = nil
        settingsService = nil
        logger = nil
        super.tearDown()
    }

    // MARK: - Persistence Tests

    func testAddLockedApp() throws {
        let service = try XCTUnwrap(persistenceService)
        let app = LockedApp(bundleIdentifier: "com.apple.Safari", name: "Safari", path: "/Applications/Safari.app")
        service.addLockedApp(app)

        let fetchedApps = service.fetchLockedApps()
        XCTAssertEqual(fetchedApps.count, 1)
        XCTAssertEqual(fetchedApps.first?.bundleIdentifier, "com.apple.Safari")
    }

    func testRemoveLockedApp() throws {
        let service = try XCTUnwrap(persistenceService)
        let app = LockedApp(bundleIdentifier: "com.apple.Safari", name: "Safari", path: "/Applications/Safari.app")
        service.addLockedApp(app)
        XCTAssertEqual(service.fetchLockedApps().count, 1)

        service.removeLockedApp(app)
        XCTAssertEqual(service.fetchLockedApps().count, 0)
    }

    func testIsAppLocked() throws {
        let service = try XCTUnwrap(persistenceService)
        let app = LockedApp(bundleIdentifier: "com.apple.Safari", name: "Safari", path: "/Applications/Safari.app")
        app.isLocked = true
        service.addLockedApp(app)

        XCTAssertTrue(service.isAppLocked(bundleIdentifier: "com.apple.Safari"))

        app.isLocked = false
        service.updateLockedApp(app)
        XCTAssertFalse(service.isAppLocked(bundleIdentifier: "com.apple.Safari"))
    }

    func testDuplicateAppPrevention() throws {
        let service = try XCTUnwrap(persistenceService)
        let app1 = LockedApp(bundleIdentifier: "com.test.app", name: "Test App", path: "/path")
        service.addLockedApp(app1)

        let app2 = LockedApp(bundleIdentifier: "com.test.app", name: "Test App", path: "/path")
        service.addLockedApp(app2)

        XCTAssertEqual(service.fetchLockedApps().count, 1, "Should not add duplicate apps")
    }

    // MARK: - Settings Tests

    func testSettingsDefaults() throws {
        let service = try XCTUnwrap(settingsService)
        XCTAssertFalse(service.launchAtLogin, "Default launchAtLogin should be false (from empty defaults)")
        XCTAssertTrue(service.showMenuBarIcon, "Default showMenuBarIcon should be true")
    }

    func testSettingsPersistence() throws {
        let service = try XCTUnwrap(settingsService)
        service.launchAtLogin = true

        let defaults = try XCTUnwrap(UserDefaults(suiteName: "TestDefaults"))
        XCTAssertTrue(defaults.bool(forKey: "launchAtLogin"))

        service.showMenuBarIcon = false
        XCTAssertFalse(defaults.bool(forKey: "showMenuBarIcon"))
    }
}
