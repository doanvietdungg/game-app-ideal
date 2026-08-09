# KidTime Mobile & Backend — Sprint 8 Design Spec

**Ngày:** 2026-08-09  
**Trạng thái:** Approved  
**Phạm vi:** Family Leaderboard Screen (`/family/leaderboard`), Weekly Family Challenge Card, Leaderboard Repository

---

## 1. Mục tiêu

1. **Bảng Xếp Hạng Thi Đua Gia Đình (`FamilyLeaderboardScreen`)**:
   - Route `/family/leaderboard` hiển thị thứ hạng thi đua giữa các bé trong gia đình.
   - Bục vinh quang Podium 🥇 (Hạng 1), 🥈 (Hạng 2), 🥉 (Hạng 3) với avatar, tổng số Sao kiếm được trong tuần và độ dài Streak.
2. **Thử Thách Tuần Của Bố Mẹ (Weekly Family Challenge Card)**:
   - Thẻ hiển thị mục tiêu chung của cả gia đình (ví dụ: *"Cả nhà cùng đọc 50 trang sách"*).
   - Thanh tiến trình phần trăm hoàn thành (ProgressBar) và danh sách đóng góp của từng bé.

---

## 2. Kiến trúc & Cấu trúc Thư mục

```
mobile/lib/
├── features/
│   ├── leaderboard/
│   │   ├── data/
│   │   │   └── leaderboard_repository.dart       # GET /v1/family/leaderboard
│   │   └── presentation/
│   │       └── family_leaderboard_screen.dart    # Màn hình bảng xếp hạng thi đua
```

---

## 3. Chi tiết Kỹ thuật

### 3.1 `LeaderboardRepository`
- Model `LeaderboardMember`: `id`, `name`, `avatarEmoji`, `rank`, `weeklyStars`, `streakDays`.
- Model `FamilyChallenge`: `title`, `currentProgress`, `targetProgress`, `rewardDescription`.
- Endpoint: `GET /v1/family/leaderboard`.

### 3.2 `FamilyLeaderboardScreen` (`/family/leaderboard`)
- Header: Bục vinh quang 🥇 🥈 🥉 xếp theo thứ tự chiều cao bục.
- Challenge Card: Thẻ tiến trình thử thách gia đình kèm nút "Đóng góp bài làm".
- List: Danh sách thứ hạng chi tiết bên dưới bục.

---

## 4. Kiểm thử & Xác minh
- Viết Widget Test cho `FamilyLeaderboardScreen`.
- Đảm bảo 100% Flutter test và Laravel test pass.
