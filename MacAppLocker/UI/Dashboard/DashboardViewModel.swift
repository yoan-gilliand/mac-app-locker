//
// ******************************************************************************
// @file        DashboardViewModel.swift
// @brief       File: DashboardViewModel.swift
// @author      Yoan Gilliand
// @editor      Yoan Gilliand
// @date        01 Dec 2025
// ******************************************************************************
// @copyright   Copyright (c) 2025 Yoan Gilliand. All rights reserved.
// ******************************************************************************
// @details
// ViewModel for the DashboardView, handling business logic.
// ******************************************************************************
//
import Combine
import Foundation

@MainActor
final class DashboardViewModel: ObservableObject {
    // MARK: - Properties

    private let appMonitor: AppMonitorService
    private let persistence: PersistenceService

    @Published var lockedApps: [LockedApp] = []
    @Published var isMonitoring: Bool = false

    // MARK: - Initialization

    init(appMonitor: AppMonitorService, persistence: PersistenceService) {
        self.appMonitor = appMonitor
        self.persistence = persistence

        fetchLockedApps()

        startMonitoring()
    }

    // MARK: - Public API

    func fetchLockedApps() {
        lockedApps = persistence.fetchLockedApps()
    }

    func addApp(_ app: LockedApp) {
        persistence.addLockedApp(app)
        fetchLockedApps()
    }

    func removeApp(_ app: LockedApp) {
        persistence.removeLockedApp(app)
        fetchLockedApps()
    }

    func toggleLock(for app: LockedApp) {
        app.isLocked.toggle()
        persistence.updateLockedApp(app)
        fetchLockedApps()
    }

    func toggleMonitoring() {
        isMonitoring.toggle()
        if isMonitoring {
            appMonitor.startMonitoring()
        } else {
            appMonitor.stopMonitoring()
        }
    }

    private func startMonitoring() {
        isMonitoring = true
        appMonitor.startMonitoring()
    }
}
