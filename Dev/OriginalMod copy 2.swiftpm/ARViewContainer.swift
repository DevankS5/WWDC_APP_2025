import SwiftUI
import RealityKit
import ARKit

struct ARViewContainer: UIViewRepresentable {
    @Binding var isARMode: Bool
    var cards: [Card]
    var onCardTap: (Card) -> Void
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        // Configure AR session
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        config.environmentTexturing = .automatic
        
        // Add coaching overlay
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        coachingOverlay.session = arView.session
        coachingOverlay.goal = .horizontalPlane
        arView.addSubview(coachingOverlay)
        
        // Start AR session
        arView.session.run(config)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        guard isARMode else { return }
        
        // Clear existing anchors
        uiView.scene.anchors.removeAll()
        
        // Create root anchor
        let anchor = AnchorEntity()
        uiView.scene.addAnchor(anchor)
        
        // Add cards with simplified positioning
        for (index, card) in cards.enumerated() {
            let cardEntity = createCardEntity(for: card)
            
            // Position cards in a circular formation
            let angle = Float(index) * (2 * .pi / Float(cards.count))
            let radius: Float = 0.5
            let x = radius * cos(angle)
            let z = radius * sin(angle)
            let y: Float = 0.3 // Height above the plane
            
            cardEntity.position = SIMD3<Float>(x, y, z)
            cardEntity.look(at: SIMD3<Float>(0, y, 0), from: cardEntity.position, relativeTo: nil)
            
            anchor.addChild(cardEntity)
        }
    }
    
    private func createCardEntity(for card: Card) -> ModelEntity {
        // Create card mesh
        let cardMesh = MeshResource.generatePlane(width: 0.1, height: 0.15)
        let cardMaterial = SimpleMaterial(color: .white, isMetallic: false)
        let cardEntity = ModelEntity(mesh: cardMesh, materials: [cardMaterial])
        
        return cardEntity
    }
    
    static func dismantleUIView(_ uiView: ARView, coordinator: ()) {
        // Proper cleanup
        uiView.session.pause()
        uiView.removeFromSuperview()
    }
}
