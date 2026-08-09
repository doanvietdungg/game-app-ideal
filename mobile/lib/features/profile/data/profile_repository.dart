import '../../../core/api/api_client.dart';

class UserProfile {
  final String id;
  final String name;
  final String avatarEmoji;
  final int age;
  final bool soundFxEnabled;
  final bool notificationsEnabled;

  UserProfile({
    required this.id,
    required this.name,
    required this.avatarEmoji,
    required this.age,
    this.soundFxEnabled = true,
    this.notificationsEnabled = true,
  });
}

class ProfileRepository {
  final ApiClient apiClient;
  ProfileRepository(this.apiClient);

  Future<UserProfile> getProfile() async {
    try {
      final res = await apiClient.get('/profile').timeout(const Duration(milliseconds: 50));
      if (res.data != null) {
        return UserProfile(
          id: res.data['id'].toString(),
          name: res.data['name'] ?? 'Bé Nam',
          avatarEmoji: res.data['avatar_emoji'] ?? '👦',
          age: res.data['age'] ?? 8,
          soundFxEnabled: res.data['sound_fx_enabled'] ?? true,
          notificationsEnabled: res.data['notifications_enabled'] ?? true,
        );
      }
    } catch (_) {}
    return UserProfile(
      id: '1',
      name: 'Bé Nam 👦',
      avatarEmoji: '👦',
      age: 8,
      soundFxEnabled: true,
      notificationsEnabled: true,
    );
  }
}
