//
//  SettingsView.swift
//  MacAppLocker
//
//  Created by Antigravity on 2025-12-01.
//  Settings window for Mac App Locker.
//

import SwiftUI

struct SettingsView: View {
    // MARK: - Properties

    @StateObject private var settingsService = DIContainer.shared.settingsService
    @Environment(\.dismiss) private var dismiss

    // MARK: - Body

    var body: some View {
        TabView {
            // General Tab
            generalTab
                .tabItem {
                    Label("General", systemImage: "gear")
                }

            // Security Tab
            securityTab
                .tabItem {
                    Label("Security", systemImage: "lock.shield")
                }

            // Advanced Tab
            advancedTab
                .tabItem {
                    Label("Advanced", systemImage: "slider.horizontal.3")
                }
        }
        .frame(width: 500, height: 400)
        .padding()
    }

    // MARK: - Tabs

    private var generalTab: some View {
        Form {
            Section {
                Toggle("Launch at Login", isOn: $settingsService.launchAtLogin)
                    .help("Automatically start Mac App Locker when you log in")

                Toggle("Show Menu Bar Icon", isOn: $settingsService.showMenuBarIcon)
                    .help("Display lock icon in the menu bar")

                Toggle("Show Dock Icon", isOn: $settingsService.showDockIcon)
                    .help("Show app icon in the Dock")
            } header: {
                Text("Appearance")
                    .font(.headline)
            }

            Spacer()
        }
        .formStyle(.grouped)
    }

    private var securityTab: some View {
        Form {
            Section {
                // These are not yet in SettingsService, using AppStorage for now or need to add them
                Toggle("Require Authentication to Unlock", isOn: Binding(
                    get: { UserDefaults.standard.bool(forKey: "requireAuthToUnlock") },
                    set: { UserDefaults.standard.set($0, forKey: "requireAuthToUnlock") }
                ))
                .help("Use Touch ID or Password to unlock apps")

                Toggle("Require Authentication to Quit Locked Apps", isOn: Binding(
                    get: { UserDefaults.standard.bool(forKey: "requireAuthToQuit") },
                    set: { UserDefaults.standard.set($0, forKey: "requireAuthToQuit") }
                ))
                .help("Prevent quitting locked apps without authentication")
            } header: {
                Text("Authentication")
                    .font(.headline)
            }

            Section {
                Text("Biometric authentication (Touch ID/Face ID) is enabled if available.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .formStyle(.grouped)
    }

    private var advancedTab: some View {
        Form {
            Section {
                Toggle("Hide Apps from Mission Control", isOn: Binding(
                    get: { UserDefaults.standard.bool(forKey: "hideFromMissionControl") },
                    set: { UserDefaults.standard.set($0, forKey: "hideFromMissionControl") }
                ))
                .help("Locked apps won't appear in Mission Control")
            } header: {
                Text("Privacy")
                    .font(.headline)
            }

            Section {
                Text("More advanced features coming soon...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .formStyle(.grouped)
    }
}

#if DEBUG
    #Preview {
        SettingsView()
    }
#endif
