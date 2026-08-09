# KidTime — Kế Hoạch Kiểm Thử Toàn Bộ Hệ Thống (Master System Test Plan)

Tài liệu thiết kế chi tiết toàn bộ Test Case kiểm thử hệ thống KidTime, bao phủ 3 tầng:
- **Tầng 1**: Backend Laravel API (PHPUnit Feature + Unit Tests)
- **Tầng 2**: Web Dashboard Phụ huynh (Inertia Vue — Laravel Feature Tests)
- **Tầng 3**: Mobile App Trẻ em (Flutter Widget + Integration Tests)

---

## Module 1: Xác Thực & Quản Lý Gia Đình (Auth & Family Management)

### 1.1 Backend API Tests (`tests/Feature/Api/AuthApiTest.php`)

| # | Test Case | Mô Tả | Input | Expected |
|---|-----------|--------|-------|----------|
| TC-1.1 | Đăng ký Phụ huynh thành công | POST `/v1/auth/register` | `{name, email, password, password_confirmation, family_name, family_pin}` | 201, trả về `token` + `family.id` |
| TC-1.2 | Đăng ký trùng email | POST `/v1/auth/register` với email đã tồn tại | Email trùng | 422, lỗi validation `email already taken` |
| TC-1.3 | Đăng ký thiếu trường bắt buộc | POST `/v1/auth/register` thiếu `family_pin` | Thiếu trường | 422, lỗi validation |
| TC-1.4 | PIN gia đình không đúng 4 chữ số | POST `/v1/auth/register` với `family_pin: "12"` | PIN sai định dạng | 422, `pin must be 4 digits` |
| TC-1.5 | Đăng nhập Phụ huynh thành công | POST `/v1/auth/login` | `{email, password}` hợp lệ | 200, trả về `token` |
| TC-1.6 | Đăng nhập sai mật khẩu | POST `/v1/auth/login` sai password | Password sai | 401, `Invalid credentials` |
| TC-1.7 | Xác minh PIN gia đình | POST `/v1/pin/verify` | `{family_id, pin}` đúng | 200, `status: true` |
| TC-1.8 | Xác minh PIN sai | POST `/v1/pin/verify` | PIN sai | 200, `status: false` |
| TC-1.9 | Đăng nhập trẻ em qua PIN | POST `/v1/auth/child-login` | `{family_id, pin}` | 200, danh sách trẻ em |
| TC-1.10 | Đăng xuất Phụ huynh | POST `/v1/auth/logout` với Bearer token | Token hợp lệ | 200, token bị thu hồi |
| TC-1.11 | Lấy thông tin `/auth/me` | GET `/v1/auth/me` với token hợp lệ | Token hợp lệ | 200, trả về thông tin user |
| TC-1.12 | Truy cập route bảo vệ không có token | GET `/v1/auth/me` không có header | Không có token | 401, `Unauthenticated` |

### 1.2 Web Dashboard Tests (`tests/Feature/Web/AuthWebTest.php`)

| # | Test Case | Mô Tả | Expected |
|---|-----------|--------|----------|
| TC-1.13 | Truy cập trang Login (guest) | GET `/login` | 200, render trang Login |
| TC-1.14 | Truy cập trang Register (guest) | GET `/register` | 200, render trang Register |
| TC-1.15 | Đăng ký web và redirect Dashboard | POST `/register` với dữ liệu hợp lệ | 302 redirect `/dashboard` |
| TC-1.16 | Đăng nhập web và redirect Dashboard | POST `/login` với email/password đúng | 302 redirect `/dashboard` |
| TC-1.17 | Đăng nhập web sai mật khẩu | POST `/login` sai password | 302 back + error flash |
| TC-1.18 | Truy cập Dashboard khi chưa đăng nhập | GET `/dashboard` khi guest | 302 redirect `/login` |

### 1.3 Mobile Widget Tests (`test/auth/`)

| # | Test Case | Mô Tả | Expected |
|---|-----------|--------|----------|
| TC-1.19 | SplashScreen hiển thị subtitle | Mount `KidTimeApp` | Hiện text `"Nhiệm vụ nhỏ · Niềm vui to"` |
| TC-1.20 | SplashScreen auto-redirect sau 2.5s | Chờ 3 giây | Chuyển sang `/role-selection` |
| TC-1.21 | RoleSelectionScreen hiển thị 2 vai trò | Mount `RoleSelectionScreen` | Hiện "Bé yêu" và "Bố mẹ" |
| TC-1.22 | ChildLoginScreen nhập PIN 4 số | Nhập 4 số bất kỳ | Navigate sang `/home` |
| TC-1.23 | ChildLoginScreen xóa PIN | Nhập 2 số rồi bấm xóa | PIN còn 1 ký tự |

---

## Module 2: Quản Lý Trẻ Em & Thú Cưng (Children & Pet Management)

### 2.1 Backend API Tests (`tests/Feature/Api/ChildApiTest.php`)

| # | Test Case | Mô Tả | Expected |
|---|-----------|--------|----------|
| TC-2.1 | Tạo hồ sơ trẻ em | POST `/v1/children` với `{name, age, pet_species}` | 201, trả về `child.id` + `pet.species` |
| TC-2.2 | Tạo trẻ em với loài thú cưng khác nhau | `pet_species: "cat" / "dog" / "dinosaur" / "rabbit"` | 201, pet đúng loài |
| TC-2.3 | Danh sách trẻ em của gia đình | GET `/v1/children` | 200, mảng trẻ em thuộc `family_id` |
| TC-2.4 | Lấy hồ sơ trẻ em | GET `/v1/children/{id}/profile` | 200, trả về name, stars, pet, streak |
| TC-2.5 | Mở khóa skin thú cưng (đủ Sao) | POST `/v1/children/{id}/pet/skin` + `{skin_name, price}` | `status: true`, trừ Sao + skin active |
| TC-2.6 | Mở khóa skin thú cưng (thiếu Sao) | Bé có 0 Sao, mua skin 10 Sao | `status: false`, `Not enough stars` |
| TC-2.7 | Xóa trẻ em (Web Dashboard) | DELETE `/children/{id}` trên web | 302 redirect + bé bị xóa |

### 2.2 Domain Unit Tests (`tests/Unit/Domain/ChildDomainTest.php`)

| # | Test Case | Mô Tả | Expected |
|---|-----------|--------|----------|
| TC-2.8 | `awardStars()` cộng Sao và tiến hóa Pet | Cộng 150 Sao cho bé | `totalStars=150`, pet stage = `teen` |
| TC-2.9 | `spendStars()` trừ Sao đổi quà | Bé có 20 Sao, chi 15 | `availableStars=5`, return `true` |
| TC-2.10 | `spendStars()` không đủ Sao | Bé có 5 Sao, chi 10 | Return `false`, Sao không đổi |
| TC-2.11 | `getRank()` trả về rank đúng | 0→bronze, 100→silver, 300→gold, 700→platinum, 1500→diamond | Đúng rank |
| TC-2.12 | `updateStreak()` chuỗi liên tục | Làm bài ngày liên tục | `streakDays` tăng +1 mỗi ngày |
| TC-2.13 | `checkStreakExpiry()` reset khi gián đoạn | Bỏ lỡ 2 ngày | `streakDays = 0` |
| TC-2.14 | Pet `syncStageFromStars()` tiến hóa | 0→baby, 50→teen, 200→adult, 500→legend | Stage đúng ngưỡng |
| TC-2.15 | Pet `unlockSkin()` mở khóa skin mới | Unlock `"robot"` | `unlockedSkins = ["default", "robot"]` |
| TC-2.16 | Pet `unlockSkin()` trùng lặp | Unlock `"default"` lần 2 | Vẫn chỉ 1 `"default"` |

### 2.3 Mobile Widget Tests (`test/pet/`)

| # | Test Case | Mô Tả | Expected |
|---|-----------|--------|----------|
| TC-2.17 | PetSelectionScreen hiển thị 4 loài | Mount `PetSelectionScreen` | Hiện Mèo Mimi, Chó Rex, Rồng Spark, Thỏ Miffy |
| TC-2.18 | PetScreen cho ăn trừ 2 Sao | Bấm "Cho ăn (-2 ⭐)" | Sao 45→43, Độ no 60%→75% |
| TC-2.19 | PetScreen chọc nhột phản hồi | Bấm "Chọc nhột" | Hiện `"Hahaha, nhột quá!"` |
| TC-2.20 | StoreScreen hiển thị & mua skin | Bấm mua Mèo Robot 15 Sao | Sao 45→30, skin unlocked |

---

## Module 3: Vòng Đời Nhiệm Vụ (Task Lifecycle)

### 3.1 Backend API Tests (`tests/Feature/Api/TaskApiTest.php`)

| # | Test Case | Mô Tả | Expected |
|---|-----------|--------|----------|
| TC-3.1 | Lấy danh sách template nhiệm vụ | GET `/v1/tasks/templates` | 200, 12 templates |
| TC-3.2 | Tạo nhiệm vụ tùy chỉnh (photo) | POST `/v1/tasks` với `verification_mode: "photo"` | 201, trả về `task.id` |
| TC-3.3 | Tạo nhiệm vụ tùy chỉnh (pin) | POST `/v1/tasks` với `verification_mode: "pin"` | 201 |
| TC-3.4 | Tạo nhiệm vụ tùy chỉnh (auto) | POST `/v1/tasks` với `verification_mode: "auto"` | 201 |
| TC-3.5 | Danh sách nhiệm vụ theo gia đình | GET `/v1/tasks` | 200, tasks thuộc `family_id` |
| TC-3.6 | Xóa nhiệm vụ | DELETE `/v1/tasks/{id}` | 200, task bị xóa |
| TC-3.7 | Lấy nhiệm vụ hôm nay cho bé | GET `/v1/children/{id}/tasks/today` | 200, mảng tasks kèm status |
| TC-3.8 | Nộp bài nhiệm vụ (photo) | POST `/v1/task-logs` + `{task_id, child_id}` | 201, `status: "submitted"` |
| TC-3.9 | Nộp bài nhiệm vụ (auto-approve) | POST `/v1/task-logs` với task `verification_mode: "auto"` | 201, `status: "approved"` |

### 3.2 Web Dashboard Tests (`tests/Feature/Web/TaskWebTest.php`)

| # | Test Case | Mô Tả | Expected |
|---|-----------|--------|----------|
| TC-3.10 | Trang danh sách nhiệm vụ | GET `/tasks` khi đăng nhập | 200, render danh sách tasks |
| TC-3.11 | Trang tạo nhiệm vụ mới | GET `/tasks/create` | 200, render form tạo task |
| TC-3.12 | Tạo nhiệm vụ qua web form | POST `/tasks` với dữ liệu hợp lệ | 302 redirect `/tasks` |
| TC-3.13 | Xóa nhiệm vụ qua web | DELETE `/tasks/{id}` | 302 redirect + task xóa |

### 3.3 Mobile Widget Tests (`test/tasks/`)

| # | Test Case | Mô Tả | Expected |
|---|-----------|--------|----------|
| TC-3.14 | TaskListScreen hiển thị tiêu đề | Mount `TaskListScreen` | Hiện `"📋 Nhiệm vụ của con"` |
| TC-3.15 | TaskListScreen phân loại theo Tab | Chuyển tab "Việc nhà", "Học tập" | Lọc đúng category |
| TC-3.16 | TaskListScreen tải dữ liệu từ API | `_loadTasksFromBackend()` | Hiện tasks từ Backend, không mock |
| TC-3.17 | TaskDetailScreen hiển thị chi tiết | Mount với `taskData` | Hiện title, stars, verification mode |
| TC-3.18 | TaskTimerScreen đếm ngược 25:00 | Mount `TaskTimerScreen` | Hiện `"25:00"` và nút `"Bắt đầu học"` |
| TC-3.19 | TaskTimerScreen đếm ngược khi bấm Start | Bấm "Bắt đầu học" rồi pump 1s | Hiện `"24:59"` |

---

## Module 4: Duyệt Bài & Tặng Sao (Approval & Stars)

### 4.1 Backend API Tests (`tests/Feature/Api/ApprovalApiTest.php`)

| # | Test Case | Mô Tả | Expected |
|---|-----------|--------|----------|
| TC-4.1 | Danh sách bài chờ duyệt | GET `/v1/task-logs/pending` | 200, mảng logs `status: "submitted"` |
| TC-4.2 | Duyệt bài + cộng Sao | POST `/v1/task-logs/{id}/approve` kèm `{sticker}` | 200, `status: "approved"`, child `totalStars` tăng |
| TC-4.3 | Từ chối bài | POST `/v1/task-logs/{id}/reject` | 200, `status: "rejected"`, Sao không đổi |
| TC-4.4 | Duyệt bài không tồn tại | POST `/v1/task-logs/999/approve` | 404 |

### 4.2 Web Dashboard Tests (`tests/Feature/Web/PendingWebTest.php`)

| # | Test Case | Mô Tả | Expected |
|---|-----------|--------|----------|
| TC-4.5 | Trang chờ duyệt hiển thị bài nộp | GET `/pending` | 200, render danh sách bài submitted |
| TC-4.6 | Duyệt bài 1-chạm qua web | POST `/pending/{id}/approve` | 302 redirect, bài chuyển approved |
| TC-4.7 | Từ chối bài qua web | POST `/pending/{id}/reject` | 302 redirect, bài chuyển rejected |

### 4.3 Mobile Widget Tests (`test/parent/`)

| # | Test Case | Mô Tả | Expected |
|---|-----------|--------|----------|
| TC-4.8 | ParentApprovalScreen hiển thị tiêu đề | Mount `ParentApprovalScreen` | Hiện `"Phụ Huynh — Duyệt Bài 👨‍👩‍👧"` |
| TC-4.9 | ParentApprovalScreen tải bài chờ duyệt từ API | `_loadPendingTasks()` | Hiện danh sách bài `submitted` từ Backend |

---

## Module 5: Đổi Quà & Quản Lý Phần Thưởng (Rewards & Redemption)

### 5.1 Backend API Tests (`tests/Feature/Api/RewardApiTest.php`)

| # | Test Case | Mô Tả | Expected |
|---|-----------|--------|----------|
| TC-5.1 | Tạo phần thưởng mới | POST `/v1/rewards` + `{title, stars_required}` | 201, trả về `reward.id` |
| TC-5.2 | Danh sách phần thưởng gia đình | GET `/v1/rewards` | 200, mảng rewards thuộc `family_id` |
| TC-5.3 | Đổi quà (đủ Sao) | POST `/v1/rewards/{id}/redeem` + `{child_id}` | 200, `remaining_stars` giảm |
| TC-5.4 | Đổi quà (thiếu Sao) | Bé có 5 Sao, quà cần 50 | 422, `"Không đủ Sao"` |
| TC-5.5 | Đổi quà không tồn tại | POST `/v1/rewards/999/redeem` | 404 |

### 5.2 Web Dashboard Tests (`tests/Feature/Web/RewardWebTest.php`)

| # | Test Case | Mô Tả | Expected |
|---|-----------|--------|----------|
| TC-5.6 | Trang danh sách phần thưởng | GET `/rewards` | 200, render rewards |
| TC-5.7 | Tạo phần thưởng qua web | POST `/rewards` với dữ liệu hợp lệ | 302 redirect |
| TC-5.8 | Xóa phần thưởng qua web | DELETE `/rewards/{id}` | 302 redirect |

### 5.3 Mobile Widget Tests (`test/rewards/`)

| # | Test Case | Mô Tả | Expected |
|---|-----------|--------|----------|
| TC-5.9 | RewardListScreen hiển thị tiêu đề | Mount `RewardListScreen` | Hiện `"Cửa Hàng Đổi Quà 🎁"` |
| TC-5.10 | RewardListScreen tải danh sách quà từ API | `_loadRewards()` | Hiện rewards từ `/v1/rewards` |

---

## Module 6: Gamification — Bảng Xếp Hạng, Timer, Gallery, Settings

### 6.1 Mobile Widget Tests (`test/gamification/`)

| # | Test Case | Mô Tả | Expected |
|---|-----------|--------|----------|
| TC-6.1 | FamilyLeaderboardScreen hiển thị bục vinh quang | Mount `FamilyLeaderboardScreen` | Hiện `"Bảng Xếp Hạng Thi Đua 🏆"`, 🥇🥈🥉 |
| TC-6.2 | PraiseGalleryScreen hiển thị feed ảnh | Mount `PraiseGalleryScreen` | Hiện `"Góc Kỷ Niệm & Lời Khen 💖"`, ảnh + sticker |
| TC-6.3 | NotificationCenterScreen hiển thị thông báo | Mount `NotificationCenterScreen` | Hiện `"Thông Báo 🔔"`, nội dung thông báo |
| TC-6.4 | ProfileSettingsScreen hiển thị cài đặt | Mount `ProfileSettingsScreen` | Hiện toggle Sound FX, Thông báo |
| TC-6.5 | StatsScreen hiển thị streak & biểu đồ | Mount `StatsScreen` | Hiện `"Báo Cáo & Streak 🔥"`, `"5 Ngày"` |
| TC-6.6 | HomeScreen hiển thị thú cưng và thống kê | Mount `HomeScreen` | Hiện `"Xin chào, Nam!"`, `"Mimi đang vui vẻ"`, `"45 Sao"` |

---

## Module 7: Tích Hợp Mobile ↔ Backend (Mobile Integration & Services)

### 7.1 Backend API Tests (`tests/Feature/Api/MobileIntegrationTest.php`)

| # | Test Case | Mô Tả | Expected |
|---|-----------|--------|----------|
| TC-7.1 | Đăng ký FCM token | POST `/v1/notifications/register` + `{token, device_type}` | 200 |
| TC-7.2 | Đồng bộ danh sách app bị chặn | POST `/v1/blocking/apps` + `{apps: [...]}` | 200 |
| TC-7.3 | Analytics tuần cho bé | GET `/v1/analytics/weekly/{childId}` | 200, dữ liệu biểu đồ tuần |

### 7.2 Mobile Service Tests (`test/services/`)

| # | Test Case | Mô Tả | Expected |
|---|-----------|--------|----------|
| TC-7.4 | `AppBlockingService` xử lý plugin thiếu | Gọi `syncBlockedApps()` trong test env | Return `true` gracefully |
| TC-7.5 | `OfflineSyncService` lưu queue offline | Ghi action khi không có mạng | Queue được lưu local |
| TC-7.6 | `OfflineSyncService` đồng bộ khi có mạng | Khôi phục kết nối | Queue replay thành công |

---

## Module 8: Kiểm Thử Tích Hợp E2E Khép Kín (End-to-End Integration)

### 8.1 E2E Backend Full Lifecycle (`tests/Feature/Api/E2EFullLifecycleTest.php`)

| # | Test Case | Mô Tả | Expected |
|---|-----------|--------|----------|
| TC-8.1 | Quy trình đầy đủ: Đăng ký → Tạo bé → Giao bài → Nộp bài → Duyệt → Cộng Sao → Đổi quà | Chuỗi 10 API calls liên tục | Mỗi bước trả về đúng status và dữ liệu lan truyền |
| TC-8.2 | Nhiều bé trong 1 gia đình | Tạo 2 bé, giao bài khác nhau, duyệt riêng | Sao và streak độc lập giữa 2 bé |
| TC-8.3 | Duyệt bài trên Web → Mobile status update | Duyệt bài qua POST `/pending/{id}/approve` → GET `/v1/children/{id}/tasks/today` | Task status = `"approved"` |
| TC-8.4 | Mua skin → Profile phản ánh | POST skin purchase → GET profile | `active_skin` thay đổi, `available_stars` giảm |

---

## Tổng Kết

| Tầng | Số Test Case | Framework |
|------|-------------|-----------|
| Backend API (PHPUnit Feature) | 32 | `php artisan test` |
| Web Dashboard (PHPUnit Feature) | 14 | `php artisan test` |
| Domain Logic (PHPUnit Unit) | 9 | `php artisan test` |
| Mobile Widget (Flutter) | 19 | `flutter test` |
| Mobile Integration E2E | 4 | `flutter test` / manual |
| **TỔNG CỘNG** | **78 Test Cases** | |

---

## Lệnh Chạy Kiểm Thử

```bash
# Backend (tất cả PHP tests)
docker compose exec -T app php artisan test

# Mobile (tất cả Flutter widget tests)
cd mobile && flutter test

# Web production build verification
cd backend && npm run build
```
