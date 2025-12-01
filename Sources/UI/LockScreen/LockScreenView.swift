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

                HStack(spacing: 20) {
                    Button(action: onQuit) {
                        VStack(spacing: 4) {
                            Label("Quit App", systemImage: "xmark.circle")
                                .font(.title3)
                                .fontWeight(.semibold)
                            Text("Press Esc")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.7))
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .tint(.red)
                    .keyboardShortcut(.cancelAction) // Esc key

                    Button(action: onUnlock) {
                        Label("Unlock", systemImage: "faceid")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .tint(.blue)
                    .shadow(radius: 5)
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.4))
    }
}

// #Preview {
//     LockScreenView(appName: "Safari", onUnlock: {}, onQuit: {})
// }
