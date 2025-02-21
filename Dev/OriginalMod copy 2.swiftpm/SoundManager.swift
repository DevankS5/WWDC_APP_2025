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
        // Setup background music with improved error handling
        guard let musicURL = Bundle.main.url(forResource: "background", withExtension: "mp3") else {
            print("❌ Critical Error: Could not find background.mp3")
            return
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: musicURL)
            backgroundMusicPlayer?.prepareToPlay()
            backgroundMusicPlayer?.numberOfLoops = -1
            backgroundMusicPlayer?.volume = 0.5
            print("✅")
        } catch {
            print("❌\(error)")
        }
        
        // Setup success sound with improved error handling
        if let successURL = Bundle.main.url(forResource: "success", withExtension: "mp3") {
            print("Found success sound file")
            do {
                successSoundPlayer = try AVAudioPlayer(contentsOf: successURL)
                successSoundPlayer?.prepareToPlay()
                successSoundPlayer?.volume = 1.0
                print("✅ Successfully setup success sound player")
            } catch {
                print("❌ Error loading success sound: \(error)")
            }
        } else {
            print("Could not find success.mp3")
        }
        
        // Setup button sound with improved error handling
        if let buttonURL = Bundle.main.url(forResource: "button", withExtension: "mp3") {
            print("Found button sound file")
            do {
                buttonSoundPlayer = try AVAudioPlayer(contentsOf: buttonURL)
                buttonSoundPlayer?.prepareToPlay()
                buttonSoundPlayer?.volume = 0.8
                print("✅ Successfully setup button sound player")
            } catch {
                print("❌ Error loading button sound: \(error)")
            }
        } else {
            print("Could not find button.mp3")
        }
    }
    
    func playBackgroundMusic() {
        print("Attempting to play background music")
        guard let player = backgroundMusicPlayer else {
            print("❌ Background music player not initialized")
            return
        }
        
        if !player.isPlaying {
            player.currentTime = 0
            player.play()
            print("✅ Started playing background music")
        }
    }
    
    func playSuccessSound() {
        print("Attempting to play success sound")
        guard let player = successSoundPlayer else {
            print("Success sound player not initialized")
            return
        }
        player.stop()
        player.currentTime = 0
        player.play()
        print("✅ Started playing success sound")
    }
    
    func playButtonSound() {
        print("Attempting to play button sound")
        guard let player = buttonSoundPlayer else {
            print("Button sound player not initialized")
            return
        }
        player.stop()
        player.currentTime = 0
        player.play()
        print("✅ Started playing button sound")
    }
    
    func stopBackgroundMusic() {
        print("Stopping background music")
        backgroundMusicPlayer?.stop()
        print("✅ Stopped background music")
    }
}
