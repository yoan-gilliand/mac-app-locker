//
// ******************************************************************************
// @file        LoggerService.swift
// @brief       File: LoggerService.swift
// @author      Yoan Gilliand
// @editor      Yoan Gilliand
// @date        01 Dec 2025
// ******************************************************************************
// @copyright   Copyright (c) 2025 Yoan Gilliand. All rights reserved.
// ******************************************************************************
// @details
// Service for logging application events and errors.
// ******************************************************************************
//
import Foundation
import OSLog

final class LoggerService {
    // MARK: - Properties

    private let logger: Logger

    // MARK: - Initialization

    init(subsystem: String = "com.macapplocker", category: String = "General") {
        logger = Logger(subsystem: subsystem, category: category)
    }

    // MARK: - Public API

    func debug(_ message: String) {
        logger.debug("🔎 \(message, privacy: .public)")
    }

    func info(_ message: String) {
        logger.info("ℹ️ \(message, privacy: .public)")
    }

    func warning(_ message: String) {
        logger.warning("⚠️ \(message, privacy: .public)")
    }

    func error(_ message: String, error: Error? = nil) {
        if let error {
            logger.error("🔥 \(message, privacy: .public) | Error: \(error.localizedDescription, privacy: .public)")
        } else {
            logger.error("🔥 \(message, privacy: .public)")
        }
    }
}
