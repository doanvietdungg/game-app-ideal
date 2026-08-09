# KidTime Mobile App (Sprint 3) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the Virtual Pet page (feeding, animations), Store & Wardrobe Screen (purchasing and changing skins with stars), and write comprehensive integration/widget tests.

**Architecture:** Extend the Pet feature folder structure: `mobile/lib/features/pet/presentation/`.

---

### Task 1: Implement Interactive Pet Screen

Create the dedicated Virtual Pet detail screen allowing feeding, tickling, and interaction.

**Files:**
- Create: `mobile/lib/features/pet/presentation/pet_screen.dart`
- Modify: `mobile/lib/core/router/app_router.dart`

- [ ] **Step 1: Create PetScreen widget**
  Create `mobile/lib/features/pet/presentation/pet_screen.dart`. It should have:
  - Interactive pet character (using custom animations or emoji representations).
  - Feeding button (costs 2 stars, increases pet satisfaction index).
  - Play button (increases happiness).
  - Custom status indicators (Đói, Vui, Buồn, Ngủ).

- [ ] **Step 2: Map route `/pet`**
  Register `/pet` in `app_router.dart` pointing to `PetScreen`.

- [ ] **Step 3: Connect HomeScreen pet canvas to PetScreen**
  Modify the pet canvas container in `home_screen.dart` to navigate to `/pet` on tap.

- [ ] **Step 4: Commit**
  ```bash
  git add mobile/lib/features/pet mobile/lib/core/router/app_router.dart
  git commit -m "feat(mobile): implement interactive PetScreen and home screen navigation"
  ```

---

### Task 2: Implement Store & Wardrobe Screen

Create a Store and Wardrobe tab screen where the child can unlock and equip custom Rive skin themes.

**Files:**
- Create: `mobile/lib/features/pet/presentation/store_screen.dart`
- Modify: `mobile/lib/core/router/app_router.dart`

- [ ] **Step 1: Create StoreScreen widget**
  Create `mobile/lib/features/pet/presentation/store_screen.dart`. It should contain:
  - A tab bar separating the "Cửa hàng" (Store) and "Tủ đồ" (Wardrobe).
  - Store: Lists premium skins (e.g. Mèo Robot 🤖 - 15⭐, Mèo Ninja 🥷 - 30⭐, Mèo Quý Tộc 👑 - 50⭐) with unlock buttons.
  - Wardrobe: Lists unlocked skins with "Trang bị" (Equip) buttons to set active skin.
  - Call `ApiClient` `/v1/pet/skin` to register purchases and active equips.

- [ ] **Step 2: Map route `/store`**
  Register `/store` route in `app_router.dart`.

- [ ] **Step 3: Connect quick actions**
  Make "Đổi quà" and "Tủ đồ" buttons in `home_screen.dart` navigate to `/store` on tap.

- [ ] **Step 4: Commit**
  ```bash
  git add mobile/lib/features/pet/presentation/store_screen.dart
  git commit -m "feat(mobile): implement Store & Wardrobe Screen and quick action routing"
  ```

---

### Task 3: Write Integration Tests & Complete Branch

Write end-to-end integration tests verifying the full flow: login -> home -> list tasks -> detail submit -> interaction -> skin store unlock.

**Files:**
- Modify: `mobile/test/widget_test.dart`

- [ ] **Step 1: Write integration tests**
  Add test scenarios for `PetScreen` feeding logic and `StoreScreen` purchasing/equipping in `widget_test.dart`.

- [ ] **Step 2: Run all tests**
  Run: `cd mobile && flutter test` and `docker compose exec -T app php artisan test`
  Expected: All tests pass.

- [ ] **Step 3: Commit and merge**
  ```bash
  git add mobile/test/widget_test.dart
  git commit -m "test(mobile): verify interactive pet and store flow in widget tests"
  ```
