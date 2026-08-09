# KidTime Mobile App — Sprint 4 Design Spec

**Ngày:** 2026-08-09  
**Trạng thái:** Approved  
**Phạm vi:** Mobile App Sprint 4 — Rewards, Stats & Analytics, Local Notifications, Native App Blocking Bridge

---

## 1. Mụ c tiêu Sprint 4

Triển khai 3 tính năng cuối cùng cho ứng dụng Flutter Client (KidTime Mobile App):
1. **Phần thưởng & Đổi quà (`RewardScreen`)**: Cho phép trẻ xem danh sách phần thưởng được bố mẹ thiết lập, số dư sao tích lũy, đổi quà và gửi yêu cầu xác nhận.
2. **Thống kê & Chuỗi ngày (`StatsScreen`)**: Hiển thị Streak ngày hoàn thành liên tục, biểu đồ sao tích lũy tuần dùng `fl_chart`, và tổng kết năng suất.
3. **Core Platform Services (`NotificationService` & `AppBlockingService`)**: Khởi tạo thông báo nhắc nhở làm bài/chăm thú cưng cục bộ và kết nối bridge `MethodChannel` với native iOS/Android cho việc khóa ứng dụng giải trí.

---

## 2. Kiến trúc & Cấu trúc Thư mục

```
mobile/lib/
├── core/
│   └── services/
│       ├── notification_service.dart     # Local notifications scheduler
│       └── app_blocking_service.dart     # MethodChannel bridge ('com.kidtime.app/blocking')
├── features/
│   ├── rewards/
│   │   ├── data/
│   │   │   └── reward_repository.dart    # GET /v1/rewards, POST /v1/rewards/{id}/redeem
│   │   └── presentation/
│   │       ├── reward_list_screen.dart   # Màn hình danh sách quà & đổi sao
│   │       └── widgets/
│   │           └── redeem_modal.dart     # Modal xác nhận đổi quà
│   └── stats/
│       ├── data/
│       │   └── stats_repository.dart     # GET /v1/analytics/child
│       └── presentation/
│           ├── stats_screen.dart         # Màn hình báo cáo & biểu đồ sao
│           └── widgets/
│               ├── streak_card.dart      # Widget thẻ hiển thị Streak ngày
│               └── star_chart.dart       # Widget biểu đồ fl_chart
```

---

## 3. Chi tiết Tính năng

### 3.1 Feature Rewards (`/rewards`)
- **API integration**:
  - `GET /v1/rewards`: Lấy danh sách phần thưởng (id, title, description, star_cost, status).
  - `POST /v1/rewards/{id}/redeem`: Gửi yêu cầu đổi phần thưởng.
- **UI Components**:
  - Banner hiển thị sao hiện tại ⭐ của bé.
  - Thẻ phần thưởng: Tên quà, mô tả, số sao cần đổi.
  - Trạng thái nút:
    - *Đổi quà ngay* (khi đủ sao) -> Hiển thị Modal xác nhận.
    - *Chưa đủ sao* (disabled nút + hiển thị "Cần thêm X sao").
    - *Đang chờ duyệt* (sau khi gửi yêu cầu thành công).

### 3.2 Feature Stats (`/stats`)
- **API integration**:
  - `GET /v1/analytics/child`: Lấy thông tin streak, tổng số nhiệm vụ đã hoàn thành, sao tích lũy và mảng thống kê sao theo từng ngày trong tuần.
- **UI Components**:
  - Thẻ Streak: Hiển thị biểu tượng 🔥 và số ngày làm việc liên tục.
  - Biểu đồ `fl_chart`: Cột hiển thị số sao kiếm được từ Thứ 2 đến Chủ Nhật.
  - Thẻ Thống kê tổng quan: Số lượng bài đã xong, tổng sao thu hoạch.

### 3.3 Platform Services (`NotificationService` & `AppBlockingService`)
- **`NotificationService`**:
  - Đăng ký kênh thông báo cục bộ `kidtime_reminders`.
  - Hàm `scheduleDailyTaskReminder()` gửi thông báo nhắc nhở làm nhiệm vụ mỗi ngày lúc 08:00 và 17:00.
- **`AppBlockingService`**:
  - Khai báo `MethodChannel('com.kidtime.app/blocking')`.
  - Cung cấp hàm `syncBlockedApps(List<String> bundleIds)` và `toggleBlocking(bool enabled)`.
  - Tự động fallback safe-no-op trên môi trường simulator/test để không crash ứng dụng.

---

## 4. Kiểm thử & Xác minh
- Viết Unit Tests cho `RewardRepository` và `StatsRepository`.
- Viết Widget Tests cho `RewardListScreen` và `StatsScreen`.
- Đảm bảo tất cả widget test và integration tests trong `mobile/test/` đều chạy thành công (`flutter test`).
