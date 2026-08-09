import 'package:flutter/services.dart';

class AppBlockingService {
  static const MethodChannel _channel = MethodChannel('com.kidtime.app/blocking');

  Future<bool> syncBlockedApps(List<String> packageNames) async {
    try {
      final result = await _channel.invokeMethod<bool>('syncBlockedApps', {
        'packages': packageNames,
      });
      return result ?? true;
    } on MissingPluginException catch (_) {
      // Safe fallback for desktop / simulator / test environments
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> setBlockingEnabled(bool enabled) async {
    try {
      final result = await _channel.invokeMethod<bool>('setBlockingEnabled', {
        'enabled': enabled,
      });
      return result ?? true;
    } on MissingPluginException catch (_) {
      return true;
    } catch (_) {
      return false;
    }
  }
}
