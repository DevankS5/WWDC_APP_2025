import SwiftUI
import AVFoundation

@main
struct MemoryTrainerApp: App {
    init() {
        setupAudioSession()
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
            print("Audio session setup successfully")
        } catch {
            print("Failed to set audio session category: \(error)")
        }
    }
}

