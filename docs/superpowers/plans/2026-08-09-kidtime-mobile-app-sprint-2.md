# KidTime Mobile App (Sprint 2) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement API connection using Dio, Task List screen (categorized), Task Detail and Submit flows (Camera photo upload, Parent PIN verify, and Auto-approval), and integrate with the Laravel backend.

**Architecture:** Extend Clean Architecture with a data source layer for Tasks, repository interfaces, and Riverpod providers for managing today's tasks state.

**Tech Stack:** Flutter, Dio, ImagePicker, Riverpod.

## Global Constraints
- Target directory: `mobile/` in the workspace root.
- Ensure camera integration is fully testable or mocked in tests.
- Backend API base url: `http://localhost:8000/api`.

---

### Task 1: Add ImagePicker & Setup API Client

Add the `image_picker` dependency to pubspec.yaml and implement the HTTP API client using Dio with token interceptors.

**Files:**
- Modify: `mobile/pubspec.yaml`
- Create: `mobile/lib/core/api/api_client.dart`
- Create: `mobile/lib/core/api/token_storage.dart`

- [ ] **Step 1: Add image_picker dependency**
  Modify `mobile/pubspec.yaml` to include `image_picker: ^1.0.7` under dependencies:
  ```yaml
  dependencies:
    flutter:
      sdk: flutter
    flutter_riverpod: ^2.5.1
    riverpod_annotation: ^2.3.3
    go_router: ^13.2.0
    dio: ^5.4.1
    shared_preferences: ^2.2.2
    rive: ^0.13.0
    cupertino_icons: ^1.0.8
    image_picker: ^1.0.7
  ```

- [ ] **Step 2: Run pub get**
  Run: `cd mobile && flutter pub get`
  Expected: Successful download of new dependency.

- [ ] **Step 3: Implement Token Storage**
  Write `mobile/lib/core/api/token_storage.dart` using SharedPreferences:
  ```dart
  import 'package:shared_preferences/shared_preferences.dart';

  class TokenStorage {
    static const _key = 'auth_token';

    static Future<void> saveToken(String token) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, token);
    }

    static Future<String?> getToken() async {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_key);
    }

    static Future<void> clearToken() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    }
  }
  ```

- [ ] **Step 4: Implement ApiClient with Interceptors**
  Write `mobile/lib/core/api/api_client.dart`:
  ```dart
  import 'package:dio/dio.dart';
  import 'token_storage.dart';

  class ApiClient {
    final Dio _dio = Dio(BaseOptions(
      baseUrl: 'http://localhost:8000/api',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Accept': 'application/json',
      },
    ));

    ApiClient() {
      _dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenStorage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ));
    }

    Future<Response> get(String path) => _dio.get(path);
    Future<Response> post(String path, {dynamic data}) => _dio.post(path, data: data);
  }
  ```

- [ ] **Step 5: Run tests to verify compilation**
  Run: `cd mobile && flutter test`
  Expected: PASS.

- [ ] **Step 6: Commit**
  ```bash
  git add mobile/pubspec.yaml mobile/lib/core/api
  git commit -m "feat(mobile): add image_picker and implement ApiClient with token interceptors"
  ```

---

### Task 2: Implement Task List Screen

Create the Today's Tasks screen categorized into tabs, loading data reactively from the backend API.

**Files:**
- Create: `mobile/lib/features/tasks/data/task_repository.dart`
- Create: `mobile/lib/features/tasks/presentation/task_list_screen.dart`
- Modify: `mobile/lib/core/router/app_router.dart`

- [ ] **Step 1: Implement TaskRepository**
  Create `mobile/lib/features/tasks/data/task_repository.dart` to fetch today's tasks and nộp bài (submit):
  ```dart
  import 'package:dio/dio.dart';
  import '../../../core/api/api_client.dart';

  class TaskRepository {
    final ApiClient _apiClient;
    TaskRepository(this._apiClient);

    Future<List<Map<String, dynamic>>> getTodayTasks(int childId) async {
      final res = await _apiClient.get('/v1/children/$childId/tasks/today');
      return List<Map<String, dynamic>>.from(res.data['data']);
    }

    Future<bool> submitTask(int taskId, int childId, {String? filePath}) async {
      final formData = FormData.fromMap({
        'task_id': taskId,
        'child_id': childId,
        if (filePath != null)
          'photo': await MultipartFile.fromFile(filePath, filename: 'proof.jpg'),
      });

      final res = await _apiClient.post('/v1/task-logs', data: formData);
      return res.data['status'] == true || res.statusCode == 201;
    }
  }
  ```

- [ ] **Step 2: Implement Task List Screen UI**
  Create `mobile/lib/features/tasks/presentation/task_list_screen.dart` with horizontal tabs for categories:
  ```dart
  // Group tasks by category and build tabbed list
  ```

- [ ] **Step 3: Route mapping**
  Add route `/tasks` pointing to `TaskListScreen` in `app_router.dart`.

- [ ] **Step 4: Commit**
  ```bash
  git add mobile/lib/features/tasks
  git commit -m "feat(mobile): implement TaskRepository and TaskListScreen UI"
  ```

---

### Task 3: Implement Task Detail & Submission flows

Create the task details screen, and implement the three validation methods (Photo upload using ImagePicker, Parent PIN Verification, and Auto-Approval).

**Files:**
- Create: `mobile/lib/features/tasks/presentation/task_detail_screen.dart`
- Modify: `mobile/lib/core/router/app_router.dart`

- [ ] **Step 1: Build TaskDetailScreen layout**
  Show title, description, star reward, verification mode, and status.

- [ ] **Step 2: Implement Photo Capture & Upload flow**
  Use `ImagePicker` to take a picture, show preview, and call `submitTask` with the file path.

- [ ] **Step 3: Implement PIN verification popup**
  If verification mode is `pin`, pop up a dialog to enter the 4-digit PIN. If successful, submit and immediately approve.

- [ ] **Step 4: Implement Auto-Approval flow**
  If verification mode is `auto`, submit and trigger confetti transition.

- [ ] **Step 5: Add routing for `/tasks/:id`**
  Map `TaskDetailScreen` with path parameter `id` in `app_router.dart`.

- [ ] **Step 6: Write widget tests for task submission**
  Verify layouts render correctly under mock repository.
  Run: `cd mobile && flutter test`
  Expected: PASS.

- [ ] **Step 7: Commit**
  ```bash
  git add mobile/lib/features/tasks/presentation/task_detail_screen.dart mobile/lib/core/router/app_router.dart mobile/test
  git commit -m "feat(mobile): implement TaskDetailScreen with camera, PIN and auto submission flows"
  ```
