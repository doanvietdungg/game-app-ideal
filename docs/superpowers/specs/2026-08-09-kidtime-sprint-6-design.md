# KidTime Mobile & Backend — Sprint 6 Design Spec

**Ngày:** 2026-08-09  
**Trạng thái:** Approved  
**Phạm vi:** Audio FX Engine (`AudioService`), Praise Gallery Screen (`/praise-gallery`), Task Photo Feed with Parent Stickers & Comments

---

## 1. Mục tiêu

1. **Bộ Âm Thanh Sống Động (`AudioService`)**:
   - Quản lý và phát các hiệu ứng âm thanh tương tác:
     - `playFeedSound()`: Tiếng ăn ngon miệng.
     - `playTickleSound()`: Tiếng vui vẻ khúc khích.
     - `playStarSound()`: Tiếng ting-ting nhận sao.
     - `playFanfareSound()`: Tiếng nhạc ăn mừng khi tăng cấp/hoàn thành bài.
2. **Nhật Ký Ảnh & Lời Khen (`PraiseGalleryScreen`)**:
   - Màn hình góc lưu niệm (`/praise-gallery`) hiển thị danh sách toàn bộ ảnh bài tập trẻ đã chụp và nộp.
   - Thẻ hiển thị hình ảnh, tên nhiệm vụ, số sao thưởng, nhãn dán sticker khen thưởng từ bố mẹ (*"Xuất sắc!"*, *"Siêu sạch vè!"*), và lời nhắn khen ngợi.

---

## 2. Kiến trúc & Cấu trúc Thư mục

```
mobile/lib/
├── core/
│   ├── services/
│   │   └── audio_service.dart                 # Audio FX synthesizer & player
├── features/
│   ├── gallery/
│   │   ├── data/
│   │   │   └── gallery_repository.dart        # GET /v1/gallery/praises
│   │   └── presentation/
│   │       └── praise_gallery_screen.dart     # Màn hình nhật ký ảnh & lời khen
```

---

## 3. Chi tiết Kỹ thuật

### 3.1 `AudioService`
- Cung cấp giao diện phát âm thanh không chặn (non-blocking audio player).
- Tích hợp sẵn hiệu ứng âm thanh synth linh hoạt trên mọi nền tảng (iOS, Android, Test environment).

### 3.2 `PraiseGalleryScreen` (`/praise-gallery`)
- API Model `PraiseItem`: `id`, `taskTitle`, `photoUrl`, `starsEarned`, `stickerEmoji`, `stickerText`, `parentComment`, `completedAt`.
- UI Grid/List hiển thị thẻ ảnh vuông bo góc tròn, gắn sticker ruy băng màu cam pastel, hiển thị lời nhắn khen ngợi ấm áp từ bố mẹ.

---

## 4. Kiểm thử & Xác minh
- Viết Widget Test cho `PraiseGalleryScreen` và `AudioService`.
- Đảm bảo 100% Flutter test và Laravel test pass.
