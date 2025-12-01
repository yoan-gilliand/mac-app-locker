// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MacAppLocker",
    platforms: [
        .macOS(.v14),
    ],
    products: [
        .executable(
            name: "MacAppLocker",
            targets: ["MacAppLocker"]
        ),
    ],
    targets: [
        .executableTarget(
            name: "MacAppLocker",
            dependencies: [],
            path: "Sources"
            // Removed Resources until we actually have assets to bundle
            // resources: [.process("Resources")]
        ),
        .testTarget(
            name: "MacAppLockerTests",
            dependencies: ["MacAppLocker"],
            path: "Tests"
        ),
    ]
)
