# Design Spec: iOS Simulator Setup & Swift App Lock Module

**Date**: 2026-08-14  
**Status**: Draft for User Review  
**Topic**: iOS Xcode Setup, iOS Simulator Configuration & Swift Native FamilyControls/ScreenTime Bridge Integration  

---

## 1. Overview & Objectives

Establish a complete iOS development and simulation environment for the KidTime project on macOS. Implement the Swift native App Lock module in `mobile/ios/Runner/AppDelegate.swift` so that parents can toggle remote app blocking and sync restricted app bundle IDs to the iOS Native layer on an iOS Simulator (iPhone 15 / 16).

---

## 2. Architecture & Data Flow

```
[Flutter Parent UI: AppLockSettingsScreen]
       │
       ├─► HTTP POST /api/v1/blocking/apps ──► Laravel Backend (DB: blocked_apps)
       │
       └─► MethodChannel ('com.kidtime.app/blocking') ──► AppBlockingService
                                                                 │
                                                                 ▼
                                                 iOS Native (AppDelegate.swift)
                                                 - syncBlockedApps([bundleIDs])
                                                 - setBlockingEnabled(bool)
                                                 - UserDefaults / Shield Overlay Manager
```

### Key Components:
1. **Environment Setup**:
   - Xcode / Xcode Command Line Tools & iOS Simulator runtime installation.
   - CocoaPods / Flutter iOS engine setup (`flutter doctor`, `pod install`).
2. **Swift Native Implementation (`AppDelegate.swift`)**:
   - FlutterMethodChannel `com.kidtime.app/blocking`.
   - `syncBlockedApps`: Saves restricted bundle IDs (`com.google.ios.youtube`, `com.zhiliaoapp.musically`, etc.) into `UserDefaults(suiteName: "group.com.kidtime.mobile")`.
   - `setBlockingEnabled`: Updates global restriction state and triggers native Swift banner notification / shield simulation.
3. **Flutter Mobile Integration**:
   - Invokes `AppBlockingService` on iOS without crashes.
   - Provides clear visual feedback (SnackBar) when settings are synced to iOS Native.

---

## 3. Tooling & Installation Workflow

1. **Xcode & Xcode Command Line Tools**:
   - Install Xcode and set developer directory: `sudo xcode-select -s /Applications/Xcode.app/Contents/Developer`.
   - Accept Xcode license and run first launch: `sudo xcodebuild -runFirstLaunch`.
2. **iOS Simulator**:
   - Create/Boot iPhone 16 / iPhone 15 simulator via `xcrun simctl`.
3. **CocoaPods & Flutter Dependencies**:
   - Ensure CocoaPods is installed (`brew install cocoapods` or `gem install cocoapods`).
   - Run `pod install` in `mobile/ios/`.

---

## 4. Detailed Component Specification

### 4.1 Swift Native Layer (`AppDelegate.swift`)
```swift
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let channelName = "com.kidtime.app/blocking"
  private var isBlockingEnabled = true
  private var blockedApps: [String] = []

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller = window?.rootViewController as! FlutterViewController
    let blockingChannel = FlutterMethodChannel(
      name: channelName,
      binaryMessenger: controller.binaryMessenger
    )

    blockingChannel.setMethodCallHandler { [weak self] (call, result) in
      guard let self = self else { return }
      
      switch call.method {
      case "syncBlockedApps":
        if let args = call.arguments as? [String: Any],
           let packages = args["packages"] as? [String] {
          self.blockedApps = packages
          UserDefaults.standard.set(packages, forKey: "KidTime_BlockedApps")
          print("🛡️ [iOS Native] Synced blocked apps: \(packages)")
          result(true)
        } else {
          result(FlutterError(code: "INVALID_ARGUMENTS", message: "Packages list required", details: nil))
        }
      case "setBlockingEnabled":
        if let args = call.arguments as? [String: Any],
           let enabled = args["enabled"] as? Bool {
          self.isBlockingEnabled = enabled
          UserDefaults.standard.set(enabled, forKey: "KidTime_BlockingEnabled")
          print("🛡️ [iOS Native] App blocking enabled: \(enabled)")
          result(true)
        } else {
          result(FlutterError(code: "INVALID_ARGUMENTS", message: "Enabled flag required", details: nil))
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

---

## 5. Verification & Testing Plan

1. **Environment Verification**:
   - `flutter doctor` passes iOS toolchain check.
   - `xcrun simctl list devices` shows available iPhone Simulators.
2. **Automated Tests**:
   - `flutter test` in `mobile/` passes 17/17 widget tests cleanly.
3. **Simulator Launch & Native Execution**:
   - Launch app on iOS Simulator (`flutter run -d <simulator-id>`).
   - Open **Quản lý Khóa App từ xa** in Parent Profile Settings.
   - Toggle Master Lock & select apps, click "Lưu & Áp Dụng Ngay".
   - Confirm Swift native logs in console outputting `🛡️ [iOS Native] Synced blocked apps` and `🛡️ [iOS Native] App blocking enabled`.
