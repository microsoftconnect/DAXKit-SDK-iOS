//
//  RecordingViewModel.swift
//  Example-Recording
//
//  Created by Ryan LaSante on 5/17/24.
//

import Foundation
import AVFAudio
import DragonCopilotAmbient

enum RecordingState: Equatable {
    case idle
    case starting
    case recording
}

@MainActor
final class RecordingViewModel: ObservableObject {
    private let requestRecordPermission: @MainActor () async -> Bool
    private var client: AmbientClient?
    private var activeSession: AmbientSession?
    private var recording: AmbientRecording?
    private lazy var recordingDelegate = RecordingDelegateAdapter(owner: self)
    private lazy var clientDelegate = ClientDelegateAdapter(owner: self)

    @Published private(set) var audioLevel: Float = 0
    @Published private(set) var recordingState = RecordingState.idle
    @Published private(set) var statusMessage: String?
    @Published private(set) var isReady = false

    init(
        requestRecordPermission: @escaping @MainActor () async -> Bool = {
            await AVAudioApplication.requestRecordPermission()
        },
        session: AmbientSession? = nil,
        recording: AmbientRecording? = nil
    ) {
        self.requestRecordPermission = requestRecordPermission
        activeSession = session
        self.recording = recording
    }

    func initializeAmbient() {
        guard client == nil else { return }

        do {
            let provider = try Provider(
                userId: "UserId",
                emrId: "EMRId",
                name: "User Name",
                email: "User@email.com",
                productId: "ProductId",
                partnerId: "PartnerId",
                customerId: "OrgId",
                geography: "US",
                serverEnvironment: .staging
            )
            let client = try AmbientClient.initialize(
                provider: provider,
                accessTokenProvider: MachineToMachineAccessTokenProvider(),
                delegate: clientDelegate
            )
            self.client = client
            activeSession = client.session(identifier: UUID().uuidString)
            isReady = true
        } catch {
            statusMessage = "Unable to initialize Dragon Copilot Ambient."
        }
    }

    func startRecording() async {
        guard let session = activeSession else {
            statusMessage = "Dragon Copilot Ambient is not initialized."
            return
        }

        let permissionGranted = await requestRecordPermission()
        guard permissionGranted else {
            statusMessage = "Microphone permission is required to record."
            return
        }

        recordingState = .starting
        statusMessage = nil

        do {
            recording = try await session.startRecording(
                locales: [Locale(identifier: "en-US")],
                autoNoteGeneration: true,
                outputFormIds: [],
                delegate: recordingDelegate
            )
        } catch {
            recordingState = .idle
            statusMessage = "Unable to start the recording."
        }
    }

    func stopRecording() async {
        guard let recording else { return }

        do {
            try await recording.stop()
        } catch {
            statusMessage = "Unable to stop the recording."
        }
    }

    func didStartRecording() {
        recordingState = .recording
    }

    func didStopRecording() {
        recordingState = .idle
        audioLevel = 0
        recording = nil
    }

    func recordingWasInterrupted() {
        didStopRecording()
        statusMessage = "The recording was interrupted."
    }

    func didReachWarningDuration(remaining: TimeInterval) {
        statusMessage = "Recording will stop in \(Int(remaining)) seconds."
    }

    func didRecordAudio(level: Float) {
        audioLevel = level
    }

    func didDetectDigitalSilence() {
        statusMessage = "The microphone is delivering digital silence."
    }

    func didFailUpload(willRetry: Bool) {
        guard !willRetry else { return }
        statusMessage = "The recording could not be uploaded."
    }
}

private final class RecordingDelegateAdapter: AmbientRecordingDelegate, @unchecked Sendable {
    private weak var owner: RecordingViewModel?

    init(owner: RecordingViewModel) {
        self.owner = owner
    }

    func didStartRecording(recordingId: String, sessionId: String, inputDevice: AmbientAudioInputDevice) {
        Task { @MainActor [weak owner] in
            owner?.didStartRecording()
        }
    }

    func didStopRecording(recordingId: String, sessionId: String, duration: TimeInterval) {
        Task { @MainActor [weak owner] in
            owner?.didStopRecording()
        }
    }

    func recordingWasInterrupted(
        recordingId: String,
        sessionId: String,
        reason: InterruptionReason,
        details: String?
    ) {
        Task { @MainActor [weak owner] in
            owner?.recordingWasInterrupted()
        }
    }

    func didDetectDigitalSilence(recordingId: String, sessionId: String) {
        Task { @MainActor [weak owner] in
            owner?.didDetectDigitalSilence()
        }
    }

    func didReachWarningDuration(recordingId: String, sessionId: String, remaining: TimeInterval) {
        Task { @MainActor [weak owner] in
            owner?.didReachWarningDuration(remaining: remaining)
        }
    }

    func didRecordAudio(recordingId: String, sessionId: String, duration: TimeInterval, level: Float) {
        Task { @MainActor [weak owner] in
            owner?.didRecordAudio(level: level)
        }
    }
}

private final class ClientDelegateAdapter: AmbientClientDelegate, @unchecked Sendable {
    private weak var owner: RecordingViewModel?

    init(owner: RecordingViewModel) {
        self.owner = owner
    }

    func didCompleteUpload(recordingId: String, sessionId: String) {}

    func didFailUpload(recordingId: String, sessionId: String, error: Error, willRetry: Bool) {
        Task { @MainActor [weak owner] in
            owner?.didFailUpload(willRetry: willRetry)
        }
    }

    func didStartUpload(recordingId: String, sessionId: String) {}

    func didReceiveSupportedLanguages(recordingLocales: [Locale], reportLocales: [Locale]) {}
}
