// swift-tools-version: 5.10
//
// PUBLISHED manifest for the DragonCopilotAmbient SDK.
//
// This is the ONLY Package.swift customers ever see. It is intentionally a thin
// SPM wrapper around two prebuilt, signed binary xcframeworks and NOTHING else.
//
// The second `DAXKit` binary target is intentional: listing it in the product's
// `targets` is the SPM mechanism that auto-embeds the legacy framework into the
// customer app. This is part of the migration contract ("remove your own
// DAXKit.xcframework; ours brings it"). Note that it DOES expose `DAXKit` as an
// importable binary module in the product, so customers must remove any separate
// legacy `DAXKit` dependency to avoid duplicate-module / duplicate-framework
// conflicts.
//

import PackageDescription

// Your app target must also link Security.framework
// (Target -> Build Phases -> Link Binary With Libraries). The frameworks below
// ship as static binaries, which cannot declare link-time dependencies for you.

let package = Package(
    name: "DragonCopilotAmbient",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "DragonCopilotAmbient",
            targets: ["DragonCopilotAmbient", "DAXKit"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "DragonCopilotAmbient",
            url: "https://github.com/microsoftconnect/DAXKit-SDK-iOS/releases/download/3.0.1/DragonCopilotAmbient-3.0.1.xcframework.zip",
            checksum: "3b493ba7bd8ebf198578ad861a2651e54f2adf487116421f431aaae49dd70051"
        ),
        .binaryTarget(
            name: "DAXKit",
            url: "https://github.com/microsoftconnect/DAXKit-SDK-iOS/releases/download/3.0.1/DAXKit-3.0.1.xcframework.zip",
            checksum: "4fa8ffb14327360b276b10191e9346aff46a80c0e38c2dcf03b1961431114d5c"
        ),
    ]
)
