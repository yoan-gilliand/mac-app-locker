//
//  DIContainer.swift
//  MacAppLocker
//
//  Created by Antigravity on 2025-12-01.
//  Singleton container managing all application dependencies.
//

import Combine
import Foundation
import SwiftData
import SwiftUI

/// A container responsible for managing and injecting dependencies throughout the app.
/// This follows a Service Locator pattern simplified for SwiftUI environment usage.
@MainActor
final class DIContainer: ObservableObject {
    /// Shared singleton instance.
    static let shared = DIContainer()

    // MARK: - Services

    let logger: LoggerService
    let appMonitorService: AppMonitorService
    let authenticationService: AuthenticationService
    let persistenceService: PersistenceService
    let settingsService: SettingsService

    // MARK: - Initialization

    init() {
        logger = LoggerService()
        settingsService = SettingsService()
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
        DashboardViewModel(
            appMonitor: appMonitorService,
            persistence: persistenceService
        )
    }
}
