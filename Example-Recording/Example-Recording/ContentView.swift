//
//  ContentView.swift
//  Example-Recording
//
//  Created by Ryan LaSante on 5/16/24.
//

import SwiftUI
import DAXKit

struct ContentView: View {
    @ObservedObject var viewModel = RecordingViewModel()
    var body: some View {
        VStack {
            switch viewModel.recordingState {
            case .idle:
                // Show a record button when not recording.
                Button("Record") {
                    viewModel.openNewSession()
                    viewModel.startRecording()
                }
            case .starting:
                // Show a progress view while starting the recording.
                ProgressView("Starting recording...")
            case .recording:
                Spacer()
                ZStack {
                    // Audio feedback visualizer
                    Circle()
                        .scale(0.5 + CGFloat(viewModel.audioLevel))
                        .fill(.cyan)
                        .opacity(0.25)
                        .animation(.easeInOut, value: 0.5 + CGFloat(viewModel.audioLevel))
                        .frame(minWidth: 100, maxWidth: 200, minHeight: 100, maxHeight: 200)

                    // Recording stop button
                    Button("Stop") {
                        viewModel.stopRecording()
                    }
                }
                Spacer()
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
