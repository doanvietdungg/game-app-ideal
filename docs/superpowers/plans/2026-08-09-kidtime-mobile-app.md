# KidTime Mobile App (Sprint 1) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Setup Flutter project scaffolding, routing, state management, pastel theme, authentication flow (PIN & Email), and the Home screen shell with Rive animation assets.

**Architecture:** Clean Architecture (data, domain, presentation layers per feature) with Riverpod for reactive state management and GoRouter for routing.

**Tech Stack:** Flutter 3.x, Riverpod 2.x, GoRouter, Rive, SharedPreferences, Dio.

## Global Constraints
- Target directory: `mobile/` in the workspace root.
- Theme: Pastel Warm palette (`#FFB347` Peach, `#A8E6CF` Mint, `#FFFBF0` Warm White, `#3D2B1F` Warm Brown).
- Ensure all screens have proper test coverage (widget or unit tests).

---

### Task 1: Scaffolding and Core Setup

Scaffold the Flutter app in a new `mobile` folder, set up dependencies, Clean Architecture directories, theme, and router configuration.

**Files:**
- Create: `mobile/pubspec.yaml`
- Create: `mobile/lib/main.dart`
- Create: `mobile/lib/core/theme/app_theme.dart`
- Create: `mobile/lib/core/router/app_router.dart`
- Create: `mobile/lib/core/api/api_client.dart`

- [ ] **Step 1: Create pubspec.yaml with dependencies**
  Write `mobile/pubspec.yaml`:
  ```yaml
  name: kidtime_mobile
  description: "KidTime Mobile Client App"
  publish_to: 'none'
  version: 1.0.0+1

  environment:
    sdk: '>=3.0.0 <4.0.0'

  dependencies:
    flutter:
      sdk: flutter
    flutter_riverpod: ^2.5.1
    riverpod_annotation: ^2.3.3
    go_router: ^13.2.0
    dio: ^5.4.1
    shared_preferences: ^2.2.2
    rive: ^0.13.0
    cupertino_icons: ^1.0.6

  dev_dependencies:
    flutter_test:
      sdk: flutter
    riverpod_generator: ^2.3.9
    build_runner: ^2.4.8

  flutter:
    uses-material-design: true
  ```

- [ ] **Step 2: Define AppTheme with pastel system**
  Write `mobile/lib/core/theme/app_theme.dart`:
  ```dart
  import 'package:flutter/material.dart';

  class AppTheme {
    static const primary = Color(0xFFFFB347);
    static const secondary = Color(0xFFA8E6CF);
    static const accent = Color(0xFFFFD3E8);
    static const background = Color(0xFFFFFBF0);
    static const text = Color(0xFF3D2B1F);

    static ThemeData get light {
      return ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.light(
          primary: primary,
          secondary: secondary,
          background: background,
        ),
        fontFamily: 'Nunito',
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: text, fontWeight: FontWeight.extrabold),
          bodyLarge: TextStyle(color: text, fontWeight: FontWeight.w600),
        ),
      );
    }
  }
  ```

- [ ] **Step 3: Setup Router configuration**
  Write `mobile/lib/core/router/app_router.dart` with routing for Splash, Role Selection, Login, and Home:
  ```dart
  import 'package:flutter/material.dart';
  import 'package:go_router/go_router.dart';

  final appRouter = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const Scaffold(body: Center(child: Text('Splash'))),
      ),
      GoRoute(
        path: '/role-selection',
        builder: (context, state) => const Scaffold(body: Center(child: Text('Role Selection'))),
      ),
      GoRoute(
        path: '/login-parent',
        builder: (context, state) => const Scaffold(body: Center(child: Text('Parent Login'))),
      ),
      GoRoute(
        path: '/login-child',
        builder: (context, state) => const Scaffold(body: Center(child: Text('Child Login'))),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const Scaffold(body: Center(child: Text('Home'))),
      ),
    ],
  );
  ```

- [ ] **Step 4: Create main.dart entry**
  Write `mobile/lib/main.dart`:
  ```dart
  import 'package:flutter/material.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'core/theme/app_theme.dart';
  import 'core/router/app_router.dart';

  void main() {
    runApp(
      const ProviderScope(
        child: KidTimeApp(),
      ),
    );
  }

  class KidTimeApp extends StatelessWidget {
    const KidTimeApp({super.key});

    @override
    Widget build(BuildContext context) {
      return MaterialApp.router(
        title: 'KidTime',
        theme: AppTheme.light,
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
      );
    }
  }
  ```

- [ ] **Step 5: Verify setup by running mock test**
  Create `mobile/test/widget_test.dart` asserting that the app mounts correctly.
  Run: `cd mobile && flutter test`
  Expected: PASS.

- [ ] **Step 6: Commit**
  ```bash
  git add mobile/pubspec.yaml mobile/lib mobile/test
  git commit -m "feat(mobile): scaffold Flutter project with riverpod and gorouter"
  ```

---

### Task 2: Splash & Auth Screen Implementation

Create the Splash, Role Selection, Parent Login, and Child Login screens.

**Files:**
- Create: `mobile/lib/features/auth/presentation/splash_screen.dart`
- Create: `mobile/lib/features/auth/presentation/role_selection_screen.dart`
- Create: `mobile/lib/features/auth/presentation/parent_login_screen.dart`
- Create: `mobile/lib/features/auth/presentation/child_login_screen.dart`
- Modify: `mobile/lib/core/router/app_router.dart`

- [ ] **Step 1: Implement Splash Screen**
  Add scale animation to logo and auto-redirect to `/role-selection` after 2 seconds:
  ```dart
  // Write splash_screen.dart with slide/fade animation for KidTime logo
  ```

- [ ] **Step 2: Implement Role Selection Screen**
  Provide 2 cards: "Bé đăng nhập" & "Bố mẹ đăng nhập" styled with rounded borders and warm shadow:
  ```dart
  // Write role_selection_screen.dart
  ```

- [ ] **Step 3: Implement Parent Login Screen**
  Form with email and password input validated using Riverpod state providers:
  ```dart
  // Write parent_login_screen.dart
  ```

- [ ] **Step 4: Implement Child Login Screen**
  Children log in using the family 4-digit PIN:
  ```dart
  // Write child_login_screen.dart
  ```

- [ ] **Step 5: Register routes**
  Update `app_router.dart` to point to the actual screen widgets.

- [ ] **Step 6: Run tests and verify**
  Run: `cd mobile && flutter test`
  Expected: PASS.

- [ ] **Step 7: Commit**
  ```bash
  git add mobile/lib
  git commit -m "feat(mobile): implement Splash, Role Selection, and Login views"
  ```

---

### Task 3: Home Screen & Pet Animation Placeholder

Create the home screen for kids, including current stats, streak counter, and Rive pet animation canvas.

**Files:**
- Create: `mobile/lib/features/home/presentation/home_screen.dart`
- Modify: `mobile/lib/core/router/app_router.dart`

- [ ] **Step 1: Create home screen structure**
  Layout: Top header with streak 🔥 count and stars ⭐ count, pet display area in the center, and task list below.
  ```dart
  // Write home_screen.dart
  ```

- [ ] **Step 2: Add Rive pet placeholder**
  Load a simple Rive asset (or a default Rive loop) to simulate the virtual pet's idle animation.
  ```dart
  // Integrate RiveAnimation widget with loop controller
  ```

- [ ] **Step 3: Run widget tests for Home screen**
  Verify stats and layout render correctly.
  Run: `cd mobile && flutter test`
  Expected: PASS.

- [ ] **Step 4: Commit**
  ```bash
  git add mobile/lib
  git commit -m "feat(mobile): implement home screen shell with pet Rive canvas placeholder"
  ```
