//
//  AboutView.swift
//  MacAppLocker
//
//  Created by Antigravity on 2025-12-01.
//  About window for Mac App Locker.
//

import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            // App Icon (placeholder - will be replaced with actual icon)
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 80))
                .foregroundStyle(.blue.gradient)
                .padding(.top, 30)

            // App Name and Version
            VStack(spacing: 8) {
                Text("Mac App Locker")
                    .font(.title)
                    .fontWeight(.semibold)

                Text("Version 1.0.0")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Divider()
                .padding(.horizontal, 40)

            // Description
            VStack(spacing: 12) {
                Text("A secure application locker for macOS")
                    .font(.body)
                    .multilineTextAlignment(.center)

                Text("Protect your applications with biometric authentication")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 40)

            Divider()
                .padding(.horizontal, 40)

            // Credits
            VStack(spacing: 4) {
                Text("© 2025 Yoan Gilliand")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Button("View on GitHub") {
                    if let url = URL(string: "https://github.com/yoan-gilliand/mac-app-locker") {
                        NSWorkspace.shared.open(url)
                    }
                }
                .buttonStyle(.link)
                .font(.caption)
            }

            Spacer()

            // Close Button
            HStack {
                Spacer()
                Button("Close") {
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                Spacer()
            }
            .padding(.bottom, 20)
        }
        .frame(width: 400, height: 450)
    }
}

#if DEBUG
    #Preview {
        AboutView()
    }
#endif
