import 'dart:async';
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
  int _selectedLockMinutes = 30;

  final List<Map<String, String>> _appPresets = [
    {'name': 'Trình duyệt Safari (iOS) 🧭', 'package': 'com.apple.mobilesafari', 'category': 'Duyệt web (iOS System)'},
    {'name': 'Ứng dụng Ảnh (iOS Photos) 🖼️', 'package': 'com.apple.mobileslideshow', 'category': 'Hệ thống iOS'},
    {'name': 'YouTube 🔴', 'package': 'com.google.android.youtube', 'category': 'Video & Giải trí'},
    {'name': 'TikTok 🎵', 'package': 'com.zhiliaoapp.musically', 'category': 'Mạng xã hội'},
    {'name': 'Roblox 🎮', 'package': 'com.roblox.client', 'category': 'Trò chơi'},
    {'name': 'Facebook 📘', 'package': 'com.facebook.katana', 'category': 'Mạng xã hội'},
    {'name': 'Trình duyệt Chrome 🌐', 'package': 'com.android.chrome', 'category': 'Duyệt web'},
  ];

  late final Set<String> _selectedPackages;

  @override
  void initState() {
    super.initState();
    _apiClient = widget.apiClient ?? ApiClient();
    _blockingService = widget.blockingService ?? AppBlockingService();
    _selectedPackages = {
      'com.apple.mobilesafari',
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
            const SizedBox(height: 16),

            // Timed Phone Lock Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.hourglass_top_rounded, color: Colors.deepOrange, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Khóa Điện Thoại Theo Số Phút ⏳',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Khóa màn hình máy X phút khi hết giờ xem hoặc phạt tạm thời',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [15, 30, 45, 60].map((mins) {
                        final isSel = _selectedLockMinutes == mins;
                        return ChoiceChip(
                          label: Text('$mins phút'),
                          selected: isSel,
                          selectedColor: Colors.deepOrange,
                          labelStyle: TextStyle(
                            color: isSel ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                          onSelected: (val) {
                            if (val) setState(() => _selectedLockMinutes = mins);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _startTimedLock(context, _selectedLockMinutes),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.shade800,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.lock_clock_rounded),
                        label: Text('🔒 Bắt Đầu Khóa Máy $_selectedLockMinutes Phút Ngay', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
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
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _showDemoShieldDialog(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Colors.deepOrange),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: const Icon(Icons.visibility_rounded, color: Colors.deepOrange),
              label: const Text('🧪 Xem thử Màn hình Khóa Bố Mẹ (Demo)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
            ),
          ],
        ),
      ),
    );
  }

  void _showDemoShieldDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog.fullscreen(
        child: Container(
          color: const Color(0xFF1E1E2C),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_rounded, size: 72, color: Colors.redAccent),
              ),
              const SizedBox(height: 24),
              const Text(
                '🛡️ ỨNG DỤNG ĐÃ BỊ KHÓA!',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Trình duyệt Safari (com.apple.mobilesafari) đã bị Bố Mẹ tạm thời khóa do chưa hoàn thành nhiệm vụ.',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D2D44),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: const [
                    Text('⭐', style: TextStyle(fontSize: 24)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Con hãy tích lũy thêm 10 Sao hoặc hoàn thành bài hôm nay để mở lại app nhé!',
                        style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(ctx).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.check_circle_rounded),
                label: const Text('Bố Mẹ Nhập PIN Mở Khóa Tạm Thời', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startTimedLock(BuildContext context, int minutes) {
    int remaining = minutes * 60;
    Timer? countdownTimer;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            countdownTimer ??= Timer.periodic(const Duration(seconds: 1), (timer) {
              if (remaining > 0) {
                setDialogState(() => remaining--);
              } else {
                timer.cancel();
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🎉 Hết thời gian khóa máy! Điện thoại đã mở lại.'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            });

            final minsStr = (remaining ~/ 60).toString().padLeft(2, '0');
            final secsStr = (remaining % 60).toString().padLeft(2, '0');

            return Dialog.fullscreen(
              child: Container(
                color: const Color(0xFF181824),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.hourglass_bottom_rounded, size: 72, color: Colors.amber),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      '⏳ ĐIỆN THOẠI ĐANG TRONG THỜI GIAN KHÓA',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Bố Mẹ đã khóa máy $minutes phút. Hãy nghỉ ngơi hoặc làm bài nhé!',
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    Text(
                      '$minsStr:$secsStr',
                      style: const TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.w900,
                        color: Colors.amber,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 36),
                    ElevatedButton.icon(
                      onPressed: () {
                        final pinCtrl = TextEditingController();
                        showDialog(
                          context: ctx,
                          builder: (pinCtx) => AlertDialog(
                            title: const Text('Nhập PIN Bố Mẹ để Mở Khóa'),
                            content: TextField(
                              controller: pinCtrl,
                              keyboardType: TextInputType.number,
                              obscureText: true,
                              decoration: const InputDecoration(hintText: 'Mặc định: 1234'),
                            ),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(pinCtx), child: const Text('Hủy')),
                              ElevatedButton(
                                onPressed: () {
                                  if (pinCtrl.text == '1234') {
                                    countdownTimer?.cancel();
                                    Navigator.pop(pinCtx);
                                    Navigator.pop(ctx);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('🔓 Bố Mẹ đã mở khóa điện thoại sớm!'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(pinCtx).showSnackBar(
                                      const SnackBar(content: Text('❌ Mã PIN không đúng (Gợi ý: 1234)'), backgroundColor: Colors.red),
                                    );
                                  }
                                },
                                child: const Text('Xác nhận'),
                              ),
                            ],
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.pin_rounded),
                      label: const Text('Mở Khóa Sớm (Dành cho Bố Mẹ)', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
