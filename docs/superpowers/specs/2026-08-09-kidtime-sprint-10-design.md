# KidTime Mobile & Backend — Sprint 10 Design Spec

**Ngày:** 2026-08-09  
**Trạng thái:** Approved  
**Phạm vi:** Pomodoro Focus Timer Screen (`/tasks/timer`), Studying Pet Mode, Bonus Stars Celebration

---

## 1. Mục tiêu

1. **Đồng Hồ Tập Trung Học Tập Pomodoro (`TaskTimerScreen`)**:
   - Route `/tasks/timer` cung cấp bộ đếm ngược thời gian tập trung 25 phút (hoặc tùy chỉnh 15/25/45 phút).
   - Nút Tạm dừng / Bắt đầu / Đổi mốc thời gian.
2. **Thú Cưng Đeo Kính Học Cùng Bé (`PetPhysicsCanvas`)**:
   - Expression mới: `'studying'` (thú cưng đeo kính tri thức 👓, gật gù đọc sách).
3. **Phần Thưởng Tăng Cường (+10 ⭐ Bonus)**:
   - Khi hết giờ đếm ngược, phát nhạc ăn mừng `playFanfareSound()` và cộng thưởng +10 Sao vào quỹ của bé.

---

## 2. Kiến trúc & Cấu trúc Thư mục

```
mobile/lib/
├── features/
│   ├── tasks/
│   │   └── presentation/
│   │       └── task_timer_screen.dart        # Màn hình đồng hồ đếm giờ Pomodoro
```

---

## 3. Chi tiết Kỹ thuật

### 3.1 `TaskTimerScreen` (`/tasks/timer`)
- `AnimationController` đếm ngược theo giây.
- Hiển thị tiến trình hình tròn `CircularProgressIndicator`.
- Tự động gọi `AudioService().playFanfareSound()` khi hoàn thành phiên.

---

## 4. Kiểm thử & Xác minh
- Viết Widget Test cho `TaskTimerScreen`.
- Đảm bảo 100% Flutter test và Laravel test pass.
