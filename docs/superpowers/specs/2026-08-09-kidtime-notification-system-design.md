# KidTime Mobile & Backend — Full Notification System Design Spec

**Ngày:** 2026-08-09  
**Trạng thái:** Approved  
**Phạm vi:** In-App Real-time Banner, Notification Center Screen (`/notifications`), Local Notification Scheduler, Backend Notification Event Broadcast

---

## 1. Mục tiêu

Xây dựng hệ thống thông báo đa kênh toàn diện cho KidTime:
1. **Banner Thông Báo Real-time Trong App (`NotificationBannerWidget`)**:
   - Slide & Fade in animation trượt từ mép trên màn hình xuống khi có sự kiện duyệt bài/nhận sao/nhắc nhở thú cưng.
   - Nhấp vào banner tự động điều hướng tới màn hình tương ứng.
2. **Màn hình Trung tâm Thông báo (`NotificationCenterScreen`)**:
   - Thêm nút Quả chuông 🔔 trên AppBar (kèm badge đỏ số tin chưa đọc).
   - Route `/notifications`: Xem lịch sử lời nhắn, bài duyệt, thưởng sao, nhắc nhở.
3. **Bộ Lập Lịch Nhắc Nhở Tự Động (`NotificationService`)**:
   - Đăng ký kênh local notification nhắc nhở 08:00 (Nhiệm vụ sáng) và 17:00 (Cho thú cưng ăn).
4. **Backend Broadcaster (`TaskApprovedNotification`)**:
   - Tự động tạo bản ghi Notification khi bố mẹ duyệt bài trên Web hoặc Mobile.

---

## 2. Kiến trúc & Cấu trúc Thư mục

```
mobile/lib/
├── core/
│   ├── services/
│   │   └── notification_service.dart             # FCM payload parser & scheduler
│   └── widgets/
│       └── notification_banner.dart              # In-App animated top notification banner
├── features/
│   ├── notifications/
│   │   ├── data/
│   │   │   └── notification_repository.dart      # GET /v1/notifications
│   │   └── presentation/
│   │       └── notification_center_screen.dart   # Màn hình danh sách thông báo
```

---

## 3. Chi tiết Kỹ thuật

### 3.1 `NotificationRepository` & `NotificationCenterScreen`
- API Model `NotificationItem`: `id`, `title`, `body`, `type` (`approval`, `star_reward`, `pet_hunger`, `reminder`), `isRead`, `createdAt`.
- Endpoint: `GET /v1/notifications` (kèm fallback mock data).
- UI: Danh sách dạng Card bo góc, có icon tương ứng theo loại thông báo (`🎉`, `⭐`, `🍖`, `🔔`).

### 3.2 `NotificationBannerWidget`
- SlideTransition trượt từ y: -100px xuống y: 0px trong 300ms.
- Tự động ẩn đi sau 4 giây hoặc khi vuốt lên.

### 3.3 `NotificationService`
- Khởi tạo channel `kidtime_channel`.
- Hàm `showInAppBanner(title, body, route)`.

---

## 4. Kiểm thử & Xác minh
- Viết Widget Test cho `NotificationCenterScreen` và `NotificationBannerWidget`.
- Đảm bảo 100% Flutter test và Laravel test pass.
