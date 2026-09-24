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
            url: "https://github.com/microsoftconnect/DAXKit-SDK-iOS/releases/download/0.0.2-alpha.2/DragonCopilotAmbient-0.0.2-alpha.2.xcframework.zip",
            checksum: "dc216f7e5ed72ee5a8b243fe4edcaf81b1f74911e91188e06e172519e40e6fd8"
        ),
        .binaryTarget(
            name: "DAXKit",
            url: "https://github.com/microsoftconnect/DAXKit-SDK-iOS/releases/download/0.0.2-alpha.2/DAXKit-0.0.2-alpha.2.xcframework.zip",
            checksum: "10d84486924c07bec13d05339652f8b6d817ee56f9a940f061e677a6b2d68a84"
        ),
    ]
)
