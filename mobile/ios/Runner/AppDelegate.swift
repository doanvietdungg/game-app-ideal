import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
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

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}

