import SwiftUI

// Card type definition
struct Card: Identifiable, Hashable {
    let id: Int
    let symbol: String
    
    init(id: Int, symbol: String) {
        self.id = id
        self.symbol = symbol
    }
    
    static func == (lhs: Card, rhs: Card) -> Bool {
        lhs.id == rhs.id && lhs.symbol == rhs.symbol
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(symbol)
    }
}

// Game phase definition
enum GamePhase {
    case ready, showing, input
}

// Card view definition
struct CardView: View {
    let card: Card
    let themeColor: Color
    let onTap: () -> Void
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white)
                .shadow(radius: 8)
            
            RoundedRectangle(cornerRadius: 25)
                .stroke(themeColor, lineWidth: 4)
            
            Text(card.symbol)
                .font(.system(size: 65))
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
        .accessibilityLabel("Card with symbol \(card.symbol)")
        .accessibilityHint("Double tap to select this card")
        .accessibilityAddTraits(.isButton)
    }
}

// Card Generator
class CardGenerator {
    static let symbols = [
        "🎈", "🎨", "🎭", "🎪", "🎫", "🎮", "🎲", "🎯", "🎱", "🎳",
        "⚽️", "🏀", "🏈", "🎾", "🏐", "🐶", "🐱", "🐭", "🐹", "🐰",
        "🦊", "🐻", "🐼", "🐨", "🐯", "🦁", "🐮", "🐷", "🐸", "🐵"
    ]
    
    static func generateCards(count: Int) -> [Card] {
        var cards: [Card] = []
        let shuffledSymbols = symbols.shuffled()
        
        for i in 0..<count {
            cards.append(Card(id: i, symbol: shuffledSymbols[i]))
        }
        
        return cards
    }
}

// Preview Provider
struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            CardView(card: Card(id: 1, symbol: "🎈"), themeColor: .blue, onTap: {})
                .frame(width: 200, height: 300)
            
            CardView(card: Card(id: 2, symbol: "🎨"), themeColor: .green, onTap: {})
                .frame(width: 200, height: 300)
            
            CardView(card: Card(id: 3, symbol: "🎭"), themeColor: .purple, onTap: {})
                .frame(width: 200, height: 300)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
    }
}

// Add this extension to test if files are properly included
extension Bundle {
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
