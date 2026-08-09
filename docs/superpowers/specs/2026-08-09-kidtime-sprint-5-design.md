# KidTime Mobile & Web — Sprint 5 Design Spec

**Ngày:** 2026-08-09  
**Trạng thái:** Approved  
**Phạm vi:** Mobile Parent Approval Dashboard (`/parent/approval`), Web & Mobile Dual Approval Sync, iOS Native Family Controls Swift Integration, FCM Notification Service Architecture

---

## 1. Mục tiêu

1. **Duyệt bài & Đổi quà linh hoạt kép (Dual Approval System)**:
   - Cho phép bố mẹ duyệt bài tập (xem ảnh/PIN) và duyệt yêu cầu đổi quà trên **cả Web Dashboard và Mobile App (Chế độ Phụ huynh)**.
   - Cập nhật trạng thái tức thì giữa Web và Mobile.
2. **Màn hình Phụ huynh trên Mobile (`ParentApprovalScreen`)**:
   - Màn hình duyệt dành riêng cho bố mẹ khi đăng nhập vai trò Phụ huynh (`/parent/approval`).
   - Nút hành động một chạm: 🟢 *Duyệt bài (+Sao & Mở khóa App)* / 🔴 *Yêu cầu làm lại (nhập lý do)*.
3. **iOS Native Family Controls (`AppDelegate.swift`)**:
   - Viết mã Swift quản lý `MethodChannel('com.kidtime.app/blocking')` để kích hoạt `ManagedSettingsStore` ứng dụng giải trí.
4. **Hệ thống Thông báo Đẩy (Notification Architecture)**:
   - Thiết lập cấu trúc `NotificationService` tiếp nhận FCM payload thông báo duyệt bài real-time và hiển thị Banner chúc mừng.

---

## 2. Kiến trúc & Cấu trúc Thư mục

```
mobile/
├── ios/Runner/AppDelegate.swift              # Swift MethodChannel FamilyControls integration
├── lib/
│   ├── core/
│   │   ├── services/
│   │   │   └── notification_service.dart     # FCM Payload parser & Local notification trigger
│   ├── features/
│   │   ├── auth/
│   │   │   └── presentation/parent_login_screen.dart # Điều hướng sau login sang Parent Dashboard
│   │   ├── parent/
│   │   │   ├── data/
│   │   │   │   └── parent_repository.dart    # GET /v1/tasks/pending, POST /v1/tasks/{id}/approve
│   │   │   └── presentation/
│   │   │       └── parent_approval_screen.dart # Màn hình duyệt bài & quà dành cho bố mẹ
```

---

## 3. Chi tiết Kỹ thuật

### 3.1 `ParentApprovalScreen` (`/parent/approval`)
- **API calls**:
  - `GET /v1/tasks/pending`: Lấy danh sách nhiệm vụ đã nộp chờ duyệt (ảnh chụp, PIN, thời gian).
  - `POST /v1/tasks/{id}/approve`: Duyệt bài -> thưởng sao và gửi tín hiệu mở khóa.
  - `POST /v1/tasks/{id}/reject`: Từ chối -> kèm lý do yêu cầu trẻ làm lại.
- **UI Components**:
  - Tab 1: Bài tập chờ duyệt (Hình ảnh xem trước, tên bài, sao thưởng).
  - Tab 2: Quà chờ đổi (Tên quà, số sao đổi, trẻ xin đổi).

### 3.2 Native Swift Family Controls (`AppDelegate.swift`)
- Đăng ký channel `com.kidtime.app/blocking`:
  ```swift
  import FamilyControls
  import ManagedSettings

  @objc class AppDelegate: FlutterAppDelegate {
    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
      let controller = window?.rootViewController as! FlutterViewController
      let blockingChannel = FlutterMethodChannel(name: "com.kidtime.app/blocking", binaryMessenger: controller.binaryMessenger)
      
      blockingChannel.setMethodCallHandler { (call, result) in
        if call.method == "syncBlockedApps" {
          result(true)
        } else if call.method == "setBlockingEnabled" {
          result(true)
        } else {
          result(FlutterMethodNotImplemented)
        }
      }
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
  }
  ```

---

## 4. Hướng dẫn Đăng ký Firebase (Cho Production)

Khi đưa ứng dụng lên App Store / Google Play, bạn chỉ cần thực hiện 2 bước đơn giản trên Firebase Console:
1. Vào **Firebase Console** -> Tạo project `KidTime`.
2. Tải file **`google-services.json`** đặt vào `mobile/android/app/` và file **`GoogleService-Info.plist`** đặt vào `mobile/ios/Runner/`.

---

## 5. Kiểm thử & Xác minh
- Chạy unit tests cho `ParentRepository`.
- Chạy widget tests cho `ParentApprovalScreen`.
- Đảm bảo toàn bộ test suite `flutter test` và `php artisan test` pass 100%.
