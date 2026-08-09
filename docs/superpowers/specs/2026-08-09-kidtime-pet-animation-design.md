# KidTime Mobile — Interactive Pet Animation & Navigation Design Spec

**Ngày:** 2026-08-09  
**Trạng thái:** Approved  
**Phạm vi:** Interactive Physics Pet Engine (`CustomPainter` + Drag-and-Drop + Particles) & App Bottom Navigation Integration

---

## 1. Mục tiêu

Nâng cấp trải nghiệm tương tác thú cưng ảo lên mức độ sinh động cao:
1. **Thú cưng tương tác vật lý sống động (`PetPhysicsCanvas`)**:
   - Dùng Flutter `CustomPainter` vẽ vector sắc nét.
   - Con ngươi và đầu tự động xoay theo ngón tay/con trỏ (`Eye & Head Tracking`).
   - Phản ứng chạm thông minh: pat head (lim dim nhả tim 💖), tickle belly (nảy lò xo cười 😸), poke nose (hắt hơi nảy lùi).
   - Đàn hồi vật lý (Squish & Stretch physics) với `SpringSimulation`.
2. **Kéo thả đồ ăn tương tác (`DragAndDropFood`)**:
   - Bé kéo đùi gà 🍖 / bình sữa 🍼 tự do trên màn hình.
   - Miệng thú cưng tự động há to hút đồ ăn (Magnet Effect) khi đồ ăn lại gần (<80px).
   - Tung hiệu ứng hạt bắn nổ pháo hoa sao ⭐ khi nuốt đồ ăn thành công.
3. **Thanh điều hướng chính (`AppBottomNavBar`)**:
   - Tích hợp Bottom Navigation Bar 4 tab vào `HomeScreen`: 🏠 Trang chủ, 📋 Nhiệm vụ, 🎁 Đổi quà, 📊 Thống kê.

---

## 2. Kiến trúc & Cấu trúc Thư mục

```
mobile/lib/
├── features/
│   ├── pet/
│   │   ├── presentation/
│   │   │   ├── pet_screen.dart             # Pet screen chính kết nối canvas
│   │   │   ├── widgets/
│   │   │   │   ├── pet_physics_canvas.dart # CustomPainter vẽ vector & biến dạng nảy
│   │   │   │   ├── draggable_food.dart     # Widget kéo thả đồ ăn & lực hút magnet
│   │   │   │   └── particle_overlay.dart   # Hiệu ứng hạt bắn nổ sao/tim
│   ├── home/
│   │   └── presentation/
│   │       └── home_screen.dart            # Cập nhật Bottom Navigation Bar 4 tab
```

---

## 3. Chi tiết Kỹ thuật

### 3.1 `PetPhysicsCanvas`
- Tùy biến `CustomPainter`:
  - Thân thú cưng: Hình oval viền bo mềm với màu sắc gradient sống động.
  - Tai & Đuôi: Co giật đung đưa nhẹ theo chu kỳ `AnimationController`.
  - Mắt & Con ngươi: Tính toán offset con ngươi theo vị trí `touchOffset`:
    ```dart
    final dx = (touchOffset.dx - center.dx).clamp(-12.0, 12.0);
    final dy = (touchOffset.dy - center.dy).clamp(-8.0, 8.0);
    ```
  - Biểu cảm: Mắt mở to, Mắt nhắm lim dim, Mắt hình trái tim 😍, Mắt >_<.

### 3.2 Kéo thả Đồ ăn (`DraggableFoodItem`)
- Sử dụng `LongPressDraggable` hoặc `GestureDetector`:
  - Cập nhật vị trí đồ ăn khi drag.
  - Tính khoảng cách tới miệng thú cưng: `(foodPos - mouthPos).distance`.
  - Nếu `distance < 80.0`: Kích hoạt trạng thái `isMouthOpen = true`.
  - Nhả tay khi `distance < 80.0`: Kích hoạt hàm `_feedPet()`, kích nổ ParticleOverlay và reset đồ ăn.

### 3.3 Particle Overlay (`ParticleOverlay`)
- Quản lý mảng `List<Particle>` (x, y, vx, vy, opacity, scale, emoji).
- Cập nhật hạt bằng `Ticker` hoặc `AnimationController` liên tục 60 FPS.

---

## 4. Kiểm thử & Xác minh
- Chạy `flutter test` đảm bảo tất cả widget tests (PetScreen, HomeScreen, Navigation, Drag test) đều passed 100%.
