import SwiftUI

struct ScoreboardView: View {
    @ObservedObject var gameManager: GameManager
    @State private var isAnimating = false
    @State private var particles: [ScoreParticle] = []
    
    var body: some View {
        ZStack {
            // Playful particle background
            ForEach(particles) { particle in
                Circle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
                    .position(particle.position)
                    .opacity(particle.opacity)
            }
            .onAppear {
                // Initialize particles
                for _ in 0...30 {
                    particles.append(ScoreParticle())
                }
                // Animate particles
                withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                    for i in particles.indices {
                        particles[i].move(in: UIScreen.main.bounds)
                    }
                }
            }
            
            // Updated gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "FF5E78").opacity(0.4),
                    Color(hex: "FF9671").opacity(0.4),
                    Color(hex: "FFC75F").opacity(0.4)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Trophy animation
                Text("🏆")
                    .font(.system(size: 80))
                    .rotationEffect(.degrees(isAnimating ? 15 : -15))
                    .animation(
                        Animation.easeInOut(duration: 1)
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
                
                Text("High Scores")
                    .font(.custom("Arial Rounded MT Bold", size: 40))
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(hex: "FF5E78").opacity(0.8))
                            .shadow(radius: 10)
                    )
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(
                        .easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
                
                // Enhanced score cards
                VStack(spacing: 25) {
                    EnhancedScoreCard(
                        mode: "Classic Mode",
                        score: gameManager.classicModeHighScore,
                        color: Color(hex: "FF9671"),
                        isAnimating: isAnimating
                    )
                    .offset(x: isAnimating ? 0 : -300)
                    
                    EnhancedScoreCard(
                        mode: "N-Back Mode",
                        score: gameManager.nBackModeHighScore,
                        color: Color(hex: "FFC75F"),
                        isAnimating: isAnimating
                    )
                    .offset(x: isAnimating ? 0 : 300)
                }
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

// Enhanced score card with animations
struct EnhancedScoreCard: View {
    let mode: String
    let score: Int
    let color: Color
    let isAnimating: Bool
    @State private var showScore = false
    
    var body: some View {
        VStack(spacing: 15) {
            Text(mode)
                .font(.custom("Arial Rounded MT Bold", size: 32))
                .foregroundColor(color)
            
            // Animated score reveal
            Text("High Score: \(showScore ? String(score) : "???")")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(color)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.spring()) {
                            showScore = true
                        }
                    }
                }
        }
        .padding(.vertical, 25)
        .padding(.horizontal, 30)
        .frame(maxWidth: .infinity)
        .background(
            ZStack {
                // Card shadow
                RoundedRectangle(cornerRadius: 25)
                    .fill(color.opacity(0.3))
                    .offset(y: 5)
                
                // Main card
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.white.opacity(0.9))
                
                // Shine effect
                RoundedRectangle(cornerRadius: 25)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                .white.opacity(0.5),
                                .clear
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(color, lineWidth: 2)
        )
    }
}

// Particle struct for background animation
struct ScoreParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var color: Color
    var size: CGFloat
    var opacity: Double
    
    init() {
        position = CGPoint(
            x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
            y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
        )
        color = [Color(hex: "FF5E78"), Color(hex: "FF9671"), Color(hex: "FFC75F")].randomElement()!
        size = CGFloat.random(in: 5...15)
        opacity = Double.random(in: 0.3...0.7)
    }
    
    mutating func move(in bounds: CGRect) {
        position = CGPoint(
            x: CGFloat.random(in: 0...bounds.width),
            y: CGFloat.random(in: 0...bounds.height)
        )
    }
}
