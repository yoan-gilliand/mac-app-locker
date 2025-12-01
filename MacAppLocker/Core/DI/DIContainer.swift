//
//  DIContainer.swift
//  MacAppLocker
//
//  Created by Antigravity on 2025-12-01.
//  Central Dependency Injection Container for the application.
//

import Foundation
import SwiftUI

/// A container responsible for managing and injecting dependencies throughout the app.
/// This follows a Service Locator pattern simplified for SwiftUI environment usage.
@MainActor
final class DIContainer: ObservableObject {
    // MARK: - Services

    let logger: LoggerService
    let appMonitorService: AppMonitorService
    let authenticationService: AuthenticationService
    let persistenceService: PersistenceService

    // MARK: - Initialization

    init() {
        logger = LoggerService()
        persistenceService = PersistenceService(logger: logger)
        authenticationService = AuthenticationService(logger: logger)
        appMonitorService = AppMonitorService(
            logger: logger,
            persistenceService: persistenceService,
            authenticationService: authenticationService
        )

        // Initialize services
        setupServices()
    }

    private func setupServices() {
        logger.info("DIContainer: Initializing services...")
        // Additional setup if needed
    }

    // MARK: - Factory Methods

    /// Creates a ViewModel for the Dashboard.
    func makeDashboardViewModel() -> DashboardViewModel {
        return DashboardViewModel(
            appMonitor: appMonitorService,
            persistence: persistenceService
        )
    }
}
