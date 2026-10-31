# SwaprTrans ⚡

<p align="center">
  <b><a href="README.md">简体中文</a></b> | <b>English</b>
</p>

<p align="center">
  <a href="https://www.apple.com/macos/"><img src="https://img.shields.io/badge/platform-macOS%2014.2%2B-lightgrey.svg" alt="Platform"></a>
  <a href="https://swift.org"><img src="https://img.shields.io/badge/language-Swift%206-orange.svg" alt="Language"></a>
  <a href="https://developer.apple.com/xcode/swiftui/"><img src="https://img.shields.io/badge/framework-AppKit%20%7C%20SwiftUI-blue.svg" alt="Framework"></a>
  <a href="https://github.com/linrol/swapr-trans/releases"><img src="https://img.shields.io/badge/binary-Universal%202%20(Intel%20%2B%20M--chip)-success.svg" alt="Universal 2"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-green.svg" alt="License"></a>
</p>

**SwaprTrans** is an ultra-lightweight, native **in-place translation tool** built exclusively for macOS.  
It shatters the traditional friction loop: *"select -> copy -> switch app -> paste -> translate -> copy back -> overwrite"*.

> **🚀 Select & Space to translate, Enter to in-place rewrite!**  
> In any active input box (Teams, Slack, WeChat, email client, browser, or terminal), select any text and hit the default shortcut **`Space`** to summon the instant translation HUD. Tap **`Enter`** once, and your original draft is atomically transformed into fluent, idiomatic target text!

---

## ✨ Key Features

- ** Apple Native On-Device Engine (macOS 15+ Translation.framework)**:
  - **Offline On-Device Inference**: Powered directly by Apple's Neural Engine with zero network reliance;
  - **100% Commercial Privacy**: Confidential chat drafts and emails never leave your machine;
- **Tri-Engine Smart Failover**:
  - **Apple (Native)**: System-level offline translation;
  - **Microsoft Edge**: Ultra-fast keyless direct lane;
  - **Google Translate**: Automated graceful fallback;
- **Bi-directional Language Auto-Detection**: Seamlessly detects Chinese and foreign languages, converting Chinese to English or foreign text to Chinese;
- **⭐ Built-in Vocabulary & Favorites Manager (Powered by SQLite)**:
  - **Instant Star on HUD**: Click the star button in translation popup to bookmark phrases and words;
  - **Dedicated Native Window**: Bidirectional search across source and target text, native TTS pronunciation, and cleanups;
  - **Export to CSV / JSON**: Export all your saved translations with one click into Anki, dictionary apps, or flashcards;
  - **Native SQLite3 Persistence**: Uses macOS built-in `libsqlite3` with WAL journaling—zero external dependencies, ultra-fast and resilient;
- **Non-Activating Liquid Glass HUD**: Floating HUD appears near your cursor without stealing window focus; customizable background opacity (40%~100%) while preserving 100% crisp text contrast;
- **Ultra-lightweight & Universal 2**: Pure Swift + SwiftUI native architecture, runs natively on both Apple Silicon (M1/M2/M3/M4) and Intel Macs;
- **Silent In-Place Auto Update**: Checks releases in the background, updates with one click, and preserves macOS Accessibility trust.

---

## 📦 Use as a Swift Package (SPM)

`SwaprTrans` is not only a standalone menu bar application—its core engine and UI are fully modularized and open-sourced via `SwaprTransKit`. When imported into third-party apps, it defaults to a clean, pure translation tool without baggage:

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/linrol/swapr-trans.git", from: "1.0.2")
],
targets: [
    .target(
        name: "YourApp",
        dependencies: [
            .product(name: "SwaprTransKit", package: "swapr-trans")
        ]
    )
]
```

Usage in your app:
```swift
import SwaprTransKit

// 1. Enable translation engine (defaults to pure translator with zero favorites UI/DB footprint)
SwaprTransConfig.shared.isEnabled = true

// 2. Optionally enable Favorites functionality
SwaprTransConfig.shared.isFavoritesEnabled = true

// 3. Open native favorites window with one line (Optional)
FavoritesWindowController.shared.show()

// 4. Or embed favorites SwiftUI view into your own views (Optional)
FavoritesListView()

// 5. Embed prebuilt settings view in SwiftUI
SwaprTransSettingsView()
```

---

## 📥 Download & Installation

### Option 1: Download Release DMG (Recommended)
Visit the [Releases Page](https://github.com/linrol/swapr-trans/releases) and download the latest `SwaprTrans-x.x.x.dmg`:
1. Open the DMG image;
2. Drag `SwaprTrans.app` into your **`Applications`** folder;
3. **First Launch**: If prompted by macOS Gatekeeper, right-click `SwaprTrans.app` in Finder and click **「Open」**;
4. **Grant Permission**: Grant **Accessibility** permission in System Settings when prompted (required to detect selected text and perform in-place replacement);
5. **Apple Native On-Device Engine Notice**: If using the Apple Native Translation engine (macOS 15+), macOS will prompt you to download the offline language pack on first use. You can also pre-download offline packages in **System Settings → General → Language & Region → Translation Languages**. Once downloaded, it operates 100% offline.

> [!TIP]
> **Updating an existing installation**: If you replace the app manually, toggle SwaprTrans OFF and ON once in **System Settings → Privacy & Security → Accessibility** to refresh macOS permission caching. Or simply use the in-app **Update & Restart** button for seamless upgrades!

---

## 🛠️ Local Development & Build

```bash
# Clone the repository
git clone https://github.com/linrol/swapr-trans.git
cd swapr-trans

# Compile and install directly into /Applications
./scripts/install.sh
```

---

## ⚖️ License
This project is open-sourced under the [MIT License](LICENSE).
