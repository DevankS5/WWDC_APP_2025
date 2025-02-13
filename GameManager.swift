import Foundation

class GameManager: ObservableObject {
    @Published var classicModeHighScore = 0
    @Published var nBackModeHighScore = 0
    
    private let userDefaults = UserDefaults.standard
    
    init() {
        loadScores()
    }
    
    func updateClassicModeScore(_ score: Int) {
        if score > classicModeHighScore {
            classicModeHighScore = score
            saveScores()
        }
    }
    
    func updateNBackModeScore(_ score: Int) {
        if score > nBackModeHighScore {
            nBackModeHighScore = score
            saveScores()
        }
    }
    
    private func saveScores() {
        userDefaults.set(classicModeHighScore, forKey: "ClassicModeHighScore")
        userDefaults.set(nBackModeHighScore, forKey: "NBackModeHighScore")
    }
    
    private func loadScores() {
        classicModeHighScore = userDefaults.integer(forKey: "ClassicModeHighScore")
        nBackModeHighScore = userDefaults.integer(forKey: "NBackModeHighScore")
    }
}
