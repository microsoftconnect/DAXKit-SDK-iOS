//
//  RecordingViewModel.swift
//  Example-Recording
//
//  Created by Ryan LaSante on 5/17/24.
//

import Foundation
import DAXKit

enum RecordingState {
    case idle
    case starting
    case recording
}

final class RecordingViewModel: ObservableObject, RecordingDelegate {
    /// The active session that the recording is being recorded in. This is retained so that if
    /// we wished record multiple times on the same session we don't need to open the same session multiple times.
    /// Instead we can reuse the same DAXSession object and just call startRecording() multiple times.
    /// **Note** that you should never call startRecording() until you have either failed to start or you have received a
    /// didStopRecording() callback.
    private var activeSession: DAXSession?

    /// The current recording that is in progress. This is retained so that we can stop the recording.
    /// **Note** that we should never call stop on the recorder after we have received the didStopRecording().
    private var recorder: Recorder?

    /// The current audio level of the recording. This is updated as the recording is in progress.
    @Published private(set) var audioLevel: Float = 0

    /// State manager for the current recording meant to track when the provider is actively recording
    /// and drive the UI to reflect that.
    @Published private(set) var recordingState = RecordingState.idle
    
    /// Open a new session for recording audio.
    /// **Note** that if the identifier is a previously used one then recordings
    /// will be grouped under that same session and be combined into a single document.
    func openNewSession() {
        // Just generating a random identifier however this should be the correlation id that can then
        // be identified by your backend system when the document and events are delivered.
        let sessionIdentifier = UUID().uuidString
        let session = DAX.shared.session(withIdentifier: sessionIdentifier, ehrData: nil)
        activeSession = session
    }

    /// Start recording on the currently open session.
    /// **Note** that if the user has not been configured, starting the recording will fail.
    func startRecording() {
        // We need to have an active session otherwise we can't start the recording.
        guard let session = activeSession else {
            assertionFailure("No active session to record in")
            return
        }
        do {
            // Start a new recording associated with the session.
            // We're setting ourselves as the RecordingDelegate inorder
            // to get callbacks on the state of the recording.
            //
            // **Note** that recordings can be stopped by calling `recorder.stop()` or by
            // DAXKit stopping the recording automatically. This means that we should
            // track the state and ensure that we aren't just toggling state based on
            // if the user pressed the start or stop button.
            let recorder = try session.startRecording(delegate: self)
            self.recorder = recorder
            // Calling start recording doesn't immediately start the recording.
            // The call is asynchronous from the time to call `session.startRecording()`
            // to the recordingDelegate receiving either `didStartRecording()` or `didFailToStartRecording()`
            recordingState = .starting
        } catch {
            assertionFailure("Failed to start recording: \(error)")
        }
    }

    func stopRecording() {
        do {
            // **Note** This should only ever be called once per recorder.
            // This should never fail but potentially could fail if
            // this is called twice on the same recorder. If you want to start
            // a new recording you should start a new recording from the session
            // instead of reusing the same one.
            try recorder?.stop()
        } catch {
            assertionFailure("Failed to stop recording: \(error)")
        }
    }

    // MARK: - RecordingDelegate Implementation

    func didStartRecording(recordingIdentifier: String, sessionIdentifier: String, audioInputDevice: AudioInputDevice) {
        // The recording successfully started and the user can now start to speak.
        print("Recording started")
        recordingState = .recording
    }
    
    func didFailToStartRecording(sessionIdentifier: String, error: any Error) {
        // The recording failed to start so indicate to the user that an error ocurred
        // and we were unable to start the recording. They should try again.
        // This could occur due to:
        // * the audio system is being used for a higher priority item ala phone call
        // * The recording took too long to start that we determined the user should try again
        //     - This can occur if the audio system is in a bad state or for some reason the
        //       phone was unable to start feeding audio to DAXKit quick enough. Known issues
        //       have been when apple changes its fade out of audio sometimes that can take quite a while.
        //       Another known issue was on iPhone 7's there were cases where the audio engine would get into
        //       a state where it just wouldn't send audio packets. Bugs in microphone/bluetooth could also cause no audio
        //       packets to show.
        print("Failed to start recording: \(error)")
        recordingState = .idle
    }
    
    func didStopRecording(recordingIdentifier: String, sessionIdentifier: String, recordingDuration: TimeInterval) {
        print("Recording stopped after \(recordingDuration) seconds")
        // The recording successfully stopped. This will fire if the recording was stopped by the user or by DAXKit.
        // Even if the recording is interrupted this callback will fire.
        recordingState = .idle
        audioLevel = 0
    }
    
    func recordingInterrupted(reason: DAXKit.RecordingInterruptionReason) {
        // The recording was interrupted for some reason. The current reasons being:
        // * Audio interruptions (other app playing audio, phonecall)
        // * Audio route changes (user plugged in or unplugged headphones or a bluetooth microphone like a car)
        // * Audio system reset (this should be very rare, I don't know that we have seen this in the wild but it's a possibility)
        // * Maximum recording duration has been reached on the current session. Afterwhich no more recordings can be made.
        print("Recording interrupted: \(reason)")
    }
    
    func reachedWarnDuration(timeLeft: TimeInterval) {
        // This callback will fire when the current recording is approaching
        // the max recording duration for a single session.
        // This warning is meant to inform the user how much time is left before the
        // session will automatically stop. Afterwhich there can be no more recordings
        // made for that session.
        //
        // It is recommended that this information is shared with the user in some way.
        // Consider some sort alert, either visual or audio alongside a notification.
        // The audio could be useful if the provider is not looking at their phone, the notification
        // would be useful when the phone is locked (which is quite likely when the provider is in a patient room).
        print("Recording will stop in \(timeLeft) seconds")
    }
    
    func recordedAudio(withDuration duration: TimeInterval, audioLevel level: Float) {
        // This callback will fire many times throughout the recording.
        // It is meant to be used to provide feed back to the user such as timer updates
        // and live audio level indicators.
        // **Note** that this callback is not guarenteed to fire at a consistent rate.
        audioLevel = level
    }
    
    func digitalSilenceDetected() {
        print("Digital Silence Detected")
    }
}
