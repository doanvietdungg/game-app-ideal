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
      await _apiClient.post('/api/v1/blocking/apps', data: {'apps': selectedApps});
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
      // Fallback local app blocking invoke
      await _blockingService.syncBlockedApps(_selectedPackages.toList());
      await _blockingService.setBlockingEnabled(_isLockEnabled);
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
