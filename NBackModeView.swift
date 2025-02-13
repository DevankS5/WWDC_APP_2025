import SwiftUI

struct NBackModeView: View {
    @ObservedObject var gameManager: GameManager
    @State private var cards: [Card] = []
    @State private var showingCard = false
    @State private var currentCardIndex = 0
    @State private var userSequence: [Int] = []
    @State private var gamePhase: GamePhase = .ready
    @State private var currentLevel = 3
    @State private var displayCards: [Card] = []
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.green.opacity(0.3), .yellow.opacity(0.3)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack {
                Text("N-Back Mode")
                    .font(.custom("Arial Rounded MT Bold", size: 34))
                    .foregroundColor(.green)
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
                            .fill(Color.green)
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
                        Text("Recall the sequence in reverse")
                            .font(.title2.bold())
                            .foregroundColor(.green)
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
                    .foregroundColor(.green)
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
        let reversedCards = cards.map { $0.id }.reversed()
        let correct = zip(userSequence, reversedCards).allSatisfy { $0 == $1 }
        
        if correct {
            gameManager.updateNBackModeScore(currentLevel)
            currentLevel += 2
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                gamePhase = .ready
            }
        } else {
            currentLevel = 3
            gamePhase = .ready
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
}
