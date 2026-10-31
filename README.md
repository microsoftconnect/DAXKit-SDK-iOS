# DAXKit-SDK-iOS

This repository distributes the Dragon Copilot Ambient iOS SDK as signed
binary Swift packages.

## Installation

### Swift Package Manager

Add the public package with an exact version requirement:

```swift
dependencies: [
    .package(url: "https://github.com/microsoftconnect/DAXKit-SDK-iOS", exact: "3.0.1")
]
```

Select the `DragonCopilotAmbient` product for your app target and link
`Security.framework`. The package includes the DAXKit binary required by the
Ambient SDK; do not add a separate DAXKit dependency or embed the legacy
checked-in framework.

## Recording example

See [Example-Recording](Example-Recording/README.md) for a standalone Xcode
sample using the public SDK tag `3.0.1`. It demonstrates client initialization,
microphone permission, session recording, audio-level callbacks, and error
handling without a private package feed or local SDK checkout.
