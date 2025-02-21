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
    @State private var showSuccessMessage = false
    @State private var showFailureMessage = false
    @State private var isProcessingTap = false
    
    @State private var floatingCircles: [FloatingCircle] = []
    @State private var cardRotation: Double = 0
    @State private var glowEffect = false
    @State private var scaleEffect = false
    
    var body: some View {
        ZStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [.blue.opacity(0.3), .purple.opacity(0.3)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ForEach(floatingCircles) { circle in
                    Circle()
                        .fill(circle.color)
                        .frame(width: circle.size, height: circle.size)
                        .position(circle.position)
                        .opacity(circle.opacity)
                        .blur(radius: 3)
                }
            }
            .onAppear {
                for _ in 0...15 {
                    floatingCircles.append(FloatingCircle())
                }
                animateCircles()
            }
            
            VStack {
                Text("Classic Mode")
                    .font(.custom("Arial Rounded MT Bold", size: 34))
                    .foregroundColor(.blue)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.white.opacity(0.9))
                            .shadow(radius: 5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.blue.opacity(0.5), lineWidth: 2)
                                    .blur(radius: glowEffect ? 3 : 0)
                            )
                    )
                    .scaleEffect(scaleEffect ? 1.1 : 1.0)
                    .onAppear {
                        withAnimation(Animation.easeInOut(duration: 1.5).repeatForever()) {
                            glowEffect.toggle()
                            scaleEffect.toggle()
                        }
                    }
                
                if gamePhase == .ready {
                    Button("Start Level \(currentLevel)") {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            startGame()
                        }
                    }
                    .font(.title2.bold())
                    .padding(.horizontal, 40)
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.blue)
                            .shadow(radius: 5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white.opacity(0.5), lineWidth: 2)
                            )
                    )
                    .foregroundColor(.white)
                    .transition(.scale.combined(with: .opacity))
                    
                } else if gamePhase == .showing {
                    if showingCard {
                        CardView(
                            card: cards[currentCardIndex],
                            themeColor: .blue,
                            onTap: {}
                        )
                        .frame(width: 250, height: 350)
                        .rotation3DEffect(.degrees(cardRotation), axis: (x: 0, y: 1, z: 0))
                        .shadow(radius: 12)
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .scale.combined(with: .opacity)
                        ))
                    }
                    
                } else if gamePhase == .input {
                    ScrollView {
                        VStack(spacing: 25) {
                            Text("Repeat the sequence")
                                .font(.custom("Arial Rounded MT Bold", size: 36))
                                .foregroundColor(.blue)
                                .padding(.vertical, 15)
                                .padding(.horizontal, 25)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.white.opacity(0.9))
                                        .shadow(radius: 5)
                                )
                            
                            Text("Selected: \(userSequence.count)/\(cards.count)")
                                .foregroundColor(.blue)
                                .font(.title.bold())
                                .padding(.bottom, 10)
                            
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 140))], spacing: 25) {
                                ForEach(displayCards) { card in
                                    CardView(card: card, themeColor: .blue) {
                                        if gamePhase == .input && !isProcessingTap {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                handleCardTap(card)
                                            }
                                            SoundManager.shared.playButtonSound()
                                        }
                                    }
                                    .frame(width: 140, height: 200)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 25)
                                            .stroke(userSequence.contains(card.id) ? Color.green : Color.clear, lineWidth: 4)
                                            .shadow(color: userSequence.contains(card.id) ? Color.green : Color.clear, radius: 8)
                                    )
                                    .saturation(userSequence.contains(card.id) ? 0.7 : 1.0)
                                    .opacity(userSequence.contains(card.id) ? 0.8 : 1.0)
                                }
                            }
                            .padding(30)
                        }
                        .padding(.bottom, 50)
                    }
                }
            }
            
            if showSuccessMessage {
                SuccessView(level: currentLevel)
                    .transition(.scale.combined(with: .opacity))
            }
            
            if showFailureMessage {
                FailureView()
                    .transition(.scale.combined(with: .opacity))
            }
        }
    }
    
    private func startGame() {
        cards = generateCards(count: currentLevel)
        displayCards = cards.shuffled()
        currentCardIndex = 0
        userSequence = []
        showingCard = true
        
        withAnimation {
            gamePhase = .showing
        }
        
        print("Game started with \(cards.count) cards")
        showNextCard()
    }
    
    private func showNextCard() {
        withAnimation(.easeInOut(duration: 0.3)) {
            cardRotation += 180
            showingCard = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeInOut(duration: 0.3)) {
                cardRotation += 180
                showingCard = false
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                currentCardIndex += 1
                if currentCardIndex < cards.count {
                    showNextCard()
                } else {
                    withAnimation {
                        gamePhase = .input
                        userSequence = []
                    }
                }
            }
        }
    }
    
    private func handleCardTap(_ card: Card) {
        guard gamePhase == .input && !isProcessingTap else { return }
        
        isProcessingTap = true
        hapticFeedback()
        
        if userSequence.contains(card.id) {
            userSequence.removeAll { $0 == card.id }
        } else {
            userSequence.append(card.id)
        }
        
        print("Updated sequence: \(userSequence)")
        
        withAnimation(.spring()) {
            let _ = userSequence.count
        }
        
        if userSequence.count == cards.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                checkSequence()
                isProcessingTap = false
            }
        } else {
            isProcessingTap = false
        }
    }
    
    private func checkSequence() {
        print("Checking sequence - Original: \(cards.map { $0.id }), User: \(userSequence)")
        
        let currentCards = cards
        let currentUserSequence = userSequence
        
        DispatchQueue.main.async {
            let isCorrect = zip(currentUserSequence, currentCards.map { $0.id }).allSatisfy { $0 == $1 }
            
            if isCorrect {
                hapticFeedback()
                withAnimation(.spring()) {
                    self.showSuccessMessage = true
                }
                SoundManager.shared.playSuccessSound()
                self.gameManager.updateClassicModeScore(self.currentLevel)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.spring()) {
                        self.showSuccessMessage = false
                        self.currentLevel += 1
                        self.resetGameState()
                    }
                }
            } else {
                hapticFeedback()
                withAnimation(.spring()) {
                    self.showFailureMessage = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.spring()) {
                        self.showFailureMessage = false
                        self.resetGameState()
                    }
                }
            }
        }
    }
    
    private func resetGameState() {
        DispatchQueue.main.async {
            withAnimation(nil) {
                self.userSequence = []
                self.gamePhase = .ready
                self.cards = []
                self.showingCard = false
                self.currentCardIndex = 0
            }
        }
    }
    
    private func generateCards(count: Int) -> [Card] {
        let symbols = [
            "🎈", "🎨", "🎭", "🎪", "🎫", "🎮", "🎲", "🎯", "🎱", "🎳", "⚽️", "🏀", "🏈", "🎾", "🏐",
            "🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼", "🐨", "🐯", "🦁", "🐮", "🐷", "🐸", "🐵",
            "🍎", "🍐", "🍊", "🍋", "🍌", "🍉", "🍇", "🍓", "🫐", "🍒", "🥝", "🍅", "🥥", "🥑", "🌶️",
            "✈️", "🚗", "🚲", "🚂", "🚁", "🚀", "🛸", "🛵", "🏎️", "🚌", "🚓", "🚑", "🚕", "⛵️", "🛳️",
            "🌸", "🌺", "🌻", "🌹", "🌴", "🌈", "⭐️", "🌙", "☀️", "❄️", "🌊", "🔥", "⚡️", "🌍", "🌵",
            "💎", "🎵", "🎨", "🎬", "📱", "⌚️", "💻", "🎸", "🎺", "🎭", "🎪"
        ]
        
        var cards: [Card] = []
        let shuffledSymbols = symbols.shuffled()
        
        if count > shuffledSymbols.count {
            fatalError("Not enough unique symbols for level \(count)")
        }
        
        for i in 0..<count {
            cards.append(Card(id: i, symbol: shuffledSymbols[i]))
        }
        
        return cards
    }
    
    private func animateCircles() {
        withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
            for i in floatingCircles.indices {
                floatingCircles[i].move()
            }
        }
    }
    
    private func hapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

struct FloatingCircle: Identifiable {
    let id = UUID()
    var position: CGPoint
    let color: Color
    let size: CGFloat
    let opacity: Double
    
    init() {
        position = CGPoint(
            x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
            y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
        )
        color = [Color(red: 0.0, green: 0.0, blue: 1.0),
                Color(red: 0.5, green: 0.0, blue: 0.5)].randomElement()!
            .opacity(0.2)
        size = CGFloat.random(in: 50...150)
        opacity = Double.random(in: 0.1...0.3)
    }
    
    mutating func move() {
        position = CGPoint(
            x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
            y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
        )
    }
}

struct SuccessView: View {
    let level: Int
    @State private var scale = 0.5
    
    var body: some View {
        VStack {
            Text("Excellent!")
                .font(.custom("Arial Rounded MT Bold", size: 40))
                .foregroundColor(.green)
            Text("Level \(level) completed!")
                .font(.title2)
                .foregroundColor(.green)
        }
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white.opacity(0.95))
                .shadow(radius: 10)
        )
        .scaleEffect(scale)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                scale = 1.0
            }
        }
    }
}

struct FailureView: View {
    @State private var shake = false
    
    var body: some View {
        VStack {
            Text("Try Again")
                .font(.custom("Arial Rounded MT Bold", size: 40))
                .foregroundColor(.red)
            Text("Keep practicing!")
                .font(.title2)
                .foregroundColor(.red)
        }
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white.opacity(0.95))
                .shadow(radius: 10)
        )
        .offset(x: shake ? -10 : 0)
        .onAppear {
            withAnimation(.default.repeatCount(3)) {
                shake.toggle()
            }
        }
    }
}
