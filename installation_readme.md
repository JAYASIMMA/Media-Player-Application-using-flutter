# Installation Guide

## 🚀 Quick Install (APK)

The easiest way to install **Nothing Player** is using the pre-built APK file.

### Prerequisites

* Android device running **Android 7.0 (Nougat)** or newer.
* "Install from Unknown Sources" permission enabled (if installing from file manager).

### Steps

1. **Transfer the APK**:
    * Copy the `app-release.apk` file to your Android device's internal storage.
    * *Note: If you are the developer, the file is located at:* `build/app/outputs/flutter-apk/app-release.apk`
2. **Locate the File**:
    * Open your file manager app on Android.
    * Navigate to the folder where you copied the APK.
3. **Install**:
    * Tap on `app-release.apk`.
    * If prompted, allow the installation.
    * Tap **Install**.
4. **Launch**:
    * Once installed, tap **Open** or find "Nothing Player" in your app drawer.

---

## 🛠️ Developer Install (Build from Source)

If you want to modify the code or build the app yourself.

### Prerequisites

* [Flutter SDK](https://docs.flutter.dev/get-started/install) (Latest Stable)
* [Android Studio](https://developer.android.com/studio) (with Android SDK Command-line Tools)
* VS Code (Optional, recommended for editing)
* Git

### Steps

1. **Clone the Repository**

    ```bash
    git clone https://github.com/JAYASIMMA/Media-Player-Application-using-flutter.git
    cd Media-Player-Application-using-flutter
    ```

2. **Install Dependencies**

    ```bash
    flutter pub get
    ```

3. **Connect Device**
    * Connect your Android phone via USB.
    * Enable **USB Debugging** in *Settings > Developer Options*.
    * Verify connection:

        ```bash
        flutter devices
        ```

4. **Run the App**

    ```bash
    flutter run --release
    ```

## ❓ Troubleshooting

* **"App not installed" Error**:
  * Ensure you have uninstalled any previous version of the app (especially if signed with a different debug key).
  * Check if you have enough storage space.
* **"Parse Error"**:
  * Your Android version might be lower than 7.0.
* **Build Failures**:
  * Run `flutter clean` and try `flutter run` again.
  * Ensure your Android SDK is up to date via Android Studio.
