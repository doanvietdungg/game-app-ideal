# KidTime Mobile & Backend — Sprint 7 Design Spec

**Ngày:** 2026-08-09  
**Trạng thái:** Approved  
**Phạm vi:** Multi-Species Vector Pet Physics (`PetPhysicsCanvas`), Pet Selection Screen (`/pet/select`), Achievement Badges System

---

## 1. Mục tiêu

1. **Bộ Thú Cưng Đa Loài Vector (Multi-Species Physics)**:
   - Nâng cấp `PetPhysicsCanvas` hỗ trợ render 4 loài thú cưng khác nhau:
     - 🐱 **Mèo Mimi**: Đôi tai tam giác nhọn, mắt tròn theo dõi ngón tay, má hồng.
     - 🐶 **Chó Rex**: Đôi tai cụp dễ thương, cái mũi đen ngộ nghĩnh.
     - 🐉 **Rồng Spark**: Đôi sừng vàng, cánh nhỏ vỗ rung rinh, mắt hiền lành.
     - 🐰 **Thỏ Miffy**: Đôi tai dài thỏn thót cử động nhấp nhô.
2. **Màn hình Chọn Thú Cưng (`PetSelectionScreen` - `/pet/select`)**:
   - Giao diện chọn loài thú cưng đồng hành với xem trước hoạt hình nảy sống động.
3. **Hệ Thống Huy Chương Thành Tích (Achievement Badges System)**:
   - Trang trí bộ sưu tập huy chương danh giá (*"Chiến thần Streak 7 Ngày"*, *"Dũng sĩ Đọc sách"*, *"Ngôi sao Chăm chỉ"*) tại màn hình Thống kê.

---

## 2. Kiến trúc & Cấu trúc Thư mục

```
mobile/lib/
├── features/
│   ├── pet/
│   │   ├── presentation/
│   │   │   ├── pet_selection_screen.dart     # Màn hình chọn loài thú cưng
│   │   │   └── widgets/
│   │   │       └── pet_physics_canvas.dart    # Thêm parameter species (cat, dog, dragon, rabbit)
│   ├── stats/
│   │   └── presentation/
│   │       └── widgets/
│   │           └── badge_grid_card.dart      # Thẻ huy chương thành tích
```

---

## 3. Chi tiết Kỹ thuật

### 3.1 `PetPhysicsCanvas` (`species` parameter)
- Parameter: `final String species;` ('cat' | 'dog' | 'dragon' | 'rabbit').
- Render chi tiết tai, mũi, cánh và đuôi đặc trưng theo loài bằng Flutter `CustomPainter`.

### 3.2 `PetSelectionScreen` (`/pet/select`)
- Grid chọn 4 loài thú cưng kèm thông số sở thích và câu nói đặc trưng của từng loài.
- Nút "Chọn làm thú cưng chính".

---

## 4. Kiểm thử & Xác minh
- Viết Widget Test cho `PetSelectionScreen` và tính năng switch species.
- Đảm bảo 100% Flutter test và Laravel test pass.
