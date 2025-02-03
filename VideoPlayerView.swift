import SwiftUI
import AVFoundation

struct VideoPlayerView: UIViewRepresentable {
    var player: AVPlayer?
    
    func makeUIView(context: Context) -> UIView {
        return PlayerUIView(player: player)
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let playerLayer = (uiView as? PlayerUIView)?.playerLayer {
            playerLayer.player = player
        }
    }
}

class PlayerUIView: UIView {
    var playerLayer: AVPlayerLayer
    
    init(player: AVPlayer?) {
        self.playerLayer = AVPlayerLayer()
        super.init(frame: .zero)
        
        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspect // アスペクト比を維持
        layer.addSublayer(playerLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}