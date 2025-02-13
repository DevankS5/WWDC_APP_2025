import SwiftUI

struct ScoreboardView: View {
    @ObservedObject var gameManager: GameManager
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Playful background
            LinearGradient(
                gradient: Gradient(colors: [.purple.opacity(0.2), .blue.opacity(0.2)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("🏆 Scoreboard 🏆")
                    .font(.custom("Arial Rounded MT Bold", size: 40))
                    .foregroundColor(.purple)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.9))
                            .shadow(radius: 10)
                    )
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
                
                ScoreCard(
                    mode: "Classic Mode",
                    score: gameManager.classicModeHighScore,
                    color: .orange,
                    icon: "🎮"
                )
                .offset(x: isAnimating ? 0 : -300)
                
                ScoreCard(
                    mode: "N-Back Mode",
                    score: gameManager.nBackModeHighScore,
                    color: .green,
                    icon: "🧩"
                )
                .offset(x: isAnimating ? 0 : 300)
            }
            .padding()
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                isAnimating = true
            }
        }
    }
}

struct ScoreCard: View {
    let mode: String
    let score: Int
    let color: Color
    let icon: String
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Text(icon)
                    .font(.system(size: 40))
                Text(mode)
                    .font(.custom("Arial Rounded MT Bold", size: 24))
            }
            
            Text("High Score: \(score)")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.9))
                .shadow(radius: 10)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(color.opacity(0.5), lineWidth: 2)
        )
        .scaleEffect(isAnimating ? 1.0 : 0.8)
        .onAppear {
            withAnimation(.spring()) {
                isAnimating = true
            }
        }
    }
}
