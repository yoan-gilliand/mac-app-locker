@testable import MacAppLocker
import XCTest

@MainActor
final class DashboardViewModelTests: XCTestCase {
    var viewModel: DashboardViewModel!
    var persistenceService: PersistenceService!
    var appMonitorService: AppMonitorService!
    var authenticationService: AuthenticationService!
    var logger: LoggerService!

    override func setUp() {
        super.setUp()
        logger = LoggerService(subsystem: "com.macapplocker.tests", category: "ViewModel")

        // Use in-memory persistence
        persistenceService = PersistenceService(logger: logger, inMemory: true)
        authenticationService = AuthenticationService(logger: logger)

        appMonitorService = AppMonitorService(
            logger: logger,
            persistenceService: persistenceService,
            authenticationService: authenticationService
        )

        viewModel = DashboardViewModel(appMonitor: appMonitorService, persistence: persistenceService)
    }

    override func tearDown() {
        viewModel = nil
        persistenceService = nil
        logger = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitialStateHasMonitoringEnabled() {
        // Monitoring should be enabled by default
        XCTAssertTrue(viewModel.isMonitoring)
    }

    func testInitialStateHasNoApps() {
        XCTAssertTrue(viewModel.lockedApps.isEmpty)
    }

    // MARK: - App Management Tests

    func testRemoveApp() {
        // Add an app directly to persistence
        let app = LockedApp(
            bundleIdentifier: "com.test.app",
            name: "Test App",
            path: "/Applications/Test.app"
        )
        persistenceService.addLockedApp(app)

        // Refresh view model
        viewModel.fetchLockedApps()
        XCTAssertEqual(viewModel.lockedApps.count, 1)

        // Remove the app
        guard let appToRemove = viewModel.lockedApps.first else {
            XCTFail("App should be present")
            return
        }
        viewModel.removeApp(appToRemove)

        XCTAssertTrue(viewModel.lockedApps.isEmpty)
    }

    func testFetchLockedAppsRefreshesData() {
        // Add apps directly to persistence
        let app1 = LockedApp(bundleIdentifier: "com.app1", name: "App 1", path: "/path/1")
        let app2 = LockedApp(bundleIdentifier: "com.app2", name: "App 2", path: "/path/2")

        persistenceService.addLockedApp(app1)
        persistenceService.addLockedApp(app2)

        // Initially empty
        XCTAssertTrue(viewModel.lockedApps.isEmpty)

        // Fetch updates the view model
        viewModel.fetchLockedApps()
        XCTAssertEqual(viewModel.lockedApps.count, 2)
    }

    // MARK: - Monitoring Tests

    func testToggleMonitoringOffThenOn() {
        // Initial state (Monitoring is ON by default)
        XCTAssertTrue(viewModel.isMonitoring)

        // Toggle OFF
        viewModel.toggleMonitoring()
        XCTAssertFalse(viewModel.isMonitoring)

        // Toggle ON
        viewModel.toggleMonitoring()
        XCTAssertTrue(viewModel.isMonitoring)
    }

    // MARK: - Data Synchronization Tests

    func testViewModelSyncsWithPersistence() {
        let app = LockedApp(bundleIdentifier: "com.sync.test", name: "Sync Test", path: "/path")

        // Add through persistence
        persistenceService.addLockedApp(app)

        // Fetch in view model
        viewModel.fetchLockedApps()

        // Verify sync
        XCTAssertEqual(viewModel.lockedApps.count, 1)
        XCTAssertEqual(viewModel.lockedApps.first?.bundleIdentifier, "com.sync.test")
    }
}
