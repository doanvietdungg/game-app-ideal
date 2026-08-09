# KidTime Sprint 7 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement Sprint 7 features: Multi-species rendering in `PetPhysicsCanvas` (🐱 Cat, 🐶 Dog, 🐉 Dragon, 🐰 Rabbit), `PetSelectionScreen` (`/pet/select`), achievement badges grid widget, and full test suite verification.

**Architecture:** Update `mobile/lib/features/pet/presentation/widgets/pet_physics_canvas.dart`, create `mobile/lib/features/pet/presentation/pet_selection_screen.dart`, add `/pet/select` route, and add badge grid to `StatsScreen`.

**Tech Stack:** Flutter 3.x, Vector CustomPainter, GoRouter, Riverpod.

## Global Constraints

- Smooth species rendering in `PetPhysicsCanvas`.
- Route `/pet/select` mapped and accessible.
- 100% test pass on `flutter test` and `php artisan test`.

---

### Task 1: Update `PetPhysicsCanvas` for Multi-Species & Create `PetSelectionScreen`

Support 4 species in vector rendering engine and create pet selection UI.

**Files:**
- Modify: `mobile/lib/features/pet/presentation/widgets/pet_physics_canvas.dart`
- Modify: `mobile/lib/features/pet/presentation/pet_screen.dart`
- Create: `mobile/lib/features/pet/presentation/pet_selection_screen.dart`
- Modify: `mobile/lib/core/router/app_router.dart`

**Interfaces:**
- Produces: `PetPhysicsCanvas(species: 'cat' | 'dog' | 'dragon' | 'rabbit')` and `PetSelectionScreen` route `/pet/select`.

- [ ] **Step 1: Update `PetPhysicsCanvas`**
  Add `species` parameter to `PetPhysicsCanvas` and draw dog ears, dragon horns/wings, rabbit long ears.

- [ ] **Step 2: Create `PetSelectionScreen`**
  Create `mobile/lib/features/pet/presentation/pet_selection_screen.dart` allowing species switching.

- [ ] **Step 3: Register `/pet/select` route**
  Add `/pet/select` route in `mobile/lib/core/router/app_router.dart`.

- [ ] **Step 4: Commit**
  ```bash
  git add mobile/lib/features/pet/ mobile/lib/core/router/app_router.dart
  git commit -m "feat(mobile): implement multi-species pet canvas rendering and PetSelectionScreen"
  ```

---

### Task 2: Implement Achievement Badges Grid & Test Suite Verification

Add achievement badges grid card to `StatsScreen` and test suite verification.

**Files:**
- Modify: `mobile/lib/features/stats/presentation/stats_screen.dart`
- Modify: `mobile/test/widget_test.dart`

**Interfaces:**
- Produces: Achievement badges grid card and 100% test pass suite.

- [ ] **Step 1: Update `StatsScreen`**
  Add Achievement Badges section ("🔥 Chiến thần Streak 7 Ngày", "📚 Dũng sĩ Đọc sách", "⭐ Ngôi sao Chăm chỉ").

- [ ] **Step 2: Add widget test for `PetSelectionScreen`**
  Add test scenario in `mobile/test/widget_test.dart`.

- [ ] **Step 3: Run full test suite**
  Run `cd mobile && flutter test` and `docker compose exec -T app php artisan test`.
  Expected: All tests pass cleanly.

- [ ] **Step 4: Commit**
  ```bash
  git add mobile/lib/features/stats/presentation/stats_screen.dart mobile/test/widget_test.dart
  git commit -m "feat(mobile): add achievement badges grid and PetSelectionScreen widget tests"
  ```
