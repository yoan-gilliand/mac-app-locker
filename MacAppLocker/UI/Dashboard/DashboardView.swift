//
//  DashboardView.swift
//  MacAppLocker
//
//  Created by Antigravity on 2025-12-01.
//  Main view displaying the list of locked applications.
//

import SwiftUI

struct DashboardView: View {
    // MARK: - Properties

    @StateObject var viewModel: DashboardViewModel
    @State private var selectedAppID: String?
    @State private var isImporting = false

    // MARK: - Body

    var body: some View {
        NavigationSplitView {
            VStack(spacing: 0) {
                // Header with title and add button
                HStack {
                    Text("Locked Applications")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Spacer()

                    Button {
                        isImporting = true
                    } label: {
                        Label("Add App", systemImage: "plus")
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()

                Divider()

                // Apps List
                List(viewModel.lockedApps, id: \.bundleIdentifier, selection: $selectedAppID) { app in
                    HStack {
                        Image(nsImage: NSWorkspace.shared.icon(forFile: app.path))
                            .resizable()
                            .frame(width: 32, height: 32)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(app.name)
                                .font(.headline)

                            Text(app.bundleIdentifier)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        if app.isLocked {
                            Image(systemName: "lock.fill")
                                .foregroundColor(.blue)
                                .help("Locked")
                        }
                    }
                    .tag(app.bundleIdentifier)
                    .contextMenu {
                        Button("Unlock") {
                            // TODO: Unlock app
                        }

                        Divider()

                        Button("Remove", role: .destructive) {
                            viewModel.removeApp(app)
                        }
                    }
                }
            }
            .frame(minWidth: 300)
            .toolbar {
                ToolbarItem(placement: .status) {
                    Text("\(viewModel.lockedApps.count) apps")
                        .foregroundStyle(.secondary)
                }
            }
            .fileImporter(
                isPresented: $isImporting,
                allowedContentTypes: [.application],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case let .success(urls):
                    guard let url = urls.first else { return }
                    let appName = url.deletingPathExtension().lastPathComponent
                    let bundleID = Bundle(url: url)?.bundleIdentifier ?? "unknown.app"
                    let newApp = LockedApp(bundleIdentifier: bundleID, name: appName, path: url.path)
                    viewModel.addApp(newApp)
                case let .failure(error):
                    print("Importer failed: \(error.localizedDescription)")
                }
            }
        } detail: {
            if let selectedID = selectedAppID,
               let app = viewModel.lockedApps.first(where: { $0.bundleIdentifier == selectedID }) {
                VStack(spacing: 20) {
                    Image(nsImage: NSWorkspace.shared.icon(forFile: app.path))
                        .resizable()
                        .frame(width: 128, height: 128)

                    Text(app.name)
                        .font(.title)

                    Text("Bundle ID: \(app.bundleIdentifier)")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Toggle("Locked", isOn: .constant(app.isLocked))
                        .toggleStyle(.switch)
                        .disabled(true)

                    Spacer()
                }
                .padding()
            } else {
                ContentUnavailableView(
                    "Select an Application",
                    systemImage: "app.dashed",
                    description: Text("Choose an app from the list to view its details")
                )
            }
        }
        .onAppear {
            viewModel.fetchLockedApps()

            // Listen for refresh notifications
            NotificationCenter.default.addObserver(
                forName: NSNotification.Name("RefreshDashboard"),
                object: nil,
                queue: .main
            ) { _ in
                viewModel.fetchLockedApps()
            }
        }
    }
}
