# KidTime Backend API Upgrades — Design Spec
**Ngày:** 2026-08-09  
**Trạng thái:** Draft — chờ review  
**Phạm vi:** Nâng cấp cơ sở dữ liệu, Domain layer, Application layer và Presentation layer (API) để hỗ trợ Mobile App.

---

## 1. Cơ sở dữ liệu (Migrations & Schemas)

Chúng ta cần bổ sung các bảng sau để lưu trữ dữ liệu đặc thù của Mobile App:

### 1.1 Bảng `pet_skins`
Lưu trữ danh sách các skin thú cưng mà mỗi đứa trẻ đã mua/mở khóa.
```php
Schema::create('pet_skins', function (Blueprint $table) {
    $table->id();
    $table->foreignId('pet_id')->constrained('pets')->cascadeOnDelete();
    $table->string('skin_name'); // 'default', 'summer', 'winter', 'special'
    $table->timestamp('unlocked_at');
    $table->timestamps();
    
    $table->unique(['pet_id', 'skin_name']);
});
```

### 1.2 Bảng `reward_redemptions`
Lịch sử đổi phần thưởng của bé.
```php
Schema::create('reward_redemptions', function (Blueprint $table) {
    $table->id();
    $table->foreignId('child_id')->constrained('children')->cascadeOnDelete();
    $table->foreignId('reward_id')->constrained('rewards')->cascadeOnDelete();
    $table->integer('stars_spent');
    $table->timestamp('redeemed_at');
    $table->timestamps();
});
```

### 1.3 Bảng `blocked_apps`
Danh sách các app bị cha mẹ khóa trên điện thoại của con.
```php
Schema::create('blocked_apps', function (Blueprint $table) {
    $table->id();
    $table->foreignId('family_id')->constrained('families')->cascadeOnDelete();
    $table->string('app_bundle_id'); // e.g., 'com.google.ios.youtube'
    $table->string('app_name'); // e.g., 'YouTube'
    $table->timestamps();
    
    $table->unique(['family_id', 'app_bundle_id']);
});
```

### 1.4 Bảng `screen_time_logs`
Ghi nhận lịch sử sử dụng app của trẻ phục vụ cho báo cáo.
```php
Schema::create('screen_time_logs', function (Blueprint $table) {
    $table->id();
    $table->foreignId('child_id')->constrained('children')->cascadeOnDelete();
    $table->string('app_bundle_id');
    $table->integer('duration_seconds');
    $table->date('logged_date');
    $table->timestamps();
});
```

### 1.5 Bảng `fcm_tokens`
Lưu token phục vụ cho việc gửi Push Notification qua Firebase (FCM).
```php
Schema::create('fcm_tokens', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
    $table->string('token')->unique();
    $table->string('device_type'); // 'ios', 'android'
    $table->timestamps();
});
```

---

## 2. Thay đổi tại Domain Layer (DDD)

### 2.1 Entity `Pet`
Bổ sung danh sách skin đã mở khóa và phương thức quản lý skin.
- Properties:
  - `private array $unlockedSkins = []`
- Methods:
  - `public function getUnlockedSkins(): array`
  - `public function unlockSkin(string $skinName): void`
  - `public function changeSkin(string $skinName): void`

### 2.2 Entity `Child`
Bổ sung kiểm tra và quản lý chuỗi ngày hoàn thành nhiệm vụ (Streak).
- Methods:
  - `public function updateStreak(DateTimeInterface $today): void`
  - `public function checkStreakExpiry(DateTimeInterface $today): void`

---

## 3. Các Use Cases mới tại Application Layer

### 3.1 `UnlockPetSkinUseCase`
- **Mục đích**: Bé dùng Sao của mình để mở khóa skin mới cho Pet.
- **Tham số**: `childId`, `skinName`.
- **Logic**:
  - Lấy Child và Pet tương ứng.
  - Kiểm tra xem skin đã mở khóa chưa.
  - So sánh Sao khả dụng của bé với giá của skin (ví dụ: Summer = 50 Sao, Special = 150 Sao).
  - Khấu trừ Sao khả dụng của bé (`$child->spendStars($price)`).
  - Lưu bản ghi vào bảng `pet_skins`.
  - Cập nhật skin hoạt động của Pet (`$pet->changeSkin($skinName)`).

### 3.2 `SyncBlockedAppsUseCase`
- **Mục đích**: Bố mẹ cập nhật danh sách ứng dụng bị hạn chế từ Mobile/Web.
- **Tham số**: `familyId`, `array $appDetails` (mỗi phần tử chứa `app_bundle_id` và `app_name`).
- **Logic**:
  - Xóa danh sách app bị khóa cũ của gia đình.
  - Lưu danh sách mới vào bảng `blocked_apps`.

---

## 4. Các API Endpoints mới (Presentation Layer)

### 4.1 `/v1/children/{id}/profile` (GET)
Trả về chi tiết hồ sơ của bé, bao gồm Rank hiện tại, streak, thú cưng, skin đang dùng và danh sách skin đã mở khóa.

### 4.2 `/v1/children/{id}/tasks/today` (GET)
Lấy danh sách các nhiệm vụ được giao cho trẻ trong ngày hôm nay kèm trạng thái của chúng trong nhật ký (`todo`, `submitted`, `approved`, `rejected`).

### 4.3 `/v1/children/{id}/pet/skin` (POST)
Mua hoặc đổi trang phục cho thú cưng ảo.
- Input: `skin_name`, `action` ('buy' hoặc 'equip').

### 4.4 `/v1/notifications/register` (POST)
Đăng ký thiết bị để nhận push notification.
- Input: `token`, `device_type`.

### 4.5 `/v1/blocking/apps` (GET / POST)
- `GET`: Lấy danh sách app bị khóa của gia đình.
- `POST`: Đồng bộ danh sách app bị khóa của gia đình từ cài đặt của bố mẹ.

---

## 5. Event-Driven Push Notifications

Tạo Service gửi thông báo tự động khi các sự kiện quan trọng xảy ra:
1. **Trẻ nộp bài (`TaskLogSubmitted`)**: Gửi thông báo tới thiết bị của Bố mẹ để duyệt.
2. **Bố mẹ duyệt bài (`TaskLogApproved`)**: Gửi thông báo tới thiết bị của Trẻ để chúc mừng kèm hiệu ứng sticker.
3. **Bố mẹ từ chối (`TaskLogRejected`)**: Gửi thông báo tới Trẻ kèm lý do từ chối để làm lại.
