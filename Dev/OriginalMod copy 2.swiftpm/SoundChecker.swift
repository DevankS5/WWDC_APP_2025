import Foundation

class SoundChecker {
    static func checkSoundFiles() {
        let soundFiles = ["background", "button", "success"]
        
        for fileName in soundFiles {
            if let path = Bundle.main.path(forResource: fileName, ofType: "mp3") {
                print("✅ Found \(fileName).mp3 at: \(path)")
            } else {
                print("❌ Could not find \(fileName).mp3")
            }
        }
    }
}
