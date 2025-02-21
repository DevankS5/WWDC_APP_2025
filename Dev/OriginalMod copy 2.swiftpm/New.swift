import SwiftUI

struct ContentView: View {
    @StateObject private var gameManager = GameManager()
    @State private var isAnimating = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [.blue.opacity(0.3), .purple.opacity(0.3), .pink.opacity(0.3)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                .overlay(
                    ZStack {
                        ForEach(0..<5) { index in
                            Circle()
                                .fill(Color.yellow.opacity(0.2))
                                .frame(width: CGFloat.random(in: 50...100))
                                .offset(x: isAnimating ? CGFloat.random(in: -200...200) : 0,
                                      y: isAnimating ? CGFloat.random(in: -300...300) : 0)
                                .animation(
                                    Animation.easeInOut(duration: Double.random(in: 2...4))
                                        .repeatForever(autoreverses: true)
                                        .delay(Double(index) * 0.3),
                                    value: isAnimating
                                )
                        }
                    }
                )
                
                VStack(spacing: 30) {
                    Text("Memory Trainer")
                        .font(.custom("Arial Rounded MT Bold", size: 40))
                        .foregroundColor(.blue)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.9))
                                .shadow(radius: 10)
                        )
                        .scaleEffect(isAnimating ? 1.1 : 1.0)
                        .animation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
                    
                    NavigationLink(destination: ClassicModeView(gameManager: gameManager)) {
                        MenuButton(title: "Classic Mode", color: .orange, icon: "🎮")
                    }
                    
                    NavigationLink(destination: NBackModeView(gameManager: gameManager)) {
                        MenuButton(title: "N-Back Mode", color: .green, icon: "🧩")
                    }
                    
                    NavigationLink(destination: ScoreboardView(gameManager: gameManager)) {
                        MenuButton(title: "Scoreboard", color: .blue, icon: "🏆")
                    }
                }
                .padding()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            isAnimating = true
            SoundManager.shared.playBackgroundMusic()
        }
    }
}

// Renamed from GameButton to MenuButton to avoid confusion
struct MenuButton: View {
    let title: String
    let color: Color
    let icon: String
    @State private var isPressed = false
    @State private var isHovering = false
    
    var body: some View {
        HStack(spacing: 15) {
            Text(icon)
                .font(.system(size: 30))
            
            Text(title)
                .font(.custom("Arial Rounded MT Bold", size: 24))
                .foregroundColor(.white)
        }
        .frame(width: 280, height: 70)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(color)
                .shadow(radius: 5)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.5), lineWidth: 2)
                )
        )
        .scaleEffect(isPressed ? 0.95 : isHovering ? 1.05 : 1.0)
        .onHover { hovering in
            withAnimation(.spring()) {
                isHovering = hovering
            }
        }
        .onTapGesture {
            withAnimation(.spring()) {
                isPressed.toggle()
                SoundManager.shared.playButtonSound()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
            }
        }
    }
}
