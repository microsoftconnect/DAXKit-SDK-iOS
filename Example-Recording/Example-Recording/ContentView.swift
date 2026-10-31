//
//  ContentView.swift
//  Example-Recording
//
//  Created by Ryan LaSante on 5/16/24.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: RecordingViewModel

    var body: some View {
        VStack(spacing: 24) {
            switch viewModel.recordingState {
            case .idle:
                Button("Record") {
                    Task {
                        await viewModel.startRecording()
                    }
                }
                .disabled(!viewModel.isReady)
            case .starting:
                ProgressView("Starting recording...")
            case .recording:
                Spacer()
                ZStack {
                    Circle()
                        .scale(0.5 + CGFloat(viewModel.audioLevel))
                        .fill(.cyan)
                        .opacity(0.25)
                        .animation(.easeInOut, value: 0.5 + CGFloat(viewModel.audioLevel))
                        .frame(minWidth: 100, maxWidth: 200, minHeight: 100, maxHeight: 200)

                    Button("Stop") {
                        Task {
                            await viewModel.stopRecording()
                        }
                    }
                }
                Spacer()
            }

            if let statusMessage = viewModel.statusMessage {
                Text(statusMessage)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

        }
        .padding()
        .task {
            viewModel.initializeAmbient()
        }
    }
}

#Preview {
    ContentView(viewModel: RecordingViewModel())
}
