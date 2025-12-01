//
// ******************************************************************************
// @file        AuthenticationService.swift
// @brief       File: AuthenticationService.swift
// @author      Yoan Gilliand
// @editor      Yoan Gilliand
// @date        01 Dec 2025
// ******************************************************************************
// @copyright   Copyright (c) 2025 Yoan Gilliand. All rights reserved.
// ******************************************************************************
// @details
// Service for handling user authentication via Touch ID or password.
// ******************************************************************************
//
import Combine
import Foundation
import LocalAuthentication

final class AuthenticationService: ObservableObject {
    // MARK: - Properties

    private let logger: LoggerService

    // MARK: - Initialization

    init(logger: LoggerService) {
        self.logger = logger
    }

    // MARK: - Public API

    func authenticate() async -> Bool {
        logger.info("AuthenticationService: Requesting authentication...")

        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "Unlock application"

            do {
                let success = try await context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason)
                if success {
                    logger.info("AuthenticationService: Authentication successful.")
                    return true
                } else {
                    logger.warning("AuthenticationService: Authentication failed.")
                    return false
                }
            } catch {
                logger.error("AuthenticationService: Evaluation error", error: error)
                return false
            }
        } else {
            logger.error("AuthenticationService: Biometrics not available", error: error)
            return false
        }
    }
}
