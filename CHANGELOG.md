# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-12-01

### Added
- **Core Locking**: Securely lock any macOS application with a simple toggle.
- **Kiosk Mode**: Blocks Mission Control, Dock, and Menu Bar when a locked app is active to prevent bypassing.
- **Authentication**: Integration with Touch ID and system password for unlocking apps.
- **Dashboard**: Centralized view to manage locked applications, add new ones, and toggle locks.
- **Modern UI**:
    - Glassmorphism effects on the lock screen.
    - Premium "Squircle" app icon with transparent background.
    - Clean, native macOS design for Dashboard and Settings.
- **Preferences**:
    - Option to launch at login.
    - Toggle visibility of Menu Bar and Dock icons.
    - Security settings for authentication requirements.
- **Shortcuts**:
    - `Cmd + N` to add an app.
    - `Cmd + Q` to quit the lock screen overlay.
- **Developer Experience**:
    - Comprehensive Unit and UI Tests.
    - Automated CI/CD pipeline with GitHub Actions.
    - `Makefile` for easy building, testing, and linting.
    - Standardized file headers and strict linting rules.
