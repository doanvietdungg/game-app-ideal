# Design Spec: Parent Remote App Lock Module (Khóa Ứng Dụng Từ Xa)

**Date**: 2026-08-12  
**Status**: Approved  
**Topic**: Parent Remote App Lock Module Implementation & MethodChannel Integration  

---

## 1. Overview & Objectives

Implement an end-to-end Parent Remote App Lock module for the KidTime application. This module empowers parents to remotely lock or limit specific mobile applications (e.g., YouTube, TikTok, games) on their children's devices and synchronize state seamlessly with the Laravel backend database and Android native layer.

---

## 2. Architecture & Data Flow

```
[Parent Device / AppLockSettingsScreen]
       │
       ├─► (1) HTTP POST /api/v1/blocking/apps ──► Laravel Backend (blocked_apps table)
       │
       └─► (2) MethodChannel ('com.kidtime.app/blocking') ──► AppBlockingService
                                                                     │
                                                                     ▼
                                                      Android Native (MainActivity.kt)
                                                      - syncBlockedApps(packages)
                                                      - setBlockingEnabled(enabled)
```

### Components:
1. **Frontend (Flutter)**:
   - `AppLockSettingsScreen`: Interactive management UI for parents to toggle Master Lock and select specific apps to block.
   - `ProfileSettingsScreen`: Adds navigation entry point `🔒 Quản lý Khóa App từ xa`.
   - `AppBlockingService`: Wrapper service invoking Flutter `MethodChannel`.
2. **Backend (Laravel)**:
   - Route `POST /api/v1/blocking/apps` handled by `MobileProfileController::syncApps` and `SyncBlockedAppsUseCase`.
   - Database table `blocked_apps` (`id`, `family_id`, `app_bundle_id`, `app_name`).
3. **Android Native (Kotlin)**:
   - `MainActivity.kt`: Configures `MethodChannel("com.kidtime.app/blocking")` to receive and handle `syncBlockedApps` and `setBlockingEnabled`.

---

## 3. Detailed Component Specification

### 3.1 `AppLockSettingsScreen.dart`
- **Location**: `mobile/lib/features/parent/presentation/app_lock_settings_screen.dart`
- **Features**:
  - **Master Switch Banner**: Toggle ON/OFF to enable or disable remote app lock.
  - **Preset App Selection List**:
    - YouTube (`com.google.android.youtube`)
    - TikTok (`com.zhiliaoapp.musically`)
    - Roblox (`com.roblox.client`)
    - Facebook (`com.facebook.katana`)
    - Chrome Web (`com.android.chrome`)
    - Sample Game (`com.mobile.game.sample`)
  - **Quick Select Tools**: "Chọn tất cả" & "Bỏ chọn tất cả".
  - **Action Button**: "Lưu & Áp Dụng Ngay 🛡️" triggering API sync and native method channel calls with user feedback (SnackBar).

### 3.2 `ProfileSettingsScreen.dart` Integration
- Add a new card in `ProfileSettingsScreen` allowing parents to navigate directly to `/app-lock-settings` (or push `AppLockSettingsScreen`).

### 3.3 Android Native Integration (`MainActivity.kt`)
- **Location**: `mobile/android/app/src/main/kotlin/com/kidtime/mobile/MainActivity.kt`
- Register `MethodChannel("com.kidtime.app/blocking")` in `configureFlutterEngine`.
- Handle `syncBlockedApps` (receives list of app package names).
- Handle `setBlockingEnabled` (receives boolean flag).
- Return `result.success(true)`.

---

## 4. Testing & Verification Plan

1. **Automated Widget & Unit Tests**:
   - Add test case in `mobile/test/widget_test.dart` asserting that `AppLockSettingsScreen` mounts correctly, toggles switches, selects app checkboxes, and invokes `AppBlockingService` cleanly.
2. **Flutter Test Suite**:
   - Run `flutter test` in `mobile/` directory to ensure zero regressions across all 17+ tests.
