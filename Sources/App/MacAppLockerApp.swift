//
//  MacAppLockerApp.swift
//  MacAppLocker
//
//  Created by Antigravity on 2025-12-01.
//  Entry point for the Mac App Locker application.
//

import SwiftUI
import SwiftData

@main
struct MacAppLockerApp: App {
    // MARK: - Properties
    
    /// The centralized container for all dependencies.
    @StateObject private var container = DIContainer()
    
    // MARK: - Body
    
    var body: some Scene {
        WindowGroup {
            DashboardView(viewModel: container.makeDashboardViewModel())
                .environmentObject(container)
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            SidebarCommands()
        }
        
        // Auxiliary windows or menu bar items can be defined here
    }
}
