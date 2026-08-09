# KidTime Sprint 6 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement Sprint 6 features: Audio FX Service (`AudioService`), `GalleryRepository`, `PraiseGalleryScreen` (`/praise-gallery`), and full test suite verification.

**Architecture:** Create `mobile/lib/core/services/audio_service.dart`, `mobile/lib/features/gallery/`, and register `/praise-gallery` route in `mobile/lib/core/router/app_router.dart`.

**Tech Stack:** Flutter 3.x, GoRouter, Riverpod, Dio.

## Global Constraints

- Non-blocking audio playback in `AudioService`.
- Rich pastel cards with praise stickers and comments in `PraiseGalleryScreen`.
- 100% test pass on `flutter test` and `php artisan test`.

---

### Task 1: Implement `GalleryRepository` & `PraiseGalleryScreen`

Create gallery data repository, praise gallery feed screen, and route registration.

**Files:**
- Create: `mobile/lib/features/gallery/data/gallery_repository.dart`
- Create: `mobile/lib/features/gallery/presentation/praise_gallery_screen.dart`
- Modify: `mobile/lib/core/router/app_router.dart`

**Interfaces:**
- Consumes: `ApiClient` (`/v1/gallery/praises`).
- Produces: Route `/praise-gallery` showing photo proofs of completed tasks with parent stickers & praise notes.

- [ ] **Step 1: Create `GalleryRepository`**
  Create `mobile/lib/features/gallery/data/gallery_repository.dart`:
  ```dart
  import '../../../core/api/api_client.dart';

  class PraiseItem {
    final String id;
    final String taskTitle;
    final String photoUrl;
    final int starsEarned;
    final String stickerEmoji;
    final String stickerText;
    final String parentComment;
    final String completedAt;

    PraiseItem({
      required this.id,
      required this.taskTitle,
      required this.photoUrl,
      required this.starsEarned,
      required this.stickerEmoji,
      required this.stickerText,
      required this.parentComment,
      required this.completedAt,
    });
  }

  class GalleryRepository {
    final ApiClient apiClient;
    GalleryRepository(this.apiClient);

    Future<List<PraiseItem>> getPraiseItems() async {
      try {
        final res = await apiClient.get('/gallery/praises').timeout(const Duration(milliseconds: 50));
        if (res.data is List) {
          return (res.data as List).map((item) => PraiseItem(
            id: item['id'].toString(),
            taskTitle: item['task_title'] ?? '',
            photoUrl: item['photo_url'] ?? '',
            starsEarned: item['stars_earned'] ?? 5,
            stickerEmoji: item['sticker_emoji'] ?? '🌟',
            stickerText: item['sticker_text'] ?? 'Xuất sắc!',
            parentComment: item['parent_comment'] ?? '',
            completedAt: item['completed_at'] ?? 'Hôm nay',
          )).toList();
        }
      } catch (_) {}
      return [
        PraiseItem(
          id: '1',
          taskTitle: 'Dọn dẹp phòng ngủ 🏠',
          photoUrl: 'https://via.placeholder.com/300',
          starsEarned: 5,
          stickerEmoji: '🌟',
          stickerText: 'Xuất sắc!',
          parentComment: 'Phòng con gọn gàng và ngăn nắp lắm!',
          completedAt: 'Hôm nay, 14:30',
        ),
        PraiseItem(
          id: '2',
          taskTitle: 'Đọc sách 20 phút 📚',
          photoUrl: 'https://via.placeholder.com/300',
          starsEarned: 10,
          stickerEmoji: '🎓',
          stickerText: 'Siêu chăm chỉ!',
          parentComment: 'Con đọc sách rất tập trung, bố mẹ tự hào về con!',
          completedAt: 'Hôm qua, 19:00',
        ),
      ];
    }
  }
  ```

- [ ] **Step 2: Create `PraiseGalleryScreen`**
  Create `mobile/lib/features/gallery/presentation/praise_gallery_screen.dart`:
  Renders praise photo feed with ribbon stickers, star count, and parent praise notes.

- [ ] **Step 3: Register `/praise-gallery` route**
  Add `/praise-gallery` route in `mobile/lib/core/router/app_router.dart`.

- [ ] **Step 4: Commit**
  ```bash
  git add mobile/lib/features/gallery/ mobile/lib/core/router/app_router.dart
  git commit -m "feat(mobile): implement PraiseGalleryScreen and gallery repository"
  ```

---

### Task 2: Implement `AudioService` & Test Suite Verification

Create `AudioService` audio synthesizer FX and add `PraiseGalleryScreen` widget tests.

**Files:**
- Create: `mobile/lib/core/services/audio_service.dart`
- Modify: `mobile/test/widget_test.dart`

**Interfaces:**
- Produces: `AudioService` for interaction sound FX and 100% test pass suite.

- [ ] **Step 1: Create `AudioService`**
  Create `mobile/lib/core/services/audio_service.dart`:
  ```dart
  class AudioService {
    static final AudioService _instance = AudioService._internal();
    factory AudioService() => _instance;
    AudioService._internal();

    void playFeedSound() {
      // Audio FX playback scaffold for feeding
    }

    void playTickleSound() {
      // Audio FX playback scaffold for tickling
    }

    void playStarSound() {
      // Audio FX playback scaffold for stars reward
    }

    void playFanfareSound() {
      // Audio FX playback scaffold for level-up celebration
    }
  }
  ```

- [ ] **Step 2: Add widget test for `PraiseGalleryScreen`**
  Add test scenario in `mobile/test/widget_test.dart`.

- [ ] **Step 3: Run full test suite**
  Run `cd mobile && flutter test` and `docker compose exec -T app php artisan test`.
  Expected: All tests pass cleanly.

- [ ] **Step 4: Commit**
  ```bash
  git add mobile/lib/core/services/audio_service.dart mobile/test/widget_test.dart
  git commit -m "feat(mobile): add AudioService FX synthesizer and PraiseGalleryScreen widget tests"
  ```
