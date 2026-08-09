# KidTime Mobile — Interactive Pet Animation & Bottom Navigation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement vivid interactive physics pet animation canvas (`PetPhysicsCanvas`), particle emitter overlay (`ParticleOverlay`), drag-and-drop food feeding (`DraggableFoodItem`), and 4-tab Bottom Navigation Bar on `HomeScreen`.

**Architecture:** Create custom widgets in `mobile/lib/features/pet/presentation/widgets/` and update `mobile/lib/features/home/presentation/home_screen.dart`.

**Tech Stack:** Flutter 3.x, CustomPainter, AnimationController, GestureDetector, Drag-and-Drop, Riverpod.

## Global Constraints

- Smooth 60 FPS animation using Flutter `CustomPainter` and `AnimationController`.
- Zero external native binary asset dependency (100% Flutter vector rendering + particles).
- Safe fallback for non-drag touch events.
- All widget tests passing in `mobile/test/widget_test.dart`.

---

### Task 1: Implement `PetPhysicsCanvas` & `ParticleOverlay` Widgets

Create vector graphics pet canvas with eye-tracking, squish-stretch physics, and particle emitter.

**Files:**
- Create: `mobile/lib/features/pet/presentation/widgets/pet_physics_canvas.dart`
- Create: `mobile/lib/features/pet/presentation/widgets/particle_overlay.dart`

**Interfaces:**
- Produces: `PetPhysicsCanvas(touchOffset, expression, scaleX, scaleY)` and `ParticleOverlay(particles)`.

- [ ] **Step 1: Create `ParticleOverlay` widget**
  Create `mobile/lib/features/pet/presentation/widgets/particle_overlay.dart`:
  ```dart
  import 'dart:math';
  import 'package:flutter/material.dart';

  class ParticleItem {
    double x;
    double y;
    double vx;
    double vy;
    double opacity;
    final String emoji;

    ParticleItem({
      required this.x,
      required this.y,
      required this.vx,
      required this.vy,
      this.opacity = 1.0,
      required this.emoji,
    });
  }

  class ParticleOverlay extends StatefulWidget {
    final List<ParticleItem> particles;
    const ParticleOverlay({super.key, required this.particles});

    @override
    State<ParticleOverlay> createState() => _ParticleOverlayState();
  }

  class _ParticleOverlayState extends State<ParticleOverlay> with SingleTickerProviderStateMixin {
    late AnimationController _controller;

    @override
    void initState() {
      super.initState();
      _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();
      _controller.addListener(_updateParticles);
    }

    void _updateParticles() {
      if (widget.particles.isEmpty) return;
      setState(() {
        for (var p in widget.particles) {
          p.x += p.vx;
          p.y += p.vy;
          p.opacity = (p.opacity - 0.03).clamp(0.0, 1.0);
        }
        widget.particles.removeWhere((p) => p.opacity <= 0.0);
      });
    }

    @override
    void dispose() {
      _controller.dispose();
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
      return IgnorePointer(
        child: Stack(
          children: widget.particles.map((p) {
            return Positioned(
              left: p.x,
              top: p.y,
              child: Opacity(
                opacity: p.opacity,
                child: Text(p.emoji, style: const TextStyle(fontSize: 24)),
              ),
            );
          }).toList(),
        ),
      );
    }
  }
  ```

- [ ] **Step 2: Create `PetPhysicsCanvas` widget**
  Create `mobile/lib/features/pet/presentation/widgets/pet_physics_canvas.dart`:
  Vector CustomPainter pet rendering body, ears, eyes with dynamic gaze tracking, mouth expressions, and squish/stretch scale transformation.

- [ ] **Step 3: Commit**
  ```bash
  git add mobile/lib/features/pet/presentation/widgets/
  git commit -m "feat(mobile): add PetPhysicsCanvas and ParticleOverlay widgets"
  ```

---

### Task 2: Implement Interactive Drag-and-Drop PetScreen

Integrate drag-and-drop food items, magnet attraction, touch tickle reactions, and particle bursts into `PetScreen`.

**Files:**
- Create: `mobile/lib/features/pet/presentation/widgets/draggable_food.dart`
- Modify: `mobile/lib/features/pet/presentation/pet_screen.dart`

**Interfaces:**
- Consumes: `PetPhysicsCanvas`, `ParticleOverlay`.
- Produces: Fully interactive `PetScreen` with drag-and-drop food magnet feeding and pat/tickle physics.

- [ ] **Step 1: Create `DraggableFood` widget**
  Create `mobile/lib/features/pet/presentation/widgets/draggable_food.dart`:
  Renders draggable food item (🍖 / 🍼) supporting drag callbacks and magnet scale animations.

- [ ] **Step 2: Update `PetScreen`**
  Modify `mobile/lib/features/pet/presentation/pet_screen.dart` to use `PetPhysicsCanvas`, `ParticleOverlay`, and `DraggableFood`.

- [ ] **Step 3: Commit**
  ```bash
  git add mobile/lib/features/pet/presentation/
  git commit -m "feat(mobile): integrate interactive physics pet engine with drag-and-drop feeding"
  ```

---

### Task 3: Implement 4-Tab Bottom Navigation Bar on HomeScreen & Verify Suite

Add Bottom Navigation Bar to `HomeScreen` for seamless navigation between Home, Tasks, Rewards, and Stats, and run full test suite.

**Files:**
- Modify: `mobile/lib/features/home/presentation/home_screen.dart`
- Modify: `mobile/test/widget_test.dart`

**Interfaces:**
- Produces: 4-tab Bottom Navigation Bar (🏠 Home, 📋 Tasks, 🎁 Rewards, 📊 Stats) and 100% passing tests.

- [ ] **Step 1: Update `HomeScreen` with `BottomNavigationBar`**
  Modify `mobile/lib/features/home/presentation/home_screen.dart`:
  Add IndexedStack or Tab switching between `HomeTab`, `TaskListScreen`, `RewardListScreen`, and `StatsScreen`.

- [ ] **Step 2: Run Flutter tests**
  Run `cd mobile && flutter test`.
  Expected: All tests pass cleanly.

- [ ] **Step 3: Commit**
  ```bash
  git add mobile/lib/features/home/presentation/home_screen.dart mobile/test/widget_test.dart
  git commit -m "feat(mobile): add 4-tab BottomNavigationBar to HomeScreen and verify widget tests"
  ```
