import AVFoundation

class SoundManager {
    static let shared = SoundManager()
    
    var backgroundMusicPlayer: AVAudioPlayer?
    var successSoundPlayer: AVAudioPlayer?
    var buttonSoundPlayer: AVAudioPlayer?
    
    private init() {
        setupAudioPlayers()
    }
    
    private func setupAudioPlayers() {
        // Setup background music
        if let musicURL = Bundle.main.url(forResource: "background", withExtension: "mp3") {
            do {
                backgroundMusicPlayer = try AVAudioPlayer(contentsOf: musicURL)
                backgroundMusicPlayer?.numberOfLoops = -1 // Loop indefinitely
                backgroundMusicPlayer?.volume = 0.5
            } catch {
                print("Error loading background music: \(error)")
            }
        }
        
        // Setup success sound
        if let successURL = Bundle.main.url(forResource: "success", withExtension: "mp3") {
            do {
                successSoundPlayer = try AVAudioPlayer(contentsOf: successURL)
                successSoundPlayer?.volume = 1.0
            } catch {
                print("Error loading success sound: \(error)")
            }
        }
        
        // Setup button sound
        if let buttonURL = Bundle.main.url(forResource: "button", withExtension: "mp3") {
            do {
                buttonSoundPlayer = try AVAudioPlayer(contentsOf: buttonURL)
                buttonSoundPlayer?.volume = 0.8
            } catch {
                print("Error loading button sound: \(error)")
            }
        }
    }
    
    func playBackgroundMusic() {
        backgroundMusicPlayer?.play()
    }
    
    func playSuccessSound() {
        successSoundPlayer?.play()
    }
    
    func playButtonSound() {
        buttonSoundPlayer?.play()
    }
    
    func stopBackgroundMusic() {
        backgroundMusicPlayer?.stop()
    }
} 