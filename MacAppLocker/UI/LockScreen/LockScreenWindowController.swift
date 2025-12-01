//
// ******************************************************************************
// @file        LockScreenWindowController.swift
// @brief       File: LockScreenWindowController.swift
// @author      Yoan Gilliand
// @editor      Yoan Gilliand
// @date        01 Dec 2025
// ******************************************************************************
// @copyright   Copyright (c) 2025 Yoan Gilliand. All rights reserved.
// ******************************************************************************
// @details
// Controller for managing the lock screen window.
// ******************************************************************************
//
import AppKit
import SwiftUI

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

    func show(appName: String, onUnlock: @escaping () -> Void, onQuit: @escaping () -> Void) {
        if window != nil {
            window?.makeKeyAndOrderFront(nil)
            return
        }

        logger.info("LockScreenWindowController: Showing lock screen for \(appName)")

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

        let newWindow = LockScreenPanel(
            contentRect: NSScreen.main?.frame ?? NSRect(x: 0, y: 0, width: 800, height: 600),
            styleMask: [.nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        newWindow.contentViewController = hostingController

        newWindow.level = .screenSaver

        newWindow.backgroundColor = .clear
        newWindow.isOpaque = false
        newWindow.hasShadow = false
        newWindow.ignoresMouseEvents = false
        newWindow.isReleasedWhenClosed = false

        newWindow.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .ignoresCycle]

        if let screen = NSScreen.main {
            newWindow.setFrame(screen.frame, display: true)
        }

        window = newWindow

        newWindow.makeKeyAndOrderFront(nil)
    }

    func hide() {
        guard let window else { return }
        logger.info("LockScreenWindowController: Hiding lock screen.")

        NSApp.presentationOptions = []

        window.orderOut(nil)
        window.close()
        self.window = nil
    }
}

// MARK: - Custom Panel

private class LockScreenPanel: NSPanel {
    override var canBecomeKey: Bool {
        true
    }

    override var canBecomeMain: Bool {
        true
    }
}
