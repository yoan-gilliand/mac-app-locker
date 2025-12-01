//
// ******************************************************************************
// @file        PersistenceService.swift
// @brief       File: PersistenceService.swift
// @author      Yoan Gilliand
// @editor      Yoan Gilliand
// @date        01 Dec 2025
// ******************************************************************************
// @copyright   Copyright (c) 2025 Yoan Gilliand. All rights reserved.
// ******************************************************************************
// @details
// Service for persisting locked application data using SwiftData.
// ******************************************************************************
//
import Combine
import Foundation
import SwiftData

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

    @MainActor
    func addLockedApp(_ app: LockedApp) {
        if isAppLocked(bundleIdentifier: app.bundleIdentifier) {
            logger.warning("PersistenceService: App with bundle ID \(app.bundleIdentifier) already exists, skipping add.")
            return
        }

        modelContext.insert(app)
        save()
        logger.info("PersistenceService: Added app \(app.name) (\(app.bundleIdentifier))")
    }

    @MainActor
    func removeLockedApp(_ app: LockedApp) {
        let name = app.name
        modelContext.delete(app)
        save()
        logger.info("PersistenceService: Removed app \(name)")
    }

    @MainActor
    func updateLockedApp(_ app: LockedApp) {
        save()
        logger.info("PersistenceService: Updated app \(app.name) (Locked: \(app.isLocked))")
    }

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

    @MainActor
    func isAppLocked(bundleIdentifier: String) -> Bool {
        let descriptor = FetchDescriptor<LockedApp>(
            predicate: #Predicate<LockedApp> { $0.bundleIdentifier == bundleIdentifier && $0.isLocked }
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
