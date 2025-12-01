//
// ******************************************************************************
// @file        DIContainer.swift
// @brief       File: DIContainer.swift
// @author      Yoan Gilliand
// @editor      Yoan Gilliand
// @date        01 Dec 2025
// ******************************************************************************
// @copyright   Copyright (c) 2025 Yoan Gilliand. All rights reserved.
// ******************************************************************************
// @details
// Dependency Injection container for managing app services.
// ******************************************************************************
//
import Combine
import Foundation
import SwiftData
import SwiftUI

@MainActor
final class DIContainer: ObservableObject {
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

        setupServices()
    }

    private func setupServices() {
        logger.info("DIContainer: Initializing services...")
    }

    // MARK: - Factory Methods

    func makeDashboardViewModel() -> DashboardViewModel {
        DashboardViewModel(
            appMonitor: appMonitorService,
            persistence: persistenceService
        )
    }
}
