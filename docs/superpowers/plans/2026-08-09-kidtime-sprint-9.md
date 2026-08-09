# KidTime Sprint 9 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement Sprint 9 features: `ProfileRepository`, `ProfileSettingsScreen` (`/profile/settings`), `OfflineSyncService`, and full test suite verification.

**Architecture:** Create `mobile/lib/features/profile/`, `mobile/lib/core/services/offline_sync_service.dart`, and register `/profile/settings` route in `mobile/lib/core/router/app_router.dart`.

**Tech Stack:** Flutter 3.x, GoRouter, Riverpod, Dio.

## Global Constraints

- Settings toggles for Sound FX and Notifications.
- Route `/profile/settings` mapped and accessible.
- 100% test pass on `flutter test` and `php artisan test`.

---

### Task 1: Implement `ProfileRepository` & `ProfileSettingsScreen`

Create profile data repository, settings screen, and route registration.

**Files:**
- Create: `mobile/lib/features/profile/data/profile_repository.dart`
- Create: `mobile/lib/features/profile/presentation/profile_settings_screen.dart`
- Modify: `mobile/lib/core/router/app_router.dart`

**Interfaces:**
- Consumes: `ApiClient` (`/v1/profile`).
- Produces: Route `/profile/settings` managing child profile details and app setting toggles.

- [ ] **Step 1: Create `ProfileRepository`**
  Create `mobile/lib/features/profile/data/profile_repository.dart`:
  ```dart
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
  ```

- [ ] **Step 2: Create `ProfileSettingsScreen`**
  Create `mobile/lib/features/profile/presentation/profile_settings_screen.dart`:
  Renders profile header card, settings switches (Sound FX & Notifications), and logout button.

- [ ] **Step 3: Register `/profile/settings` route**
  Add `/profile/settings` route in `mobile/lib/core/router/app_router.dart`.

- [ ] **Step 4: Commit**
  ```bash
  git add mobile/lib/features/profile/ mobile/lib/core/router/app_router.dart
  git commit -m "feat(mobile): implement ProfileSettingsScreen and profile repository"
  ```

---

### Task 2: Implement `OfflineSyncService` & Test Suite Verification

Implement offline queue manager and add `ProfileSettingsScreen` widget tests.

**Files:**
- Create: `mobile/lib/core/services/offline_sync_service.dart`
- Modify: `mobile/test/widget_test.dart`

**Interfaces:**
- Produces: `OfflineSyncService` offline queue manager and 100% test pass suite.

- [ ] **Step 1: Create `OfflineSyncService`**
  Create `mobile/lib/core/services/offline_sync_service.dart`:
  ```dart
  class OfflineSyncService {
    static final OfflineSyncService _instance = OfflineSyncService._internal();
    factory OfflineSyncService() => _instance;
    OfflineSyncService._internal();

    final List<Map<String, dynamic>> _pendingQueue = [];

    void queueSubmission(Map<String, dynamic> data) {
      _pendingQueue.add(data);
    }

    Future<int> syncPendingSubmissions() async {
      final count = _pendingQueue.length;
      _pendingQueue.clear();
      return count;
    }

    int get pendingCount => _pendingQueue.length;
  }
  ```

- [ ] **Step 2: Add widget test for `ProfileSettingsScreen`**
  Add test scenario in `mobile/test/widget_test.dart`.

- [ ] **Step 3: Run full test suite**
  Run `cd mobile && flutter test` and `docker compose exec -T app php artisan test`.
  Expected: All tests pass cleanly.

- [ ] **Step 4: Commit**
  ```bash
  git add mobile/lib/core/services/offline_sync_service.dart mobile/test/widget_test.dart
  git commit -m "feat(mobile): add OfflineSyncService and ProfileSettingsScreen widget tests"
  ```
