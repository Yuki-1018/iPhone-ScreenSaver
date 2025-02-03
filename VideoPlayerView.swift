import SwiftUI
import AVFoundation

struct VideoPlayerView: UIViewControllerRepresentable {
    var player: AVPlayer?
    var isFullscreen: Bool

    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = isFullscreen ? .resizeAspectFill : .resizeAspect
        controller.view.layer.addSublayer(playerLayer)

        context.coordinator.playerLayer = playerLayer
        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        context.coordinator.playerLayer?.player = player
        context.coordinator.playerLayer?.videoGravity = isFullscreen ? .resizeAspectFill : .resizeAspect
        context.coordinator.playerLayer?.frame = uiViewController.view.bounds
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        var playerLayer: AVPlayerLayer?
    }
}
