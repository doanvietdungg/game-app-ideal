import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../data/profile_repository.dart';

class ProfileSettingsScreen extends StatefulWidget {
  final ApiClient? apiClient;
  const ProfileSettingsScreen({super.key, this.apiClient});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  late final ProfileRepository _repository;
  UserProfile? _profile;
  bool _isLoading = true;
  bool _soundFx = true;
  bool _notifications = true;

  @override
  void initState() {
    super.initState();
    _repository = ProfileRepository(widget.apiClient ?? ApiClient());
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final data = await _repository.getProfile();
    if (mounted) {
      setState(() {
        _profile = data;
        _soundFx = data.soundFxEnabled;
        _notifications = data.notificationsEnabled;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Cài Đặt & Hồ Sơ ⚙️'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile Card
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundColor: Colors.amber.shade100,
                            child: Text(_profile?.avatarEmoji ?? '👦', style: const TextStyle(fontSize: 36)),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_profile?.name ?? 'Bé Nam', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text('${_profile?.age ?? 8} tuổi · Thành viên KidTime Star', style: const TextStyle(color: Colors.black54)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // App Settings Options
                  const Text('TÙY CHỈNH ỨNG DỤNG', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                  const SizedBox(height: 12),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: const Text('Âm thanh hiệu ứng (Sound FX)', style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: const Text('Tiếng ăn ngon 🍖, tiếng pháo hoa ăn mừng 🎺'),
                          value: _soundFx,
                          secondary: const Text('🔊', style: TextStyle(fontSize: 24)),
                          onChanged: (val) => setState(() => _soundFx = val),
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          title: const Text('Thông báo nhắc nhở', style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: const Text('Nhắc nhở làm bài 08:00 & cho Mimi ăn 17:00'),
                          value: _notifications,
                          secondary: const Text('🔔', style: TextStyle(fontSize: 24)),
                          onChanged: (val) => setState(() => _notifications = val),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Account & Navigation Card
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      leading: const Text('👨‍👩‍👧', style: TextStyle(fontSize: 24)),
                      title: const Text('Đổi vai trò tài khoản', style: TextStyle(fontWeight: FontWeight.bold)),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                      onTap: () => context.go('/role-selection'),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // App Version Info
                  const Center(
                    child: Text('KidTime App v1.0.0 · Dual Approval Enabled', style: TextStyle(color: Colors.black38, fontSize: 12)),
                  ),
                ],
              ),
            ),
    );
  }
}
