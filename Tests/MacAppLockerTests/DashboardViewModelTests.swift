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

        // Initialize real AppMonitorService (it's safe as it just listens to notifications)
        appMonitorService = AppMonitorService(
            logger: logger,
            persistenceService: persistenceService,
            authenticationService: authenticationService
        )

        viewModel = DashboardViewModel(appMonitor: appMonitorService, persistence: persistenceService)
    }

    override func tearDown() {
        viewModel = nil
        appMonitorService = nil
        authenticationService = nil
        persistenceService = nil
        logger = nil
        super.tearDown()
    }

    func testInitialState() {
        XCTAssertTrue(viewModel.lockedApps.isEmpty)
        XCTAssertFalse(viewModel.isMonitoring)
    }

    func testAddApp() {
        // Create a dummy URL for an app
        let url = URL(fileURLWithPath: "/Applications/Safari.app")

        viewModel.addApp(at: url)

        XCTAssertEqual(viewModel.lockedApps.count, 1)
        let addedApp = viewModel.lockedApps.first
        XCTAssertEqual(addedApp?.name, "Safari")
        XCTAssertEqual(addedApp?.path, "/Applications/Safari.app")
        // Bundle ID might be empty if the file doesn't actually exist or isn't a bundle in the test env,
        // but our logic might try to read it.
        // In a real unit test we might need to mock the Bundle(url:) call or use a real system app path that exists.
    }

    func testRemoveApp() {
        let url = URL(fileURLWithPath: "/Applications/Safari.app")
        viewModel.addApp(at: url)

        guard let app = viewModel.lockedApps.first else {
            XCTFail("App should have been added")
            return
        }

        viewModel.removeApp(app)
        XCTAssertTrue(viewModel.lockedApps.isEmpty)
    }

    func testToggleMonitoring() {
        // Initial state
        XCTAssertFalse(viewModel.isMonitoring)

        // Toggle ON
        viewModel.toggleMonitoring()
        XCTAssertTrue(viewModel.isMonitoring)

        // Toggle OFF
        viewModel.toggleMonitoring()
        XCTAssertFalse(viewModel.isMonitoring)
    }
}
