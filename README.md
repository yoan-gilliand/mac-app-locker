# 🔒 Mac App Locker

**Secure your applications with ease.**

Mac App Locker is a lightweight, secure, and modern utility that allows you to password-protect any application on your Mac. Prevent unauthorized access to your sensitive apps with a simple, elegant lock screen.

![Mac App Locker Screenshot](https://i.ibb.co/JR8SsZKW/Screenshot-2025-12-01-at-21-35-51.png)

## ✨ Features

-   **🔒 Secure Locking**: Instantly lock any application with a single click.
-   **🛡️ Kiosk Mode**: Blocks Mission Control, Dock, and Menu Bar when an app is locked, ensuring total security.
-   **🎨 Modern Design**: Beautiful, native macOS interface with a premium lock screen experience.
-   **⌨️ Shortcuts**: Use `Cmd + Q` to safely quit the locked app overlay.
-   **⚙️ Custom Preferences**:
    -   Launch at Login
    -   Hide/Show Menu Bar Icon
    -   Hide/Show Dock Icon
-   **🚀 Lightweight**: Minimal system resource usage.

## 📦 Installation

### Download Binary
1.  Go to the [Releases](https://github.com/yoan-gilliand/mac-app-locker/releases) page.
2.  Download the latest `MacAppLocker.zip`.
3.  Unzip and drag `MacAppLocker.app` to your **Applications** folder.
4.  Open the app. You may need to allow it in **System Settings > Privacy & Security** if prompted.

### Build from Source
Requirements: Xcode 15+

1.  Clone the repository:
    ```bash
    git clone https://github.com/yoan-gilliand/mac-app-locker.git
    cd mac-app-locker
    ```
2.  Build the app:
    ```bash
    make build
    ```
    Or to build a release version:
    ```bash
    make archive
    ```

## 🛠️ Usage

1.  **Add Apps**: Click the "+" button in the dashboard or press `Cmd + N` to select an app to lock.
2.  **Lock/Unlock**: Use the toggle switch next to each app to enable or disable locking.
3.  **Authentication**: When you open a locked app, you will be prompted to authenticate (Touch ID or Password) to access it.
4.  **Preferences**: Access settings via `Cmd + ,` or the Menu Bar icon.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1.  Fork the project.
2.  Create your feature branch (`git checkout -b feature/AmazingFeature`).
3.  Commit your changes (`git commit -m 'Add some AmazingFeature'`).
4.  Push to the branch (`git push origin feature/AmazingFeature`).
5.  Open a Pull Request.

---
*Created by [Yoan Gilliand](https://yoan-gilliand.ch)*
