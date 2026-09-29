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
            url: "https://github.com/microsoftconnect/DAXKit-SDK-iOS/releases/download/0.0.2-alpha.3/DragonCopilotAmbient-0.0.2-alpha.3.xcframework.zip",
            checksum: "83e52d1c8111810828b5ad344e47c68cc574c56b5cc010009f014b0394e87c40"
        ),
        .binaryTarget(
            name: "DAXKit",
            url: "https://github.com/microsoftconnect/DAXKit-SDK-iOS/releases/download/0.0.2-alpha.3/DAXKit-0.0.2-alpha.3.xcframework.zip",
            checksum: "963071194736227d975272a98bb436134c4d8e40e244e55eaf84953d197ff7be"
        ),
    ]
)
