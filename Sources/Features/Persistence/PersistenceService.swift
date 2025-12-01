//
//  PersistenceService.swift
//  MacAppLocker
//
//  Created by Antigravity on 2025-12-01.
//  Service responsible for persisting application data using SwiftData.
//

import Foundation
import SwiftData

/// Service that manages data persistence.
final class PersistenceService: ObservableObject {
    // MARK: - Properties

    private let logger: LoggerService
    let modelContainer: ModelContainer

    @MainActor
    var modelContext: ModelContext {
        modelContainer.mainContext
    }

    // MARK: - Initialization

    init(logger: LoggerService, inMemory: Bool = false) {
        self.logger = logger

        do {
            let schema = Schema([LockedApp.self])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            logger.info("PersistenceService: ModelContainer initialized successfully (inMemory: \(inMemory)).")
        } catch {
            logger.error("PersistenceService: Failed to initialize ModelContainer", error: error)
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }

    // MARK: - Public API

    /// Adds a new app to the locked list.
    @MainActor
    func addLockedApp(_ app: LockedApp) {
        // Check if app with same bundleIdentifier already exists
        if isAppLocked(bundleIdentifier: app.bundleIdentifier) {
            logger.warning("PersistenceService: App with bundle ID \(app.bundleIdentifier) already exists, skipping add.")
            return
        }

        modelContext.insert(app)
        save()
        logger.info("PersistenceService: Added app \(app.name) (\(app.bundleIdentifier))")
    }

    /// Removes an app from the locked list.
    @MainActor
    func removeLockedApp(_ app: LockedApp) {
        let name = app.name
        modelContext.delete(app)
        save()
        logger.info("PersistenceService: Removed app \(name)")
    }

    /// Fetches all locked apps.
    @MainActor
    func fetchLockedApps() -> [LockedApp] {
        let descriptor = FetchDescriptor<LockedApp>(sortBy: [SortDescriptor(\.name)])
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            logger.error("PersistenceService: Failed to fetch locked apps", error: error)
            return []
        }
    }

    /// Checks if an app is locked by its bundle identifier.
    @MainActor
    func isAppLocked(bundleIdentifier: String) -> Bool {
        // Note: This is a synchronous fetch on the main thread. For high frequency checks, caching might be needed.
        let descriptor = FetchDescriptor<LockedApp>(
            predicate: #Predicate<LockedApp> { $0.bundleIdentifier == bundleIdentifier }
        )
        do {
            let count = try modelContext.fetchCount(descriptor)
            return count > 0
        } catch {
            logger.error("PersistenceService: Failed to check lock status", error: error)
            return false
        }
    }

    // MARK: - Private Helpers

    @MainActor
    private func save() {
        do {
            try modelContext.save()
        } catch {
            logger.error("PersistenceService: Failed to save context", error: error)
        }
    }
}
