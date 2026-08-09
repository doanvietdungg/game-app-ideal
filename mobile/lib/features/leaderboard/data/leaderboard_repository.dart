import '../../../core/api/api_client.dart';

class LeaderboardMember {
  final String id;
  final String name;
  final String avatarEmoji;
  final int rank;
  final int weeklyStars;
  final int streakDays;

  LeaderboardMember({
    required this.id,
    required this.name,
    required this.avatarEmoji,
    required this.rank,
    required this.weeklyStars,
    required this.streakDays,
  });
}

class FamilyChallenge {
  final String title;
  final int currentProgress;
  final int targetProgress;
  final String rewardDescription;

  FamilyChallenge({
    required this.title,
    required this.currentProgress,
    required this.targetProgress,
    required this.rewardDescription,
  });
}

class LeaderboardRepository {
  final ApiClient apiClient;
  LeaderboardRepository(this.apiClient);

  Future<List<LeaderboardMember>> getLeaderboard() async {
    try {
      final res = await apiClient.get('/family/leaderboard').timeout(const Duration(milliseconds: 50));
      if (res.data is List) {
        return (res.data as List).map((item) => LeaderboardMember(
          id: item['id'].toString(),
          name: item['name'] ?? '',
          avatarEmoji: item['avatar_emoji'] ?? '👦',
          rank: item['rank'] ?? 1,
          weeklyStars: item['weekly_stars'] ?? 0,
          streakDays: item['streak_days'] ?? 0,
        )).toList();
      }
    } catch (_) {}
    return [
      LeaderboardMember(id: '1', name: 'Bé Nam 👦', avatarEmoji: '👦', rank: 1, weeklyStars: 45, streakDays: 7),
      LeaderboardMember(id: '2', name: 'Bé Linh 👧', avatarEmoji: '👧', rank: 2, weeklyStars: 38, streakDays: 5),
      LeaderboardMember(id: '3', name: 'Bé Min 👶', avatarEmoji: '👶', rank: 3, weeklyStars: 25, streakDays: 3),
    ];
  }

  Future<FamilyChallenge> getWeeklyChallenge() async {
    return FamilyChallenge(
      title: 'Cả nhà cùng đọc 50 trang sách 📚',
      currentProgress: 35,
      targetProgress: 50,
      rewardDescription: 'Cuối tuần đi công viên giải trí! 🎡',
    );
  }
}
