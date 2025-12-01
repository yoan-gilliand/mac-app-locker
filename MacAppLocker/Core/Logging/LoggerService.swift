//
//  LoggerService.swift
//  MacAppLocker
//
//  Created by Antigravity on 2025-12-01.
//  Centralized logging service wrapping OSLog.
//

import Foundation
import OSLog

/// A service dedicated to logging application events, errors, and debug information.
final class LoggerService {
    // MARK: - Properties

    private let logger: Logger

    // MARK: - Initialization

    init(subsystem: String = "com.macapplocker", category: String = "General") {
        logger = Logger(subsystem: subsystem, category: category)
    }

    // MARK: - Public API

    /// Logs a debug message.
    /// - Parameter message: The message to log.
    func debug(_ message: String) {
        logger.debug("🔎 \(message, privacy: .public)")
    }

    /// Logs an informational message.
    /// - Parameter message: The message to log.
    func info(_ message: String) {
        logger.info("ℹ️ \(message, privacy: .public)")
    }

    /// Logs a warning message.
    /// - Parameter message: The message to log.
    func warning(_ message: String) {
        logger.warning("⚠️ \(message, privacy: .public)")
    }

    /// Logs an error message.
    /// - Parameter message: The message to log.
    /// - Parameter error: An optional error object to log details from.
    func error(_ message: String, error: Error? = nil) {
        if let error = error {
            logger.error("🔥 \(message, privacy: .public) | Error: \(error.localizedDescription, privacy: .public)")
        } else {
            logger.error("🔥 \(message, privacy: .public)")
        }
    }
}
