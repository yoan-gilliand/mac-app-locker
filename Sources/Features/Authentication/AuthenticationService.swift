//
//  AuthenticationService.swift
//  MacAppLocker
//
//  Created by Antigravity on 2025-12-01.
//  Service responsible for handling user authentication via LocalAuthentication (TouchID/FaceID/Password).
//

import Foundation
import LocalAuthentication

/// Service that handles biometric and password authentication.
final class AuthenticationService: ObservableObject {
    
    // MARK: - Properties
    
    private let logger: LoggerService
    
    // MARK: - Initialization
    
    init(logger: LoggerService) {
        self.logger = logger
    }
    
    // MARK: - Public API
    
    /// Attempts to authenticate the user.
    /// - Returns: `true` if authentication is successful, `false` otherwise.
    func authenticate() async -> Bool {
        logger.info("AuthenticationService: Requesting authentication...")
        
        let context = LAContext()
        var error: NSError?
        
        // Check if biometric authentication is available
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
            // Fallback to password or other method if needed
            return false
        }
    }
}
