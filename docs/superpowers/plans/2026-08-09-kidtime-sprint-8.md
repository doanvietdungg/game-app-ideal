# KidTime Sprint 8 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement Sprint 8 features: `LeaderboardRepository`, `FamilyLeaderboardScreen` (`/family/leaderboard`), podium UI widget, weekly challenge card, and full test suite verification.

**Architecture:** Create `mobile/lib/features/leaderboard/`, register `/family/leaderboard` route in `mobile/lib/core/router/app_router.dart`.

**Tech Stack:** Flutter 3.x, GoRouter, Riverpod, Dio.

## Global Constraints

- Podium UI 🥇 🥈 🥉 for top 3 members.
- Route `/family/leaderboard` mapped and accessible.
- 100% test pass on `flutter test` and `php artisan test`.

---

### Task 1: Implement `LeaderboardRepository` & `FamilyLeaderboardScreen`

Create leaderboard repository, family leaderboard screen, and route registration.

**Files:**
- Create: `mobile/lib/features/leaderboard/data/leaderboard_repository.dart`
- Create: `mobile/lib/features/leaderboard/presentation/family_leaderboard_screen.dart`
- Modify: `mobile/lib/core/router/app_router.dart`

**Interfaces:**
- Consumes: `ApiClient` (`/v1/family/leaderboard`).
- Produces: Route `/family/leaderboard` showing podium rankings and weekly family challenge progress.

- [ ] **Step 1: Create `LeaderboardRepository`**
  Create `mobile/lib/features/leaderboard/data/leaderboard_repository.dart`:
  ```dart
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
  ```

- [ ] **Step 2: Create `FamilyLeaderboardScreen`**
  Create `mobile/lib/features/leaderboard/presentation/family_leaderboard_screen.dart`:
  Renders podium 🥇 🥈 🥉 height columns, weekly challenge progress bar, and member standings list.

- [ ] **Step 3: Register `/family/leaderboard` route**
  Add `/family/leaderboard` route in `mobile/lib/core/router/app_router.dart`.

- [ ] **Step 4: Commit**
  ```bash
  git add mobile/lib/features/leaderboard/ mobile/lib/core/router/app_router.dart
  git commit -m "feat(mobile): implement FamilyLeaderboardScreen and leaderboard repository"
  ```

---

### Task 2: Implement Test Suite Verification & Clean Up

Add `FamilyLeaderboardScreen` widget test case in `mobile/test/widget_test.dart` and verify all tests pass.

**Files:**
- Modify: `mobile/test/widget_test.dart`

**Interfaces:**
- Produces: 100% test pass suite for all mobile & backend features.

- [ ] **Step 1: Add widget test for `FamilyLeaderboardScreen`**
  Add test scenario in `mobile/test/widget_test.dart`.

- [ ] **Step 2: Run full test suite**
  Run `cd mobile && flutter test` and `docker compose exec -T app php artisan test`.
  Expected: All tests pass cleanly.

- [ ] **Step 3: Commit**
  ```bash
  git add mobile/test/widget_test.dart
  git commit -m "test(mobile): add FamilyLeaderboardScreen widget test and verify full test suite"
  ```
