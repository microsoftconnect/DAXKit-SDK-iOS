//
//  Example-RecordingApp.swift
//  Example-Recording
//
//  Created by Ryan LaSante on 5/16/24.
//

import SwiftUI
import DAXKit
import AVFAudio

@main
struct Example_RecordingApp: App {
    var daxkitdelegate = DAXDelegate()
    init() {
        do {
            try startDAXKit()
            try loginUser()
            requestRecordingPermissions()
        } catch {
            assertionFailure("Error starting DAXKit: \(error)")
        }
    }

    // MARK: - DAXKit Start
    private func startDAXKit() throws {
        // **Only once** per application run call DAX.start()
        // **Note** subsequent calls will be ignored so you can only
        // update these passed in values on the next application run.
        try DAX.start(
            withAppMetadataProvider: ExampleAppMetadataProvider(),
            accessTokenProvider: Machine2MachineAccessTokenProvider(),
            delegate: daxkitdelegate,
            partnerId: "44f33add-5032-452c-9c23-82a903307a8e"
        )
    }

    // MARK: - DAXKit Login
    private func loginUser() throws {
        // Inform DAXKit who the user is and what product they are using.
        try DAX.shared.configure([
            // Associated DAX product. Associated Value Type: String
            DAX.ConfigurationKeys.Provider.productId: "ProductId",

            // Org id from NMS. Associated Value Type: String
            DAX.ConfigurationKeys.Provider.orgId: "OrgId",
            
            // DAX Specific user identifier. Associated Value Type: String
            DAX.ConfigurationKeys.Provider.userId: "UserId",

            // EMR specific user identifier. Associated Value Type: String
            DAX.ConfigurationKeys.Provider.emrId: "EMRId",

            // User email. Associated Value Type: String
            DAX.ConfigurationKeys.Provider.email: "User@email.com",

            // User's name. Associated Value Type: String
            DAX.ConfigurationKeys.Provider.name: "User Name",

            // User's geography. Associated Value Type: ISO 3166-1 Alpha2 String
            DAX.ConfigurationKeys.Provider.geography: "US",

            // Server environment to point DAX to. Associated Value Type: String (defined on ServerEnvironments)
            DAX.ConfigurationKeys.ServerEnvironment.environment: ServerEnvironments.staging,
        ])

        // Enable uploads to DAX now the user has logged in.
        try DAX.shared.resumeUploads()
    }

    // MARK: - Request Recording Permissions
    private func requestRecordingPermissions() {
        // Request recording permissions from the user at the time of your choosing.
        AVAudioApplication.requestRecordPermission { granted in
            print("Recording Permission Granted: \(granted)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

final class DAXDelegate: DAXKitDelegate {
    func uploadedRecording(recordingIdentifier: String, sessionIdentifier: String) {}
    func uploadFailed(recordingIdentifier: String, sessionIdentifier: String, error: any Error, willRetryUpload: Bool) {}
    func recordingPermission(granted: Bool) {}
    func didStartUpload(recordingIdentifier: String, sessionIdentifier: String) {}
    func didFinishAllUploads() {}
    func didCompleteSession(identifier: String) {}
    func didFailToCompleteSession(identifier: String, withError error: any Error) {}
    func didReceiveSupportedLanguages(recordingLocales: [Locale], reportLocales: [Locale]) {}
}
