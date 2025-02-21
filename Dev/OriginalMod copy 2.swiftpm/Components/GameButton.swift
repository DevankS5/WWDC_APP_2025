import SwiftUI

struct GameButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.title2.bold())
                .padding(.horizontal, 40)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.blue)
                        .shadow(radius: 5)
                )
                .foregroundColor(.white)
        }
    }
}