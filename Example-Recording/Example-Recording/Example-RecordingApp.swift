//
//  Example-RecordingApp.swift
//  Example-Recording
//
//  Created by Ryan LaSante on 5/16/24.
//

import SwiftUI

@main
struct Example_RecordingApp: App {
    @StateObject private var viewModel = RecordingViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
        }
    }
}
