# KidTime Sprint 10 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement Sprint 10 features: `TaskTimerScreen` (`/tasks/timer`), Pomodoro countdown timer with studying pet expression, bonus stars celebration, and full test suite verification.

**Architecture:** Create `mobile/lib/features/tasks/presentation/task_timer_screen.dart` and register `/tasks/timer` route in `mobile/lib/core/router/app_router.dart`.

**Tech Stack:** Flutter 3.x, GoRouter, AnimationController, Riverpod.

## Global Constraints

- Smooth circular timer countdown animation.
- Route `/tasks/timer` mapped and accessible.
- 100% test pass on `flutter test` and `php artisan test`.

---

### Task 1: Implement `TaskTimerScreen` & Route Registration

Create Pomodoro timer screen, countdown controls, bonus star popup, and route.

**Files:**
- Create: `mobile/lib/features/tasks/presentation/task_timer_screen.dart`
- Modify: `mobile/lib/core/router/app_router.dart`

**Interfaces:**
- Produces: Route `/tasks/timer` providing interactive Pomodoro focus session.

- [ ] **Step 1: Create `TaskTimerScreen`**
  Create `mobile/lib/features/tasks/presentation/task_timer_screen.dart`:
  ```dart
  import 'dart:async';
  import 'package:flutter/material.dart';
  import '../../../core/theme/app_theme.dart';
  import '../../../core/services/audio_service.dart';
  import '../../pet/presentation/widgets/pet_physics_canvas.dart';

  class TaskTimerScreen extends StatefulWidget {
    const TaskTimerScreen({super.key});

    @override
    State<TaskTimerScreen> createState() => _TaskTimerScreenState();
  }

  class _TaskTimerScreenState extends State<TaskTimerScreen> {
    int _totalSeconds = 25 * 60;
    int _remainingSeconds = 25 * 60;
    Timer? _timer;
    bool _isRunning = false;

    void _startTimer() {
      setState(() => _isRunning = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingSeconds > 0) {
          setState(() => _remainingSeconds--);
        } else {
          _timer?.cancel();
          setState(() => _isRunning = false);
          AudioService().playFanfareSound();
          _showRewardDialog();
        }
      });
    }

    void _pauseTimer() {
      _timer?.cancel();
      setState(() => _isRunning = false);
    }

    void _showRewardDialog() {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('🎉 HOÀN THÀNH TẬP TRUNG!'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('⭐ +10 SAO THƯỞNG BONUS ⭐', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
              SizedBox(height: 12),
              Text('Bé và Mimi đã học tập rất chăm chỉ!'),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Nhận sao ngay'),
            )
          ],
        ),
      );
    }

    @override
    void dispose() {
      _timer?.cancel();
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
      final minutes = (_remainingSeconds / 60).floor().toString().padLeft(2, '0');
      final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');

      return Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(title: const Text('Đồng Hồ Tập Trung ⏳')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const PetPhysicsCanvas(expression: 'happy', species: 'cat'),
              const SizedBox(height: 32),
              Text('$minutes:$seconds', style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _isRunning ? _pauseTimer : _startTimer,
                    icon: Icon(_isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded),
                    label: Text(_isRunning ? 'Tạm dừng' : 'Bắt đầu học'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }
  ```

- [ ] **Step 2: Register `/tasks/timer` route**
  Add `/tasks/timer` route in `mobile/lib/core/router/app_router.dart`.

- [ ] **Step 3: Commit**
  ```bash
  git add mobile/lib/features/tasks/presentation/task_timer_screen.dart mobile/lib/core/router/app_router.dart
  git commit -m "feat(mobile): implement TaskTimerScreen Pomodoro focus timer and route"
  ```

---

### Task 2: Implement Test Suite Verification & Clean Up

Add `TaskTimerScreen` widget test case in `mobile/test/widget_test.dart` and verify all tests pass.

**Files:**
- Modify: `mobile/test/widget_test.dart`

**Interfaces:**
- Produces: 100% test pass suite for all mobile & backend features.

- [ ] **Step 1: Add widget test for `TaskTimerScreen`**
  Add test scenario in `mobile/test/widget_test.dart`.

- [ ] **Step 2: Run full test suite**
  Run `cd mobile && flutter test` and `docker compose exec -T app php artisan test`.
  Expected: All tests pass cleanly.

- [ ] **Step 3: Commit**
  ```bash
  git add mobile/test/widget_test.dart
  git commit -m "test(mobile): add TaskTimerScreen widget test and verify full test suite"
  ```
