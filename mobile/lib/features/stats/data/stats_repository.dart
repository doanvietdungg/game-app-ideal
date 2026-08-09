import '../../../core/api/api_client.dart';

class ChildStats {
  final int streakDays;
  final int totalTasksCompleted;
  final int totalStarsEarned;
  final List<int> weeklyStars; // 7 days (Mon-Sun)

  ChildStats({
    required this.streakDays,
    required this.totalTasksCompleted,
    required this.totalStarsEarned,
    required this.weeklyStars,
  });
}

class StatsRepository {
  final ApiClient apiClient;
  StatsRepository(this.apiClient);

  Future<ChildStats> getChildStats() async {
    try {
      final res = await apiClient.get('/analytics/child');
      final data = res.data;
      return ChildStats(
        streakDays: data['streak_days'] ?? 5,
        totalTasksCompleted: data['total_tasks_completed'] ?? 14,
        totalStarsEarned: data['total_stars_earned'] ?? 42,
        weeklyStars: List<int>.from(data['weekly_stars'] ?? [5, 8, 4, 6, 10, 3, 6]),
      );
    } catch (_) {
      return ChildStats(
        streakDays: 5,
        totalTasksCompleted: 14,
        totalStarsEarned: 42,
        weeklyStars: [5, 8, 4, 6, 10, 3, 6],
      );
    }
  }
}
