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
    @State private var isImporterPresented: Bool = false
    @State private var selectedAppID: String?

    // MARK: - Body

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedAppID) {
                Section(header: Text("Locked Apps")) {
                    ForEach(viewModel.lockedApps, id: \.bundleIdentifier) { app in
                        HStack {
                            Image(nsImage: NSWorkspace.shared.icon(forFile: app.path))
                                .resizable()
                                .frame(width: 32, height: 32)

                            VStack(alignment: .leading) {
                                Text(app.name)
                                    .font(.headline)
                                Text(app.bundleIdentifier)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            if app.isLocked {
                                Image(systemName: "lock.fill")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .tag(app.bundleIdentifier) // Use bundleIdentifier as tag
                        .contextMenu {
                            Button(role: .destructive) {
                                viewModel.removeApp(app)
                            } label: {
                                Label("Remove", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .navigationSplitViewColumnWidth(min: 250, ideal: 300, max: 400)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { isImporterPresented = true }) {
                        Label("Add App", systemImage: "plus")
                    }
                }
            }
            .fileImporter(
                isPresented: $isImporterPresented,
                allowedContentTypes: [.application],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case let .success(urls):
                    if let url = urls.first {
                        viewModel.addApp(url: url)
                    }
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
                        .font(.largeTitle)

                    Toggle("Monitoring Active", isOn: $viewModel.isMonitoring)
                        .toggleStyle(.switch)
                        .onChange(of: viewModel.isMonitoring) { _, _ in
                            viewModel.toggleMonitoring()
                        }

                    Spacer()
                }
                .padding()
            } else {
                Text("Select an app or add one to get started")
                    .foregroundStyle(.secondary)
            }
        }
    }
}
