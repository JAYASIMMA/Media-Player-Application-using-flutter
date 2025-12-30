# Nothing Player

**Pure Audio. Zero Distractions.**

Nothing Player is a minimalist, high-performance media player application built with Flutter. Inspired by the **Nothing OS** design language, it features a striking monochrome aesthetic with signature red accents, dot-matrix typography (`Ndot57`), and intuitive gesture-based controls.

## 📱 Features

* **Nothing OS Aesthetic**:
  * Signature Dot Matrix (Ndot57) typography.
  * Strict Black/White/Red color palette.
  * Retro-futuristic UI elements.
* **Unified Media Library**:
  * Automatically scans and organizes Audio and Video files.
  * Categorized views: Albums, Folders, Videos, Favorites.
* **Smart Playback**:
  * **Instant Launch**: Optimized startup with 0s latency.
  * **Gesture Controls**: Swipe for volume/brightness, pinch to zoom.
  * **Background Playback**: Seamless audio listening while multitasking.
* **Playlist Management**:
  * Create custom playlists.
  * "Favorites" quick access.
* **Welcome Experience**:
  * One-time introductory onboarding for new users.

## 🛠 Tech Stack

* **Framework**: Flutter (Dart)
* **State Management**: Provider
* **Audio Engine**: `just_audio` + `audio_service` (Background support)
* **Video Engine**: `video_player` + `chewie`
* **Data Persistence**: `shared_preferences`
* **Permissions**: `permission_handler`

## 📥 Installation

### Prerequisites

* Android 7.0 (Nougat, API 24) or higher.

### Install via APK

1. Download the latest `app-release.apk`.
2. Enable "Install from Unknown Sources" in your device settings.
3. Tap the APK file to install.

### Build from Source

1. Clone the repository:

    ```bash
    git clone https://github.com/JAYASIMMA/Media-Player-Application-using-flutter.git
    ```

2. Install dependencies:

    ```bash
    flutter pub get
    ```

3. Run on device:

    ```bash
    flutter run --release
    ```

## 🎨 Design Philosophy

> "Technology should be intuitive, not intrusive."

Nothing Player strips away the clutter of traditional media players. No ads, no complex menus, no colorful distractions—just you and your media.

* **Font**: Custom integrated `Ndot57` (Ndot 57 Aligned.ttf).
* **Icons**: Material Symbols Outlined.

## 🤝 Contact & Support

Developed by **Jayasimma D**.

* **Website**: [https://github.com/JAYASIMMA/](https://github.com/JAYASIMMA/)
* **Email**: <jayasimma1@gmail.com>
* **Copyright**: © 2025 Jayasimma D. All Rights Reserved.

---
*Built with ❤️ and Flutter.*
