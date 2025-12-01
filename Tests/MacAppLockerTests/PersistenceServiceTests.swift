@testable import MacAppLocker
import SwiftData
import XCTest

@MainActor
final class PersistenceServiceTests: XCTestCase {
    var persistenceService: PersistenceService!
    var logger: LoggerService!

    override func setUp() {
        super.setUp()
        logger = LoggerService(subsystem: "com.macapplocker.tests", category: "Persistence")
        persistenceService = PersistenceService(logger: logger, inMemory: true)
    }

    override func tearDown() {
        persistenceService = nil
        logger = nil
        super.tearDown()
    }

    // MARK: - Basic CRUD Tests

    func testAddLockedApp() {
        let app = LockedApp(bundleIdentifier: "com.test.app", name: "Test App", path: "/Applications/TestApp.app")

        persistenceService.addLockedApp(app)

        let fetchedApps = persistenceService.fetchLockedApps()
        XCTAssertEqual(fetchedApps.count, 1)
        XCTAssertEqual(fetchedApps.first?.bundleIdentifier, "com.test.app")
        XCTAssertEqual(fetchedApps.first?.name, "Test App")
        XCTAssertEqual(fetchedApps.first?.isLocked, true)
    }

    func testRemoveLockedApp() {
        let app = LockedApp(bundleIdentifier: "com.test.app", name: "Test App", path: "/Applications/TestApp.app")
        persistenceService.addLockedApp(app)

        persistenceService.removeLockedApp(app)

        let fetchedApps = persistenceService.fetchLockedApps()
        XCTAssertTrue(fetchedApps.isEmpty)
    }

    func testIsAppLocked() {
        let app = LockedApp(bundleIdentifier: "com.test.app", name: "Test App", path: "/Applications/TestApp.app")
        persistenceService.addLockedApp(app)

        XCTAssertTrue(persistenceService.isAppLocked(bundleIdentifier: "com.test.app"))
        XCTAssertFalse(persistenceService.isAppLocked(bundleIdentifier: "com.other.app"))
    }

    // MARK: - Sorting Tests

    func testFetchSortedAlphabetically() {
        let app1 = LockedApp(bundleIdentifier: "com.b.app", name: "Bravo App", path: "/path/b")
        let app2 = LockedApp(bundleIdentifier: "com.a.app", name: "Alpha App", path: "/path/a")
        let app3 = LockedApp(bundleIdentifier: "com.c.app", name: "Charlie App", path: "/path/c")

        persistenceService.addLockedApp(app1)
        persistenceService.addLockedApp(app2)
        persistenceService.addLockedApp(app3)

        let fetchedApps = persistenceService.fetchLockedApps()
        XCTAssertEqual(fetchedApps.count, 3)
        XCTAssertEqual(fetchedApps[0].name, "Alpha App")
        XCTAssertEqual(fetchedApps[1].name, "Bravo App")
        XCTAssertEqual(fetchedApps[2].name, "Charlie App")
    }

    // MARK: - Edge Cases

    func testAddDuplicateApp() {
        let app1 = LockedApp(bundleIdentifier: "com.test.app", name: "Test App", path: "/Applications/TestApp.app")
        let app2 = LockedApp(bundleIdentifier: "com.test.app", name: "Test App 2", path: "/Applications/TestApp2.app")

        persistenceService.addLockedApp(app1)
        persistenceService.addLockedApp(app2)

        // Due to @Attribute(.unique), only one should exist
        let fetchedApps = persistenceService.fetchLockedApps()
        XCTAssertEqual(fetchedApps.count, 1)
    }

    func testRemoveNonExistentApp() {
        let app = LockedApp(bundleIdentifier: "com.test.app", name: "Test App", path: "/Applications/TestApp.app")

        // Should not crash when removing an app that doesn't exist
        persistenceService.removeLockedApp(app)

        let fetchedApps = persistenceService.fetchLockedApps()
        XCTAssertTrue(fetchedApps.isEmpty)
    }

    func testFetchLockedAppsFromEmptyStore() {
        let fetchedApps = persistenceService.fetchLockedApps()
        XCTAssertTrue(fetchedApps.isEmpty)
    }

    func testIsAppLockedFromEmptyStore() {
        XCTAssertFalse(persistenceService.isAppLocked(bundleIdentifier: "com.test.app"))
    }

    // MARK: - Persistence Tests

    func testMultipleAdditionsAndRemovals() {
        let apps = [
            LockedApp(bundleIdentifier: "com.app1", name: "App 1", path: "/path/1"),
            LockedApp(bundleIdentifier: "com.app2", name: "App 2", path: "/path/2"),
            LockedApp(bundleIdentifier: "com.app3", name: "App 3", path: "/path/3")
        ]

        // Add all
        apps.forEach { persistenceService.addLockedApp($0) }
        XCTAssertEqual(persistenceService.fetchLockedApps().count, 3)

        // Remove middle one
        persistenceService.removeLockedApp(apps[1])
        XCTAssertEqual(persistenceService.fetchLockedApps().count, 2)

        // Verify correct apps remain
        let remaining = persistenceService.fetchLockedApps()
        XCTAssertTrue(remaining.contains { $0.bundleIdentifier == "com.app1" })
        XCTAssertTrue(remaining.contains { $0.bundleIdentifier == "com.app3" })
        XCTAssertFalse(remaining.contains { $0.bundleIdentifier == "com.app2" })
    }
}
