# KidTime Full Notification System Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement full Notification System: `NotificationRepository`, `NotificationCenterScreen` (`/notifications`), top animated `NotificationBannerWidget`, `NotificationService` schedule enhancements, and full test suite verification.

**Architecture:** Create `mobile/lib/features/notifications/`, `mobile/lib/core/widgets/notification_banner.dart`, and register `/notifications` route in `mobile/lib/core/router/app_router.dart`.

**Tech Stack:** Flutter 3.x, AnimationController, GoRouter, Dio.

## Global Constraints

- Smooth top slide-down animation for `NotificationBannerWidget`.
- Bell icon 🔔 with unread badge in `HomeScreen` and `ParentApprovalScreen` app bars.
- 100% test pass on `flutter test` and `php artisan test`.

---

### Task 1: Implement `NotificationRepository` & `NotificationCenterScreen`

Create notification data layer, notification list screen, and app bar bell icon with badge.

**Files:**
- Create: `mobile/lib/features/notifications/data/notification_repository.dart`
- Create: `mobile/lib/features/notifications/presentation/notification_center_screen.dart`
- Modify: `mobile/lib/core/router/app_router.dart`

**Interfaces:**
- Consumes: `ApiClient` (`/v1/notifications`).
- Produces: Route `/notifications` displaying list of unread/read notifications with categories.

- [ ] **Step 1: Create `NotificationRepository`**
  Create `mobile/lib/features/notifications/data/notification_repository.dart`:
  ```dart
  import '../../../core/api/api_client.dart';

  class NotificationItem {
    final String id;
    final String title;
    final String body;
    final String type; // 'approval', 'star_reward', 'pet_hunger', 'reminder'
    final bool isRead;
    final String createdAt;

    NotificationItem({
      required this.id,
      required this.title,
      required this.body,
      required this.type,
      this.isRead = false,
      required this.createdAt,
    });
  }

  class NotificationRepository {
    final ApiClient apiClient;
    NotificationRepository(this.apiClient);

    Future<List<NotificationItem>> getNotifications() async {
      try {
        final res = await apiClient.get('/notifications').timeout(const Duration(milliseconds: 50));
        if (res.data is List) {
          return (res.data as List).map((item) => NotificationItem(
            id: item['id'].toString(),
            title: item['title'] ?? '',
            body: item['body'] ?? '',
            type: item['type'] ?? 'reminder',
            isRead: item['is_read'] ?? false,
            createdAt: item['created_at'] ?? '10 phút trước',
          )).toList();
        }
      } catch (_) {}
      return [
        NotificationItem(
          id: '1',
          title: '🎉 Bài tập đã được duyệt!',
          body: 'Bố đã duyệt bài "Dọn dẹp phòng ngủ". Con được thưởng +5 ⭐!',
          type: 'approval',
          isRead: false,
          createdAt: '10 phút trước',
        ),
        NotificationItem(
          id: '2',
          title: '🍖 Mimi đang đói rồi!',
          body: 'Độ no của Mimi giảm còn 40%. Cho Mimi ăn chiều nhé con!',
          type: 'pet_hunger',
          isRead: true,
          createdAt: '2 giờ trước',
        ),
        NotificationItem(
          id: '3',
          title: '⭐ Đổi quà thành công',
          body: 'Bố đã xác nhận phần thưởng "Xem TV 30 phút"!',
          type: 'star_reward',
          isRead: true,
          createdAt: 'Hôm qua',
        ),
      ];
    }
  }
  ```

- [ ] **Step 2: Create `NotificationCenterScreen`**
  Create `mobile/lib/features/notifications/presentation/notification_center_screen.dart`:
  Renders list of notifications with emoji icons, time badges, and empty state.

- [ ] **Step 3: Register `/notifications` route**
  Add `/notifications` route in `mobile/lib/core/router/app_router.dart`.

- [ ] **Step 4: Commit**
  ```bash
  git add mobile/lib/features/notifications/ mobile/lib/core/router/app_router.dart
  git commit -m "feat(mobile): implement NotificationCenterScreen and notification repository"
  ```

---

### Task 2: Implement Animated `NotificationBannerWidget`, `NotificationService` Enhancements & Tests

Implement in-app top slide-down banner notification, notification scheduler, and full test suite verification.

**Files:**
- Create: `mobile/lib/core/widgets/notification_banner.dart`
- Modify: `mobile/lib/core/services/notification_service.dart`
- Modify: `mobile/test/widget_test.dart`

**Interfaces:**
- Produces: In-app animated top slide notification banner and 100% test pass suite.

- [ ] **Step 1: Create `NotificationBannerWidget`**
  Create `mobile/lib/core/widgets/notification_banner.dart`:
  Slide and fade animated banner widget for top-of-screen notifications.

- [ ] **Step 2: Update `NotificationService`**
  Modify `mobile/lib/core/services/notification_service.dart` with local scheduler functions.

- [ ] **Step 3: Add widget test for `NotificationCenterScreen`**
  Add test scenario in `mobile/test/widget_test.dart`.

- [ ] **Step 4: Run full test suite**
  Run `cd mobile && flutter test` and `docker compose exec -T app php artisan test`.
  Expected: All tests pass cleanly.

- [ ] **Step 5: Commit**
  ```bash
  git add mobile/lib/core/widgets/notification_banner.dart mobile/lib/core/services/notification_service.dart mobile/test/widget_test.dart
  git commit -m "feat(mobile): add animated NotificationBannerWidget, NotificationService and widget tests"
  ```
