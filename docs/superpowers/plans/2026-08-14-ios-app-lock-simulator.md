# iOS Simulator Setup & Swift App Lock Module Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Configure iOS Simulator environment on macOS and implement Swift Native App Lock MethodChannel handler in `AppDelegate.swift` to sync app blocking preferences on iOS.

**Architecture:** Flutter `AppLockSettingsScreen` sends blocked package list and toggle status via MethodChannel `com.kidtime.app/blocking` to `AppDelegate.swift`, which stores preferences in `UserDefaults` and logs native sync state.

**Tech Stack:** Swift, iOS Simulator (`simctl`), CocoaPods, Flutter, Dart.

## Global Constraints
- Target iOS Version: iOS 16.0+
- MethodChannel Name: `com.kidtime.app/blocking`
- Swift File: `mobile/ios/Runner/AppDelegate.swift`

---

### Task 1: Environment & iOS Tooling Setup

**Files:**
- Modify: System configuration (`xcode-select`, CocoaPods)
- Inspect: `mobile/ios/Podfile`

**Interfaces:**
- Consumes: macOS CLI tools (`xcode-select`, `xcrun`, `pod`)
- Produces: Active Xcode developer path and booted iOS Simulator

- [ ] **Step 1: Configure Xcode Developer Directory**

Run command:
```bash
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer 2>/dev/null || xcode-select -p
```
Expected: Output showing developer directory `/Applications/Xcode.app/Contents/Developer` or active command line tools.

- [ ] **Step 2: Check iOS Simulators via `simctl`**

Run command:
```bash
xcrun simctl list devices available
```
Expected: List of available iOS Simulators (e.g. iPhone 16 / iPhone 15).

- [ ] **Step 3: Boot target iOS Simulator**

Run command:
```bash
open -a Simulator || true
```
Expected: iOS Simulator window opens on macOS desktop.

- [ ] **Step 4: Commit setup verification**

```bash
git status
```

---

### Task 2: Implement Swift Native MethodChannel in `AppDelegate.swift`

**Files:**
- Modify: `mobile/ios/Runner/AppDelegate.swift`
- Test: `mobile/test/widget_test.dart`

**Interfaces:**
- Consumes: Flutter `com.kidtime.app/blocking` channel calls (`syncBlockedApps`, `setBlockingEnabled`)
- Produces: `UserDefaults` keys `KidTime_BlockedApps` and `KidTime_BlockingEnabled`

- [ ] **Step 1: Update `AppDelegate.swift` with Swift MethodChannel handler**

```swift
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let channelName = "com.kidtime.app/blocking"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller = window?.rootViewController as! FlutterViewController
    let blockingChannel = FlutterMethodChannel(
      name: channelName,
      binaryMessenger: controller.binaryMessenger
    )

    blockingChannel.setMethodCallHandler { (call, result) in
      switch call.method {
      case "syncBlockedApps":
        if let args = call.arguments as? [String: Any],
           let packages = args["packages"] as? [String] {
          UserDefaults.standard.set(packages, forKey: "KidTime_BlockedApps")
          print("🛡️ [iOS Native] Synced blocked apps: \(packages)")
          result(true)
        } else if let packages = call.arguments as? [String] {
          UserDefaults.standard.set(packages, forKey: "KidTime_BlockedApps")
          print("🛡️ [iOS Native] Synced blocked apps list: \(packages)")
          result(true)
        } else {
          result(true)
        }
      case "setBlockingEnabled":
        if let args = call.arguments as? [String: Any],
           let enabled = args["enabled"] as? Bool {
          UserDefaults.standard.set(enabled, forKey: "KidTime_BlockingEnabled")
          print("🛡️ [iOS Native] App blocking enabled state: \(enabled)")
          result(true)
        } else if let enabled = call.arguments as? Bool {
          UserDefaults.standard.set(enabled, forKey: "KidTime_BlockingEnabled")
          print("🛡️ [iOS Native] App blocking enabled state: \(enabled)")
          result(true)
        } else {
          result(true)
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

- [ ] **Step 2: Run Flutter tests to verify no compilation regressions**

Run command:
```bash
cd mobile && flutter test
```
Expected: 17/17 passed.

- [ ] **Step 3: Commit `AppDelegate.swift` changes**

```bash
git add mobile/ios/Runner/AppDelegate.swift
git commit -m "feat(ios): implement Swift MethodChannel handler for App Lock sync"
```

---

### Task 3: Launch iOS Simulator and Verify Native Execution

**Files:**
- Target: `mobile/`

**Interfaces:**
- Consumes: iOS Simulator device ID
- Produces: Running Flutter app on iOS Simulator

- [ ] **Step 1: Get connected Flutter devices including iOS Simulator**

Run command:
```bash
cd mobile && flutter devices
```
Expected: Device ID for iOS Simulator listed.

- [ ] **Step 2: Run Flutter app on iOS Simulator**

Run command:
```bash
cd mobile && flutter run -d simulator
```
Expected: App launches on iOS Simulator, displays splash screen, navigates smoothly to HomeScreen.

- [ ] **Step 3: Perform interactive test in Parent Remote App Lock Screen**

Navigate to Profile Settings -> Quản lý Khóa App từ xa -> Toggle switch and click "Lưu & Áp Dụng Ngay 🛡️".
Expected: SnackBar shows success, native log outputs `🛡️ [iOS Native] Synced blocked apps`.

- [ ] **Step 4: Commit final verification**

```bash
git status
```
