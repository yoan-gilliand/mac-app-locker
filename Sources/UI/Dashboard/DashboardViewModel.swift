//
//  DashboardViewModel.swift
//  MacAppLocker
//
//  Created by Antigravity on 2025-12-01.
//  ViewModel for the main Dashboard view.
//

import Foundation
import Combine

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
    
    func addApp(url: URL) {
        guard let bundle = Bundle(url: url),
              let bundleIdentifier = bundle.bundleIdentifier,
              let info = bundle.infoDictionary,
              let name = info["CFBundleName"] as? String ?? info["CFBundleDisplayName"] as? String else {
            // Handle error: Not a valid app bundle
            return
        }
        
        // Check if already exists
        if lockedApps.contains(where: { $0.bundleIdentifier == bundleIdentifier }) {
            return
        }
        
        let newApp = LockedApp(
            bundleIdentifier: bundleIdentifier,
            name: name,
            path: url.path
        )
        
        persistence.addLockedApp(newApp)
        fetchLockedApps()
    }
    
    func removeApp(_ app: LockedApp) {
        persistence.removeLockedApp(app)
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
