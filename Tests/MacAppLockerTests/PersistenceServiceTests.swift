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
        // Use in-memory storage for tests
        persistenceService = PersistenceService(logger: logger, inMemory: true)
    }

    override func tearDown() {
        persistenceService = nil
        logger = nil
        super.tearDown()
    }

    func testAddLockedApp() {
        let app = LockedApp(bundleIdentifier: "com.test.app", name: "Test App", path: "/Applications/TestApp.app")

        persistenceService.addLockedApp(app)

        let fetchedApps = persistenceService.fetchLockedApps()
        XCTAssertEqual(fetchedApps.count, 1)
        XCTAssertEqual(fetchedApps.first?.bundleIdentifier, "com.test.app")
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

    func testFetchSorted() {
        let app1 = LockedApp(bundleIdentifier: "com.a.app", name: "A App", path: "/path/a")
        let app2 = LockedApp(bundleIdentifier: "com.b.app", name: "B App", path: "/path/b")

        persistenceService.addLockedApp(app2)
        persistenceService.addLockedApp(app1)

        let fetchedApps = persistenceService.fetchLockedApps()
        XCTAssertEqual(fetchedApps.count, 2)
        XCTAssertEqual(fetchedApps[0].name, "A App")
        XCTAssertEqual(fetchedApps[1].name, "B App")
    }
}
