//
//  SettingsView.swift
//  MacAppLocker
//
//  Created by Antigravity on 2025-12-01.
//  Settings window for Mac App Locker.
//

import SwiftUI

struct SettingsView: View {
    // MARK: - State

    @AppStorage("launchAtLogin") private var launchAtLogin = false
    @AppStorage("showMenuBarIcon") private var showMenuBarIcon = true
    @AppStorage("showDockIcon") private var showDockIcon = true
    @AppStorage("requireAuthToUnlock") private var requireAuthToUnlock = true
    @AppStorage("requireAuthToQuit") private var requireAuthToQuit = false
    @AppStorage("hideFromMissionControl") private var hideFromMissionControl = true

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
                Toggle("Launch at Login", isOn: $launchAtLogin)
                    .help("Automatically start Mac App Locker when you log in")

                Toggle("Show Menu Bar Icon", isOn: $showMenuBarIcon)
                    .help("Display lock icon in the menu bar")

                Toggle("Show Dock Icon", isOn: $showDockIcon)
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
                Toggle("Require Authentication to Unlock", isOn: $requireAuthToUnlock)
                    .help("Use Touch ID or Password to unlock apps")

                Toggle("Require Authentication to Quit Locked Apps", isOn: $requireAuthToQuit)
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
                Toggle("Hide Apps from Mission Control", isOn: $hideFromMissionControl)
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
