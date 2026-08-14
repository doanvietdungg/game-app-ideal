package com.kidtime.mobile

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.kidtime.app/blocking"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "syncBlockedApps" -> {
                    val packages = call.argument<List<String>>("packages")
                    result.success(true)
                }
                "setBlockingEnabled" -> {
                    val enabled = call.argument<Boolean>("enabled")
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
