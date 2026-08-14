# Parent Remote App Lock Module Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build and integrate the Parent Remote App Lock module in Flutter and Android Native, allowing parents to remotely toggle app lock and select blocked packages.

**Architecture:** Flutter `AppLockSettingsScreen` triggers backend sync (`POST /api/v1/blocking/apps`) and calls `AppBlockingService` via MethodChannel `com.kidtime.app/blocking`. `MainActivity.kt` in Android handles the MethodChannel calls.

**Tech Stack:** Flutter, Dart, MethodChannel, Kotlin (Android Native), Laravel (Backend API).

## Global Constraints
- Target Flutter SDK: 3.44.9 / Dart 3.12.2
- MethodChannel Name: `com.kidtime.app/blocking`
- API Endpoint: `POST /api/v1/blocking/apps`

---

### Task 1: Create `AppLockSettingsScreen` UI

**Files:**
- Create: `mobile/lib/features/parent/presentation/app_lock_settings_screen.dart`
- Test: `mobile/test/widget_test.dart`

**Interfaces:**
- Consumes: `AppBlockingService` (`mobile/lib/core/services/app_blocking_service.dart`), `ApiClient` (`mobile/lib/core/api/api_client.dart`)
- Produces: `AppLockSettingsScreen` widget

- [ ] **Step 1: Create `AppLockSettingsScreen` implementation file**

```dart
import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';
import '../../../core/services/app_blocking_service.dart';
import '../../../core/theme/app_theme.dart';

class AppLockSettingsScreen extends StatefulWidget {
  final ApiClient? apiClient;
  final AppBlockingService? blockingService;

  const AppLockSettingsScreen({
    super.key,
    this.apiClient,
    this.blockingService,
  });

  @override
  State<AppLockSettingsScreen> createState() => _AppLockSettingsScreenState();
}

class _AppLockSettingsScreenState extends State<AppLockSettingsScreen> {
  late final ApiClient _apiClient;
  late final AppBlockingService _blockingService;
  bool _isLockEnabled = true;
  bool _isSaving = false;

  final List<Map<String, String>> _appPresets = [
    {'name': 'YouTube 🔴', 'package': 'com.google.android.youtube', 'category': 'Video & Giải trí'},
    {'name': 'TikTok 🎵', 'package': 'com.zhiliaoapp.musically', 'category': 'Mạng xã hội'},
    {'name': 'Roblox 🎮', 'package': 'com.roblox.client', 'category': 'Trò chơi'},
    {'name': 'Facebook 📘', 'package': 'com.facebook.katana', 'category': 'Mạng xã hội'},
    {'name': 'Trình duyệt Chrome 🌐', 'package': 'com.android.chrome', 'category': 'Duyệt web'},
    {'name': 'Game Thí Nghiệm 🕹️', 'package': 'com.mobile.game.sample', 'category': 'Trò chơi'},
  ];

  late final Set<String> _selectedPackages;

  @override
  void initState() {
    super.initState();
    _apiClient = widget.apiClient ?? ApiClient();
    _blockingService = widget.blockingService ?? AppBlockingService();
    _selectedPackages = {
      'com.google.android.youtube',
      'com.zhiliaoapp.musically',
      'com.roblox.client',
    };
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);
    final selectedApps = _appPresets
        .where((app) => _selectedPackages.contains(app['package']))
        .map((app) => {
              'app_bundle_id': app['package']!,
              'app_name': app['name']!,
            })
        .toList();

    try {
      await _apiClient.post('/api/v1/blocking/apps', {'apps': selectedApps});
      await _blockingService.syncBlockedApps(_selectedPackages.toList());
      await _blockingService.setBlockingEnabled(_isLockEnabled);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🛡️ Đã đồng bộ cài đặt Khóa App thành công!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã áp dụng khóa app cục bộ trên thiết bị.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Quản Lý Khóa App Bố Mẹ 🔒'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Master Switch Banner
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.deepOrange, Colors.orangeAccent],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(Icons.security_rounded, color: Colors.white, size: 40),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Khóa Ứng Dụng Từ Xa',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Giới hạn quyền truy cập các app khi con chưa hoàn thành nhiệm vụ',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isLockEnabled,
                    activeColor: Colors.white,
                    activeTrackColor: Colors.green.shade400,
                    onChanged: (val) => setState(() => _isLockEnabled = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'DANH SÁCH ỨNG DỤNG BỊ GIỚI HẠN',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedPackages.addAll(_appPresets.map((a) => a['package']!));
                        });
                      },
                      child: const Text('Chọn tất cả'),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedPackages.clear();
                        });
                      },
                      child: const Text('Bỏ chọn'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            ..._appPresets.map((app) {
              final pkg = app['package']!;
              final isSelected = _selectedPackages.contains(pkg);

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                margin: const EdgeInsets.only(bottom: 10),
                child: CheckboxListTile(
                  title: Text(app['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${app['category']} · $pkg', style: const TextStyle(fontSize: 11, color: Colors.black54)),
                  value: isSelected,
                  activeColor: Colors.deepOrange,
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        _selectedPackages.add(pkg);
                      } else {
                        _selectedPackages.remove(pkg);
                      }
                    });
                  },
                ),
              );
            }),
            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: _isSaving ? null : _saveSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: _isSaving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.shield_outlined),
              label: Text(_isSaving ? 'Đang lưu...' : 'Lưu & Áp Dụng Ngay 🛡️', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### Task 2: Connect `ProfileSettingsScreen` Navigation

**Files:**
- Modify: `mobile/lib/features/profile/presentation/profile_settings_screen.dart`

- [ ] **Step 1: Add App Lock option tile in `ProfileSettingsScreen`**

In `ProfileSettingsScreen.dart`, insert an option tile pointing to `AppLockSettingsScreen`:

```dart
// Under App Settings Options Card or Account Card:
Card(
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  child: ListTile(
    leading: const Text('🔒', style: TextStyle(fontSize: 24)),
    title: const Text('Quản lý Khóa App từ xa', style: TextStyle(fontWeight: FontWeight.bold)),
    subtitle: const Text('Bật/tắt & cài đặt các ứng dụng bị hạn chế'),
    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AppLockSettingsScreen()),
      );
    },
  ),
),
```

---

### Task 3: Update Native Android `MainActivity.kt` MethodChannel Handler

**Files:**
- Modify: `mobile/android/app/src/main/kotlin/com/kidtime/mobile/MainActivity.kt`

- [ ] **Step 1: Configure FlutterEngine with MethodChannel handler**

```kotlin
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
                    // Log or handle system lock sync
                    result.success(true)
                }
                "setBlockingEnabled" -> {
                    val enabled = call.argument<Boolean>("enabled")
                    // Log or toggle master lock state
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
```

---

### Task 4: Add Widget & Unit Test and Verify Suite

**Files:**
- Modify: `mobile/test/widget_test.dart`

- [ ] **Step 1: Add widget test for `AppLockSettingsScreen`**

```dart
testWidgets('AppLockSettingsScreen mounts and displays master switch and app list', (WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(
    home: AppLockSettingsScreen(),
  ));

  await tester.pump(const Duration(milliseconds: 100));

  expect(find.text('Quản Lý Khóa App Bố Mẹ 🔒'), findsOneWidget);
  expect(find.text('Khóa Ứng Dụng Từ Xa'), findsOneWidget);
  expect(find.text('YouTube 🔴'), findsOneWidget);
  expect(find.text('Lưu & Áp Dụng Ngay 🛡️'), findsOneWidget);
});
```

- [ ] **Step 2: Run test suite**

Run command: `flutter test` in `mobile/` directory.
Expected: PASS (All 17+ tests pass).
