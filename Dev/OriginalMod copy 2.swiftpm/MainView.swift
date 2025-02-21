import SwiftUI

struct MainView: View {
    @StateObject private var gameManager = GameManager()
    @State private var isAnimating = false
    @State private var particles: [Particle] = []
    
    // Define our ocean-inspired color scheme
    private let appColors = AppColors.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                // Dynamic particle background
                ZStack {
                    ForEach(particles) { particle in
                        Circle()
                            .fill(particle.color)
                            .frame(width: particle.size, height: particle.size)
                            .position(particle.position)
                            .opacity(particle.opacity)
                    }
                }
                .onAppear {
                    // Initialize particles
                    for _ in 0...80 {
                        particles.append(Particle())
                    }
                    // Start animation
                    withAnimation(.linear(duration: 6).repeatForever(autoreverses: false)) {
                        for i in particles.indices {
                            particles[i].move(in: UIScreen.main.bounds)
                        }
                    }
                }
                
                // Updated gradient overlay with new warm colors
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "FF5E78").opacity(0.4),  // Coral Pink
                        Color(hex: "FF9671").opacity(0.4),  // Peach
                        Color(hex: "FFC75F").opacity(0.4)   // Golden Yellow
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 70) {
                    HStack {
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // Animated title
                    Text("Memory Trainer")
                        .font(.custom("Arial Rounded MT Bold", size: 52))
                        .foregroundColor(.white)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .fill(Color(hex: "FF5E78").opacity(0.8))
                                .shadow(radius: 15)
                        )
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 20)
                    
                    // Updated menu buttons with more engaging design
                    VStack(spacing: 40) {
                        NavigationLink {
                            ClassicModeView(gameManager: gameManager)
                        } label: {
                            FunButton(
                                title: "Classic Mode",
                                emoji: "🎮",
                                color: Color(hex: "FF9671")
                            )
                        }
                        .buttonStyle(InstantNavigationButtonStyle())
                        
                        NavigationLink {
                            NBackModeView(gameManager: gameManager)
                        } label: {
                            FunButton(
                                title: "N-Back Mode",
                                emoji: "🧩",
                                color: Color(hex: "FFC75F")
                            )
                        }
                        .buttonStyle(InstantNavigationButtonStyle())
                        
                        NavigationLink {
                            ScoreboardView(gameManager: gameManager)
                        } label: {
                            FunButton(
                                title: "Scoreboard",
                                emoji: "🏆",
                                color: Color(hex: "FF5E78")
                            )
                        }
                        .buttonStyle(InstantNavigationButtonStyle())
                    }
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 50)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            SoundChecker.checkSoundFiles()
            isAnimating = true
            SoundManager.shared.playBackgroundMusic()
        }
    }
}

// Create a shared color scheme
struct AppColors {
    static let shared = AppColors()
    
    let primary = Color(hex: "023E8A")     // Royal blue - for titles
    let secondary = Color(hex: "00B4D8")   // Bright blue - for classic mode
    let accent = Color(hex: "F9C74F")      // Warm yellow - for n-back mode
    let highlight = Color(hex: "F8961E")   // Orange - for scoreboard
    let backgroundStart = Color(hex: "0077B6")  // Deep blue - gradient start
    let backgroundEnd = Color(hex: "90E0EF")    // Light aqua - gradient end
    
    private init() {}
}

// Add Particle struct for background animation
struct Particle: Identifiable {
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
        // Updated particle colors to match new scheme
        color = [Color(hex: "FF5E78"), Color(hex: "FF9671"), Color(hex: "FFC75F")].randomElement()!
        size = CGFloat.random(in: 3...20)
        opacity = Double.random(in: 0.4...0.8)
    }
    
    mutating func move(in bounds: CGRect) {
        position = CGPoint(
            x: CGFloat.random(in: 0...bounds.width),
            y: CGFloat.random(in: 0...bounds.height)
        )
    }
}

// New kid-friendly button style
struct FunButton: View {
    let title: String
    let emoji: String
    let color: Color
    @State private var isPressed = false
    @State private var wobble = false
    
    var body: some View {
        HStack(spacing: 20) {
            Text(emoji)
                .font(.system(size: 45))
                .rotationEffect(.degrees(wobble ? 15 : -15))
                .animation(
                    Animation.easeInOut(duration: 0.3)
                        .repeatForever(autoreverses: true),
                    value: wobble
                )
            
            Text(title)
                .font(.custom("Arial Rounded MT Bold", size: 32))
                .foregroundColor(.white)
        }
        .frame(width: 340, height: 90)
        .background(
            ZStack {
                // Button shadow
                RoundedRectangle(cornerRadius: 30)
                    .fill(color.opacity(0.5))
                    .offset(y: 6)
                
                // Main button
                RoundedRectangle(cornerRadius: 30)
                    .fill(color)
                    .offset(y: isPressed ? 6 : 0)
                
                // Shine effect
                RoundedRectangle(cornerRadius: 30)
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [
                            .white.opacity(0.5),
                            .clear
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .offset(y: isPressed ? 6 : 0)
            }
        )
        .onAppear { wobble = true }
        .scaleEffect(isPressed ? 0.95 : 1.0)
    }
}

// Add ButtonStyle for instant navigation
struct InstantNavigationButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

// Add Color extension for hex support
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
