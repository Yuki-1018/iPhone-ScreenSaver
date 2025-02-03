import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var player: AVPlayer?
    @State private var videoURLs: [URL] = []
    @State private var currentIndex: Int = 0
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        GeometryReader { geometry in
            VideoPlayerView(player: player)
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
                .onTapGesture {
                    moveToHomeScreen()
                }
                .onAppear {
                    loadVideos()
                }
                .onChange(of: scenePhase) { newPhase in
                    if newPhase == .active {
                        player?.play()
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

        // `Videos` フォルダがなければ作成
        if !fileManager.fileExists(atPath: videosFolder.path) {
            do {
                try fileManager.createDirectory(at: videosFolder, withIntermediateDirectories: true)
            } catch {
                fatalError("Videos フォルダの作成に失敗: \(error)")
            }
        }

        do {
            let files = try fileManager.contentsOfDirectory(at: videosFolder, includingPropertiesForKeys: nil)
            videoURLs = files.filter { $0.pathExtension.lowercased() == "mp4" || $0.pathExtension.lowercased() == "mov" }
                .sorted { $0.lastPathComponent < $1.lastPathComponent }

            // 動画がない場合はアプリを強制終了
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
        player = AVPlayer(url: videoURLs[currentIndex])
        player?.actionAtItemEnd = .none

        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill // 画面いっぱいに表示（アスペクト比維持）
        
        player?.play()

        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem,
            queue: .main
        ) { _ in
            player?.seek(to: .zero)
            player?.play()
        }

        UserDefaults.standard.setValue(currentIndex, forKey: "lastVideoIndex")
    }

    /// 次の動画へ
    private func nextVideo() {
        if currentIndex < videoURLs.count - 1 {
            currentIndex += 1
            playCurrentVideo()
        }
    }

    /// 前の動画へ
    private func prevVideo() {
        if currentIndex > 0 {
            currentIndex -= 1
            playCurrentVideo()
        }
    }

    /// ホーム画面へ移動
    private func moveToHomeScreen() {
        UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
    }
}