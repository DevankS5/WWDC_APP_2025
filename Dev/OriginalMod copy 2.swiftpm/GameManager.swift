import Foundation
import SwiftUI

class GameManager: ObservableObject {
    @Published var classicModeHighScore = 0
    @Published var nBackModeHighScore = 0
    @Published var gamesPlayed = 0
    @Published var totalCorrectSequences = 0
    @Published var averageScore: Double = 0
    
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
        userDefaults.set(gamesPlayed, forKey: "GamesPlayed")
        userDefaults.set(totalCorrectSequences, forKey: "TotalCorrectSequences")
        userDefaults.set(averageScore, forKey: "AverageScore")
    }
    
    private func loadScores() {
        classicModeHighScore = userDefaults.integer(forKey: "ClassicModeHighScore")
        nBackModeHighScore = userDefaults.integer(forKey: "NBackModeHighScore")
        gamesPlayed = userDefaults.integer(forKey: "GamesPlayed")
        totalCorrectSequences = userDefaults.integer(forKey: "TotalCorrectSequences")
        averageScore = userDefaults.double(forKey: "AverageScore")
    }
    
    func updateStatistics(mode: String, score: Int, isCorrect: Bool) {
        gamesPlayed += 1
        if isCorrect {
            totalCorrectSequences += 1
        }
        averageScore = Double(totalCorrectSequences) / Double(gamesPlayed)
        saveScores()
    }
}

#if DEBUG
struct GameManagerPreviewView: View {
    @StateObject private var gameManager = GameManager()
    
    var body: some View {
        VStack {
            Text("Classic Mode High Score: \(gameManager.classicModeHighScore)")
            Text("N-Back Mode High Score: \(gameManager.nBackModeHighScore)")
            Text("Games Played: \(gameManager.gamesPlayed)")
        }
    }
}

struct GameManager_Previews: PreviewProvider {
    static var previews: some View {
        GameManagerPreviewView()
    }
}
#endif
