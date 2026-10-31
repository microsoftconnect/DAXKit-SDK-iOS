import XCTest
import DragonCopilotAmbient
@testable import Example_Recording

final class AccessTokenProviderTests: XCTestCase {
    func testTokenResponseAcceptsIntegerExpiry() throws {
        let data = try JSONSerialization.data(withJSONObject: [
            "access_token": "synthetic-token",
            "expires_in": 3600,
        ])

        let token = try MachineToMachineAccessTokenProvider.tokenResponse(from: data)

        XCTAssertEqual(token.value, "synthetic-token")
        XCTAssertEqual(token.expiresIn, 3600)
    }

    func testTokenResponseRejectsMissingExpiry() throws {
        let data = try JSONSerialization.data(withJSONObject: [
            "access_token": "synthetic-token",
        ])

        XCTAssertThrowsError(try MachineToMachineAccessTokenProvider.tokenResponse(from: data))
    }

    func testTokenResponseRejectsEmptyToken() throws {
        let data = try JSONSerialization.data(withJSONObject: [
            "access_token": " ",
            "expires_in": 3600,
        ])

        XCTAssertThrowsError(try MachineToMachineAccessTokenProvider.tokenResponse(from: data))
    }

    func testTokenResponseRejectsNonPositiveExpiry() throws {
        let data = try JSONSerialization.data(withJSONObject: [
            "access_token": "synthetic-token",
            "expires_in": 0,
        ])

        XCTAssertThrowsError(try MachineToMachineAccessTokenProvider.tokenResponse(from: data))
    }
}

@MainActor
final class RecordingViewModelTests: XCTestCase {
    func testStartWithoutInitializationSurfacesError() async {
        let model = RecordingViewModel()

        await model.startRecording()

        XCTAssertEqual(model.recordingState, .idle)
        XCTAssertEqual(model.statusMessage, "Dragon Copilot Ambient is not initialized.")
    }

    func testPermissionDenialDoesNotStartSession() async {
        let session = MockAmbientSession()
        let model = RecordingViewModel(
            requestRecordPermission: { false },
            session: session
        )

        await model.startRecording()

        XCTAssertEqual(session.startCallCount, 0)
        XCTAssertEqual(model.recordingState, .idle)
        XCTAssertEqual(model.statusMessage, "Microphone permission is required to record.")
    }

    func testStartFailureResetsStateAndSurfacesError() async {
        let session = MockAmbientSession(startError: TestError.synthetic)
        let model = RecordingViewModel(
            requestRecordPermission: { true },
            session: session
        )

        await model.startRecording()

        XCTAssertEqual(session.startCallCount, 1)
        XCTAssertEqual(model.recordingState, .idle)
        XCTAssertEqual(model.statusMessage, "Unable to start the recording.")
    }

    func testStopFailureSurfacesError() async {
        let recording = MockAmbientRecording(stopError: TestError.synthetic)
        let model = RecordingViewModel(recording: recording)

        await model.stopRecording()

        XCTAssertEqual(recording.stopCallCount, 1)
        XCTAssertEqual(model.statusMessage, "Unable to stop the recording.")
    }

    func testRecordingDelegateUpdatesRecordingState() {
        let model = RecordingViewModel()

        model.didStartRecording()

        XCTAssertEqual(model.recordingState, .recording)
    }

    func testAudioDelegateUpdatesLevel() {
        let model = RecordingViewModel()

        model.didRecordAudio(level: 0.75)

        XCTAssertEqual(model.audioLevel, 0.75)
    }

    func testInterruptionResetsRecordingState() {
        let model = RecordingViewModel()
        model.didStartRecording()
        model.didRecordAudio(level: 0.75)

        model.recordingWasInterrupted()

        XCTAssertEqual(model.recordingState, .idle)
        XCTAssertEqual(model.audioLevel, 0)
        XCTAssertEqual(model.statusMessage, "The recording was interrupted.")
    }

    func testRetryableUploadFailureDoesNotSurfaceTerminalStatus() {
        let model = RecordingViewModel()

        model.didFailUpload(willRetry: true)

        XCTAssertNil(model.statusMessage)
    }

    func testTerminalUploadFailureSurfacesStatus() {
        let model = RecordingViewModel()

        model.didFailUpload(willRetry: false)

        XCTAssertEqual(model.statusMessage, "The recording could not be uploaded.")
    }
}

private enum TestError: Error {
    case synthetic
}

private final class MockAmbientRecording: AmbientRecording {
    private let stopError: Error?
    private(set) var stopCallCount = 0

    init(stopError: Error? = nil) {
        self.stopError = stopError
    }

    func stop() async throws {
        stopCallCount += 1
        if let stopError {
            throw stopError
        }
    }
}

private final class MockAmbientSession: AmbientSession {
    let sessionId = "synthetic-session"
    private let startError: Error?
    private(set) var startCallCount = 0

    init(startError: Error? = nil) {
        self.startError = startError
    }

    func startRecording(
        locales: [Locale],
        autoNoteGeneration: Bool,
        outputFormIds: [String],
        delegate: AmbientRecordingDelegate,
        traceContext: TraceContext?
    ) async throws -> AmbientRecording {
        startCallCount += 1
        if let startError {
            throw startError
        }
        return MockAmbientRecording()
    }
}
