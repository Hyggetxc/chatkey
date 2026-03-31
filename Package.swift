// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ChatKey",
    platforms: [
        .macOS(.v14),
    ],
    products: [
        .executable(
            name: "ChatKey",
            targets: ["ChatKey"]
        ),
    ],
    targets: [
        .executableTarget(
            name: "ChatKey"
        ),
        .testTarget(
            name: "ChatKeyTests",
            dependencies: ["ChatKey"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
