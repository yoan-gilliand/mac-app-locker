//
// ******************************************************************************
// @file        SettingsView.swift
// @brief       File: SettingsView.swift
// @author      Yoan Gilliand
// @editor      Yoan Gilliand
// @date        01 Dec 2025
// ******************************************************************************
// @copyright   Copyright (c) 2025 Yoan Gilliand. All rights reserved.
// ******************************************************************************
// @details
// View for managing application settings.
// ******************************************************************************
//
import SwiftUI

struct SettingsView: View {
    // MARK: - Properties

    @StateObject private var settingsService = DIContainer.shared.settingsService
    @Environment(\.dismiss) private var dismiss

    // MARK: - Body

    var body: some View {
        TabView {
            generalTab
                .tabItem {
                    Label("General", systemImage: "gear")
                }

            securityTab
                .tabItem {
                    Label("Security", systemImage: "lock.shield")
                }

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
