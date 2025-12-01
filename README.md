# 🔒 Mac App Locker

Mac App Locker is a native macOS application designed to protect your privacy by locking specific applications behind biometric authentication (Touch ID / Face ID) or a password.

It features a robust monitoring system that detects when protected applications are launched or activated, immediately hiding them and presenting a secure lock screen overlay.

## ✨ Features

-   **Biometric Security**: Unlock apps using Touch ID or Face ID.
-   **Privacy First**: Locked apps are immediately **hidden** from view, including from Mission Control and the Dock.
-   **Robust Monitoring**:
    -   **Instant Detection**: Detects app activation instantly.
    -   **Lock Enforcer**: A background agent that continuously ensures locked apps remain hidden if they try to reappear.
    -   **Smart Session**: Prevents annoying re-locking loops while you are using the unlocked app.
-   **Native UI**: Built with SwiftUI for a modern, seamless macOS experience.
-   **Keyboard Friendly**: Use `Esc` to quickly quit a locked app from the lock screen.

## 🛠 Technical Architecture

The project follows a clean **MVVM (Model-View-ViewModel)** architecture with a centralized **Dependency Injection (DI)** system.

### Core Components

*   **`AppMonitorService`**: The heart of the application. It observes `NSWorkspace` notifications to detect app usage, manages the "Hide & Shield" logic, and enforces security policies.
*   **`AuthenticationService`**: Handles interaction with the `LocalAuthentication` framework.
*   **`PersistenceService`**: Manages the list of locked applications using **SwiftData**.
*   **`LockScreenWindowController`**: Manages the floating, high-priority window overlay that blocks access to locked apps.

### Key Technologies

*   **Language**: Swift 6
*   **UI Framework**: SwiftUI & AppKit (for window management)
*   **Data**: SwiftData
*   **Concurrency**: Swift Concurrency (`async/await`, `@MainActor`)

## 🚀 Getting Started

### Prerequisites

*   **macOS 14.0 (Sonoma)** or later.
*   **Xcode 15.0** or later.
*   **Homebrew** (for linting tools).

### Installation

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/yoan-gilliand/mac-app-locker.git
    cd mac-app-locker
    ```

2.  **Install Development Tools**:
    We use `SwiftLint` and `SwiftFormat` to enforce code quality.
    ```bash
    brew install swiftlint swiftformat
    ```

3.  **Setup Hooks**:
    Run the setup script to install the git pre-commit hook. This ensures all code is formatted and linted before committing.
    ```bash
    chmod +x scripts/setup_hooks.sh
    ./scripts/setup_hooks.sh
    ```

4.  **Open in Xcode**:
    Double-click `Package.swift` or open the folder in Xcode.

## 👨‍💻 Development Workflow

### Code Style
The project enforces strict code style rules.
*   **Linting**: Checked by `SwiftLint`.
*   **Formatting**: Enforced by `SwiftFormat`.

If you try to commit code that violates these rules, the pre-commit hook will either fix it automatically (formatting) or block the commit (linting errors).

### Branching Strategy
*   `main`: Stable, production-ready code.
*   `develop`: Integration branch for ongoing development.
*   `feat/feature-name`: Feature branches.

### Common Issues

**SwiftLint Crash on Commit**:
If you see `Fatal error: Loading sourcekitdInProc.framework...` during a commit, it is likely a local environment issue with SwiftLint finding the Xcode path.
*   *Workaround*: Ensure your Xcode command line tools are selected correctly: `xcode-select -s /Applications/Xcode.app/Contents/Developer`.

## 🛡 Security Model

### The "Hide & Shield" Strategy
To prevent content leaks in Mission Control:
1.  **Hide**: The target app is hidden (`app.hide()`) immediately upon detection.
2.  **Shield**: A high-level `NSPanel` overlay is presented.
3.  **Enforce**: A background loop checks every 0.5s if a locked app has become visible and re-hides it.

## 📄 License

This project is licensed under the MIT License.
