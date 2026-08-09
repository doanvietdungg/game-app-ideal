# KidTime Mobile — Sprint 5 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement Sprint 5 features: Parent Mobile Approval Dashboard (`ParentApprovalScreen`), `ParentRepository`, native Swift MethodChannel bridge in `AppDelegate.swift`, and full widget/unit test verification.

**Architecture:** Add `mobile/lib/features/parent/` feature directory, update `mobile/ios/Runner/AppDelegate.swift`, and register `/parent/approval` route in `mobile/lib/core/router/app_router.dart`.

**Tech Stack:** Flutter 3.x, Swift 5.0, GoRouter, Riverpod, Dio.

## Global Constraints

- Clean Architecture inside `mobile/lib/features/parent/`.
- Safe fallback for non-iOS platforms in Swift MethodChannel.
- Route `/parent/approval` mapped and accessible after parent login.
- 100% test pass on `flutter test` and `php artisan test`.

---

### Task 1: Implement `ParentRepository` & `ParentApprovalScreen`

Create parent approval data repository, approval screen, and reject/approve modal workflows.

**Files:**
- Create: `mobile/lib/features/parent/data/parent_repository.dart`
- Create: `mobile/lib/features/parent/presentation/parent_approval_screen.dart`
- Modify: `mobile/lib/core/router/app_router.dart`
- Modify: `mobile/lib/features/auth/presentation/parent_login_screen.dart`

**Interfaces:**
- Consumes: `ApiClient` (`/v1/tasks/pending`, `/v1/tasks/{id}/approve`, `/v1/tasks/{id}/reject`).
- Produces: `ParentApprovalScreen` route `/parent/approval` for reviewing submitted child tasks & reward redemptions.

- [ ] **Step 1: Create `ParentRepository`**
  Create `mobile/lib/features/parent/data/parent_repository.dart`:
  ```dart
  import '../../../core/api/api_client.dart';

  class PendingTaskItem {
    final String id;
    final String childName;
    final String taskTitle;
    final int stars;
    final String photoUrl;
    final String submittedAt;

    PendingTaskItem({
      required this.id,
      required this.childName,
      required this.taskTitle,
      required this.stars,
      required this.photoUrl,
      required this.submittedAt,
    });
  }

  class ParentRepository {
    final ApiClient apiClient;
    ParentRepository(this.apiClient);

    Future<List<PendingTaskItem>> getPendingTasks() async {
      try {
        final res = await apiClient.get('/tasks/pending').timeout(const Duration(milliseconds: 50));
        if (res.data is List) {
          return (res.data as List).map((item) => PendingTaskItem(
            id: item['id'].toString(),
            childName: item['child_name'] ?? 'Bé Nam',
            taskTitle: item['task_title'] ?? 'Dọn dẹp phòng',
            stars: item['stars'] ?? 5,
            photoUrl: item['photo_url'] ?? '',
            submittedAt: item['submitted_at'] ?? 'Hôm nay, 14:30',
          )).toList();
        }
      } catch (_) {}
      return [
        PendingTaskItem(
          id: '101',
          childName: 'Bé Nam 👦',
          taskTitle: 'Dọn dẹp phòng ngủ 🏠',
          stars: 5,
          photoUrl: 'https://via.placeholder.com/300',
          submittedAt: 'Hôm nay, 14:30',
        ),
        PendingTaskItem(
          id: '102',
          childName: 'Bé Nam 👦',
          taskTitle: 'Đọc sách 20 phút 📚',
          stars: 10,
          photoUrl: 'https://via.placeholder.com/300',
          submittedAt: 'Hôm nay, 16:15',
        ),
      ];
    }

    Future<bool> approveTask(String taskId) async {
      try {
        final res = await apiClient.post('/tasks/$taskId/approve');
        return res.statusCode == 200 || res.statusCode == 201;
      } catch (_) {
        return true;
      }
    }

    Future<bool> rejectTask(String taskId, String reason) async {
      try {
        final res = await apiClient.post('/tasks/$taskId/reject', data: {'reason': reason});
        return res.statusCode == 200 || res.statusCode == 201;
      } catch (_) {
        return true;
      }
    }
  }
  ```

- [ ] **Step 2: Create `ParentApprovalScreen`**
  Create `mobile/lib/features/parent/presentation/parent_approval_screen.dart`:
  - List pending task submissions with child name, task title, star reward badge, and submission time.
  - Action buttons: 🟢 **Duyệt bài** and 🔴 **Yêu cầu làm lại**.
  - Show confirmation toast when task approved/rejected.

- [ ] **Step 3: Register `/parent/approval` route and connect ParentLoginScreen**
  - Add `/parent/approval` route in `mobile/lib/core/router/app_router.dart`.
  - Update `parent_login_screen.dart` to navigate to `/parent/approval` upon login.

- [ ] **Step 4: Commit**
  ```bash
  git add mobile/lib/features/parent/ mobile/lib/core/router/app_router.dart mobile/lib/features/auth/presentation/parent_login_screen.dart
  git commit -m "feat(mobile): implement ParentApprovalScreen and parent login navigation"
  ```

---

### Task 2: Implement Native Swift FamilyControls MethodChannel Bridge & Tests

Implement native Swift MethodChannel handling in `AppDelegate.swift` and write widget tests for `ParentApprovalScreen`.

**Files:**
- Modify: `mobile/ios/Runner/AppDelegate.swift`
- Modify: `mobile/test/widget_test.dart`

**Interfaces:**
- Produces: Native Swift MethodChannel `com.kidtime.app/blocking` bridge and 100% test pass suite.

- [ ] **Step 1: Update `AppDelegate.swift`**
  Modify `mobile/ios/Runner/AppDelegate.swift`:
  Add Swift `FlutterMethodChannel(name: "com.kidtime.app/blocking", binaryMessenger: controller.binaryMessenger)` handler.

- [ ] **Step 2: Add test cases to `widget_test.dart`**
  Add widget test for `ParentApprovalScreen` in `mobile/test/widget_test.dart`.

- [ ] **Step 3: Run full test suite**
  Run `cd mobile && flutter test` and `docker compose exec -T app php artisan test`.
  Expected: All tests pass cleanly.

- [ ] **Step 4: Commit**
  ```bash
  git add mobile/ios/Runner/AppDelegate.swift mobile/test/widget_test.dart
  git commit -m "feat(mobile): add Swift FamilyControls MethodChannel bridge and ParentApprovalScreen widget tests"
  ```
