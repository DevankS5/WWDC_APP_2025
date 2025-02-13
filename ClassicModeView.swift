import SwiftUI

struct ClassicModeView: View {
    @ObservedObject var gameManager: GameManager
    @State private var cards: [Card] = []
    @State private var showingCard = false
    @State private var currentCardIndex = 0
    @State private var userSequence: [Int] = []
    @State private var gamePhase: GamePhase = .ready
    @State private var currentLevel = 3
    @State private var displayCards: [Card] = []
    @State private var showCelebration = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.blue.opacity(0.3), .purple.opacity(0.3)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack {
                Text("Classic Mode")
                    .font(.custom("Arial Rounded MT Bold", size: 34))
                    .foregroundColor(.purple)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.white.opacity(0.9))
                            .shadow(radius: 5)
                    )
                
                if gamePhase == .ready {
                    Button("Start Game") {
                        startGame()
                    }
                    .font(.title2.bold())
                    .padding(.horizontal, 40)
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.blue)
                            .shadow(radius: 5)
                    )
                    .foregroundColor(.white)
                    .scaleEffect(1.0)
                    .animation(.spring(), value: gamePhase)
                
                } else if gamePhase == .showing {
                    CardView(card: cards[currentCardIndex])
                        .frame(width: 200, height: 300)
                        .transition(.scale)
                        .animation(.spring(), value: currentCardIndex)
                
                } else if gamePhase == .input {
                    VStack {
                        Text("Recall the sequence")
                            .font(.title2.bold())
                            .foregroundColor(.purple)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.white.opacity(0.9))
                                    .shadow(radius: 3)
                            )
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 15) {
                            ForEach(displayCards) { card in
                                CardView(card: card)
                                    .frame(width: 100, height: 150)
                                    .onTapGesture {
                                        handleCardTap(card)
                                    }
                                    .scaleEffect(1.0)
                                    .animation(.spring(), value: gamePhase)
                            }
                        }
                        .padding()
                    }
                }
                
                Text("Level \(currentLevel)")
                    .font(.title2.bold())
                    .foregroundColor(.purple)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.white.opacity(0.9))
                            .shadow(radius: 3)
                    )
            }
            .padding()
        }
    }
    
    private func startGame() {
        cards = generateCards(count: currentLevel)
        let shuffledIndices = Array(0..<cards.count).shuffled()
        cards = shuffledIndices.map { cards[$0] }
        displayCards = cards.shuffled()
        gamePhase = .showing
        currentCardIndex = 0
        userSequence = []
        showNextCard()
    }
    
    private func showNextCard() {
        if currentCardIndex < cards.count {
            showingCard = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                currentCardIndex += 1
                if currentCardIndex < cards.count {
                    showNextCard()
                } else {
                    gamePhase = .input
                }
            }
        }
    }
    
    private func handleCardTap(_ card: Card) {
        userSequence.append(card.id)
        
        if userSequence.count == cards.count {
            checkSequence()
        }
    }
    
    private func checkSequence() {
        let correct = zip(userSequence, cards.map { $0.id }).allSatisfy { $0 == $1 }
        
        if correct {
            gameManager.updateClassicModeScore(currentLevel)
            currentLevel += 2
            playCelebrationEffect()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                gamePhase = .ready
            }
        } else {
            currentLevel = 3
            gamePhase = .ready
        }
    }
    
    private func playCelebrationEffect() {
        SoundManager.shared.playSuccessSound()
        
        withAnimation(.spring()) {
            showCelebration = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showCelebration = false
            }
        }
    }
}

enum GamePhase {
    case ready, showing, input
}

struct Card: Identifiable {
    let id: Int
    let symbol: String
}

struct CardView: View {
    let card: Card
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [.white, .blue.opacity(0.2)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: 2)
            
            Text(card.symbol)
                .font(.system(size: 40))
                .shadow(radius: 1)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.blue.opacity(0.3), lineWidth: 2)
        )
    }
}

    func generateCards(count: Int) -> [Card] {
        // Extended symbol set to support up to level 71
        let symbols = [
            // Original set
            "🎈", "🎨", "🎭", "🎪", "🎫", "🎮", "🎲", "🎯", "🎱", "🎳", "⚽️", "🏀", "🏈", "🎾", "🏐",
            // Animals
            "🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼", "🐨", "🐯", "🦁", "🐮", "🐷", "🐸", "🐵",
            // Food
            "🍎", "🍐", "🍊", "🍋", "🍌", "🍉", "🍇", "🍓", "🫐", "🍒", "🥝", "🍅", "🥥", "🥑", "🌶️",
            // Transport
            "✈️", "🚗", "🚲", "🚂", "🚁", "🚀", "🛸", "🛵", "🏎️", "🚌", "🚓", "🚑", "🚕", "⛵️", "🛳️",
            // Nature
            "🌸", "🌺", "🌻", "🌹", "🌴", "🌈", "⭐️", "🌙", "☀️", "❄️", "🌊", "🔥", "⚡️", "🌍", "🌵",
            // Additional symbols
            "💎", "🎵", "🎨", "🎬", "📱", "⌚️", "💻", "🎸", "🎺", "🎭", "🎪"
        ]
        
        var cards: [Card] = []
        let shuffledSymbols = symbols.shuffled()
        
        // Ensure we have enough unique symbols for the level
        if count > shuffledSymbols.count {
            fatalError("Not enough unique symbols for level \(count)")
        }
        
        for i in 0..<count {
            cards.append(Card(id: i, symbol: shuffledSymbols[i]))
        }
        
        return cards
    }

