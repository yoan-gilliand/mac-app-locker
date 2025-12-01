# MacAppLocker

A macOS application for locking and monitoring specified applications with biometric authentication.

## Overview

MacAppLocker prevents unauthorized access to selected applications by requiring Touch ID or Face ID authentication before launch. The application runs in the menu bar and monitors specified apps in the background.

## Features

- Application locking with biometric authentication
- Menu bar status indicator
- Real-time app launch monitoring
- SwiftData persistence for locked app configuration
- Native macOS UI with standard menus and keyboard shortcuts

## Requirements

- macOS 14.0 or later
- Xcode 15.0 or later (for building)
- Touch ID or Face ID capable Mac

## Build

```bash
make build
```

Or using xcodebuild directly:

```bash
xcodebuild -project MacAppLocker.xcodeproj -scheme MacAppLocker -destination 'platform=macOS' build
```

## Test

```bash
make test
```

## Run

```bash
make run
```

Then press Cmd+R in Xcode to launch the application.

## Development

### Code Formatting

```bash
make format
```

Requires SwiftFormat:
```bash
brew install swiftformat
```

### Linting

```bash
make lint
```

Requires SwiftLint:
```bash
brew install swiftlint
```

### Pre-commit Hook

The repository includes a pre-commit hook that runs SwiftFormat and SwiftLint on staged files. It is installed at `.git/hooks/pre-commit`.

## Architecture

- **SwiftUI** for user interface
- **SwiftData** for persistent storage
- **LocalAuthentication** for biometric authentication
- **AppKit** for menu bar integration and app monitoring
- **MVVM** pattern with dependency injection

### Project Structure

```
MacAppLocker/
├── App/              # Application entry point and lifecycle
├── Core/             # Core utilities (DI, logging)
├── Features/         # Feature modules (auth, monitoring, persistence)
└── UI/               # User interface components
```

## Usage

1. Launch MacAppLocker
2. Click the lock icon in the menu bar
3. Select "Show Dashboard"
4. Click "Add App" to add applications to lock
5. Select an application bundle (.app) to monitor

When a locked application is launched, MacAppLocker will prompt for authentication before allowing access.

## License

See LICENSE file for details.
