//
//  LockScreenView.swift
//  MacAppLocker
//
//  Created by Antigravity on 2025-12-01.
//  The visual interface for the lock screen overlay.
//

import SwiftUI

struct LockScreenView: View {
    // MARK: - Properties

    let appName: String
    let onUnlock: () -> Void
    let onQuit: () -> Void

    // MARK: - Body

    var body: some View {
        ZStack {
            // Background Blur
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()

            VStack(spacing: 30) {
                Image(systemName: "lock.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .foregroundStyle(.white)
                    .shadow(radius: 10)

                VStack(spacing: 10) {
                    Text("\(appName) is Locked")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(.white)

                    Text("Authenticate to access this application.")
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.8))
                }

                HStack(spacing: 24) {
                    Button(action: onQuit) {
                        Text("Quit App")
                            .font(.headline)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(.plain)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(.white.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                    .keyboardShortcut("q", modifiers: .command) // Cmd + Q

                    Button(action: onUnlock) {
                        HStack {
                            Image(systemName: "faceid")
                            Text("Unlock")
                        }
                        .font(.headline)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                    }
                    .buttonStyle(.plain)
                    .background(
                        LinearGradient(
                            colors: [.blue, .cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Capsule())
                    .shadow(color: .blue.opacity(0.4), radius: 8, x: 0, y: 4)
                }
                .padding(.top, 10)
            }
            .padding()

            // Footer Keybind Hint
            VStack {
                Spacer()
                Text("Press 'Cmd + Q' to Quit")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
                    .padding(.bottom, 30)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            ZStack {
                Color.black.opacity(0.6)
                // Add a subtle gradient overlay for richness
                LinearGradient(
                    colors: [.black.opacity(0.4), .blue.opacity(0.1)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        )
    }
}

// #Preview {
//     LockScreenView(appName: "Safari", onUnlock: {}, onQuit: {})
// }
