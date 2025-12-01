//
//  LockScreenWindowController.swift
//  MacAppLocker
//
//  Created by Antigravity on 2025-12-01.
//  Manages the floating window for the lock screen.
//

import AppKit
import SwiftUI

/// Controller responsible for presenting and dismissing the lock screen overlay.
@MainActor
final class LockScreenWindowController: NSObject {
    // MARK: - Properties

    private var window: NSPanel?
    private let logger: LoggerService

    // MARK: - Initialization

    init(logger: LoggerService) {
        self.logger = logger
        super.init()
    }

    // MARK: - Public API

    /// Shows the lock screen for a specific app.
    /// - Parameters:
    ///   - appName: The name of the locked app.
    ///   - onUnlock: Closure to execute when the user requests unlock.
    ///   - onQuit: Closure to execute when the user requests to quit the app.
    /// Shows the lock screen for a specific app.
    /// - Parameters:
    ///   - appName: The name of the locked app.
    ///   - onUnlock: Closure to execute when the user requests unlock.
    ///   - onQuit: Closure to execute when the user requests to quit the app.
    func show(appName: String, onUnlock: @escaping () -> Void, onQuit: @escaping () -> Void) {
        if window != nil {
            // Already showing, just bring to front
            window?.makeKeyAndOrderFront(nil)
            return
        }

        logger.info("LockScreenWindowController: Showing lock screen for \(appName)")

        // Enable Kiosk Mode
        NSApp.presentationOptions = [
            .disableProcessSwitching,
            .hideDock,
            .hideMenuBar,
            .disableForceQuit,
            .disableSessionTermination,
            .disableHideApplication
        ]

        let lockView = LockScreenView(appName: appName, onUnlock: onUnlock, onQuit: onQuit)
        let hostingController = NSHostingController(rootView: lockView)

        // Use custom LockScreenPanel
        let newWindow = LockScreenPanel(
            contentRect: NSScreen.main?.frame ?? NSRect(x: 0, y: 0, width: 800, height: 600),
            styleMask: [.nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        newWindow.contentViewController = hostingController

        // Window Level: .screenSaver ensures it covers everything
        newWindow.level = .screenSaver

        newWindow.backgroundColor = .clear
        newWindow.isOpaque = false
        newWindow.hasShadow = false
        newWindow.ignoresMouseEvents = false
        newWindow.isReleasedWhenClosed = false

        // Collection Behavior: Join all spaces (Mission Control), Full Screen Aux (covers full screen apps)
        newWindow.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .ignoresCycle]

        // Make it cover the screen
        if let screen = NSScreen.main {
            newWindow.setFrame(screen.frame, display: true)
        }

        window = newWindow

        // Force display and focus
        newWindow.makeKeyAndOrderFront(nil)
    }

    /// Hides the lock screen.
    func hide() {
        guard let window else { return }
        logger.info("LockScreenWindowController: Hiding lock screen.")

        // Disable Kiosk Mode
        NSApp.presentationOptions = []

        window.orderOut(nil)
        window.close()
        self.window = nil
    }
}

// MARK: - Custom Panel

/// Custom NSPanel that can become key to capture keyboard input.
private class LockScreenPanel: NSPanel {
    override var canBecomeKey: Bool {
        true
    }

    override var canBecomeMain: Bool {
        true
    }
}
