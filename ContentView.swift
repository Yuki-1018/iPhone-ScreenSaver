import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var player: AVPlayer?
    @State private var videoURLs: [URL] = []
    @State private var currentIndex: Int = 0
    @State private var isFullscreen = false
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        GeometryReader { geometry in
            VideoPlayerView(player: player, isFullscreen: isFullscreen)
                .frame(width: geometry.size.width, height: geometry.size.height)
                .edgesIgnoringSafeArea(.all)
                .gesture(
                    DragGesture().onEnded { value in
                        if value.translation.width < -50 {
                            nextVideo()
                        } else if value.translation.width > 50 {
                            prevVideo()
                        }
                    }
                )
                .simultaneousGesture(
                    MagnificationGesture(minimumScaleDelta: 0.01)
                        .onEnded { _ in
                            withAnimation {
                                isFullscreen.toggle()
                            }
                        }
                )
                .simultaneousGesture(
                    TapGesture()
                        .onEnded {
                            moveToHomeScreen()
                        }
                )
                .onAppear {
                    loadVideos()
                }
                .onChange(of: scenePhase) { newPhase in
                    if newPhase == .active {
                        restartPlayback()
                    } else if newPhase == .background {
                        player?.pause()
                    }
                }
        }
    }

    /// `Documents/Videos` フォルダの動画を取得
    private func loadVideos() {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let videosFolder = documentsURL.appendingPathComponent("Videos", isDirectory: true)

        if !fileManager.fileExists(atPath: videosFolder.path) {
            do {
                try fileManager.createDirectory(at: videosFolder, withIntermediateDirectories: true)
            } catch {
                fatalError("Videos フォルダの作成に失敗: \(error)")
            }
        }

        do {
            let files = try fileManager.contentsOfDirectory(at: videosFolder, includingPropertiesForKeys: nil)
            videoURLs = files.sorted { $0.lastPathComponent < $1.lastPathComponent }

            if videoURLs.isEmpty {
                fatalError("Videos フォルダに動画がありません。アプリを終了します。")
            }

            if let savedIndex = UserDefaults.standard.value(forKey: "lastVideoIndex") as? Int, savedIndex < videoURLs.count {
                currentIndex = savedIndex
            } else {
                currentIndex = 0
            }

            playCurrentVideo()
        } catch {
            fatalError("動画リストの取得に失敗: \(error)")
        }
    }

    /// 現在の動画を再生
    private func playCurrentVideo() {
        guard videoURLs.indices.contains(currentIndex) else { return }
        let playerItem = AVPlayerItem(url: videoURLs[currentIndex])
        if player == nil {
            player = AVPlayer(playerItem: playerItem)
        } else {
            player?.replaceCurrentItem(with: playerItem)
        }
        player?.actionAtItemEnd = .none
        player?.play()

        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem,
            queue: .main
        ) { _ in
            self.nextVideo()
        }

        UserDefaults.standard.setValue(currentIndex, forKey: "lastVideoIndex")
    }

    /// アプリがアクティブになったときに再生を再開
    private func restartPlayback() {
        if let player = player, player.currentItem == nil {
            playCurrentVideo()
        }
        player?.play()
    }

    /// 次の動画へ（最後なら最初に戻る）
    private func nextVideo() {
        currentIndex = (currentIndex + 1) % videoURLs.count
        playCurrentVideo()
    }

    /// 前の動画へ（最初なら最後に戻る）
    private func prevVideo() {
        currentIndex = (currentIndex - 1 + videoURLs.count) % videoURLs.count
        playCurrentVideo()
    }

    /// ホーム画面へ移動
    private func moveToHomeScreen() {
        UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
    }
}
