# KidTime Mobile & Backend — Sprint 9 Design Spec

**Ngày:** 2026-08-09  
**Trạng thái:** Approved  
**Phạm vi:** Profile Settings Screen (`/profile/settings`), Offline Sync Engine (`OfflineSyncService`), Profile Repository

---

## 1. Mục tiêu

1. **Màn Hình Hồ Sơ & Cài Đặt (`ProfileSettingsScreen`)**:
   - Route `/profile/settings` quản lý thông tin bé (tên, avatar, tuổi, mã PIN gia đình).
   - Tùy chỉnh công tắc bật/tắt: 🔔 Thông báo nhắc nhở, 🔊 Âm thanh hiệu ứng (Sound FX).
   - Nút đăng xuất / chuyển đổi vai trò.
2. **Bộ Cơ Chế Đồng Bộ Offline (`OfflineSyncService`)**:
   - Quản lý trạng thái lưu trữ ngoại tuyến khi ngắt kết nối Internet.
   - Hàm `queueOfflineTaskSubmission()` và `syncPendingSubmissions()`.

---

## 2. Kiến trúc & Cấu trúc Thư mục

```
mobile/lib/
├── core/
│   ├── services/
│   │   └── offline_sync_service.dart          # Offline queue manager & auto sync
├── features/
│   ├── profile/
│   │   ├── data/
│   │   │   └── profile_repository.dart        # GET/PUT /v1/profile
│   │   └── presentation/
│   │       └── profile_settings_screen.dart   # Màn hình cài đặt hồ sơ & tùy chọn
```

---

## 3. Chi tiết Kỹ thuật

### 3.1 `ProfileRepository`
- Model `UserProfile`: `id`, `name`, `avatarEmoji`, `age`, `soundFxEnabled`, `notificationsEnabled`.
- Endpoint: `GET /v1/profile`, `PUT /v1/profile`.

### 3.2 `ProfileSettingsScreen` (`/profile/settings`)
- Form chỉnh sửa thông tin bé và công tắc `SwitchListTile` cài đặt.
- Nút đăng xuất quay về chọn vai trò `/role-selection`.

---

## 4. Kiểm thử & Xác minh
- Viết Widget Test cho `ProfileSettingsScreen`.
- Đảm bảo 100% Flutter test và Laravel test pass.
