# ScreenSaver Video Player (iPhone)

This is a **fullscreen video player** app for iPhone and iPad that continuously loops video files stored in the **Documents/Videos** folder. It supports **swipe gestures to switch videos** and **remembers the last played video** when reopening the app. The app is designed for a seamless screen saver experience.

## Features

- 📂 **Plays MP4 & MOV videos** from `Documents/Videos`
- 🔄 **Loops videos continuously** without interruption
- 📱 **Full-screen playback** on both iPhone & iPad
- 🎞 **Maintains aspect ratio (no distortion)**
- 🎥 **Swipe left/right to switch videos**
- 🏠 **Tap to return to the home screen**
- ▶ **Automatically resumes playback when reopened**
- ⏸ **Pauses video when in the background**
- ⚠ **Closes the app if no videos are found**

## How It Works

### 📁 **Video Folder**
The app reads videos from:  Documents/Videos
You can manage this folder using the **Files app**.

### 🎞 **Playback Behavior**
- If multiple videos exist, they are sorted alphabetically and played in order.
- When a video ends, it **loops infinitely** until switched.
- The last played video is saved and **resumes on next launch**.

### 🎭 **Gestures**
- **Swipe left** → Next video  
- **Swipe right** → Previous video  
- **Tap screen** → Go to the home screen  

## Installation & Usage

1. **Build & Run** the app on your iPhone/iPad.
2. **Use the Files app** to add `.mp4` or `.mov` videos to `Documents/Videos`.
3. **Open the app** to start playing videos.
4. **Swipe** to switch videos, **tap** to exit.

## Technical Details

- **Built with:** `SwiftUI` + `AVFoundation`
- **Video player:** `AVPlayer` with `AVPlayerLayer`
- **Aspect ratio:** `resizeAspectFill` (fills screen without distortion)
- **State management:** `@Environment(\.scenePhase)`
- **Gesture handling:** `DragGesture()` for swipes
- **Storage:** Uses `UserDefaults` to remember the last played video

## License

This project is licensed under the MIT License.
