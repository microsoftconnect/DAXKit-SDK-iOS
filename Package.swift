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
            url: "https://github.com/microsoftconnect/DAXKit-SDK-iOS/releases/download/0.0.2-alpha.1/DragonCopilotAmbient-0.0.2-alpha.1.xcframework.zip",
            checksum: "efdaf29faf58f27f3012e7c959044dad86862794dd13c897b64c53322b13ce31"
        ),
        .binaryTarget(
            name: "DAXKit",
            url: "https://github.com/microsoftconnect/DAXKit-SDK-iOS/releases/download/0.0.2-alpha.1/DAXKit-0.0.2-alpha.1.xcframework.zip",
            checksum: "da779ac90c00c01970d5854ae97e4f667307f0c6d2fd394850c7b8e5159d4b5a"
        ),
    ]
)
