// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DAXKit",
    platforms: [
        .macOS(.v13),
        .iOS(.v15),
    ],
    products: [
        .library(
            name: "DAXKit",
            targets: ["DAXKit"]
        )
    ],
    targets: [
        .binaryTarget(
            name: "DAXKit",
            path: "./DAXKit.xcframework"
        )
    ]
)
