//
//  AppMetadataProvider.swift
//  Example-Recording
//
//  Created by Ryan LaSante on 5/16/24.
//

import Foundation
import DAXKit
import UIKit

/// This is an example implementation of the AppMetadataProvider.
/// It provides the DAX system with information about the application and device for diagnosing issues.
final class ExampleAppMetadataProvider: AppMetadataProvider {

    // Realistically it should be safe to force unwrap but, to be even safer, we provide a default.
    var appID: String = Bundle.main.bundleIdentifier ?? "Example-Recording"

    // This should also be safe to force unwrap but we provide a default.
    var appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"

    // This is documented as potentially blank. We've never seen that case, but again we provide a default to be safe.
    var deviceID: String = UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
}
