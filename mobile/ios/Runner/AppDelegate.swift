import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller = window?.rootViewController as! FlutterViewController
    let blockingChannel = FlutterMethodChannel(
      name: "com.kidtime.app/blocking",
      binaryMessenger: controller.binaryMessenger
    )

    blockingChannel.setMethodCallHandler { (call, result) in
      if call.method == "syncBlockedApps" {
        result(true)
      } else if call.method == "setBlockingEnabled" {
        result(true)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
