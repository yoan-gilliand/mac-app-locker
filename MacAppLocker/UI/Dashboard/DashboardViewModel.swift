//
//  DashboardViewModel.swift
//  MacAppLocker
//
//  Created by Antigravity on 2025-12-01.
//  ViewModel for the main Dashboard view.
//

import Combine
import Foundation

/// ViewModel managing the state of the Dashboard.
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

        // Load initial data
        fetchLockedApps()

        // Start monitoring by default (or based on settings)
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
