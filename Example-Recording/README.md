# Example Recording

This sample demonstrates the Dragon Copilot Ambient 3.0.1 recording flow,
including initializing the client, opening a session, starting and stopping a
recording, and receiving recording delegate callbacks.

## Dragon Copilot Ambient dependency

The Xcode project consumes Dragon Copilot Ambient from the public Swift package:

```text
https://github.com/microsoftconnect/DAXKit-SDK-iOS
```

The dependency is pinned to the public release tag using an exact version
requirement:

```text
3.0.1
```

The package exposes the `DragonCopilotAmbient` product and prebuilt signed
frameworks. The app target also links `Security.framework`, as required by the
published package. No private package feed, local SDK checkout, or separately
embedded DAXKit framework is required.

## Build and run

1. Open `Example-Recording.xcodeproj` in Xcode.
2. Wait for Swift Package Manager to resolve Dragon Copilot Ambient 3.0.1.
3. Replace the provider and token-service placeholders in
   `RecordingViewModel.swift` and `AccessTokenProvider.swift`, including the
   example token-service URL. Select the service environment appropriate for
   your integration.
4. For a physical device, select your own development team under Signing &
   Capabilities and configure a unique bundle identifier.
5. Select an iOS 17.5 or later destination and run the `Example-Recording`
   scheme.

The machine-to-machine token provider is an authentication example, not a
production credential-storage pattern. Do not commit real credentials or
embed a production client secret in a shipped app; obtain tokens through your
secure backend.

## Tests

The shared `Example-Recording` scheme includes unit tests for token-response
validation and recording state/error handling. Run Product > Test in Xcode
with an iOS simulator selected.
