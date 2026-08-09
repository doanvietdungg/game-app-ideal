# KidTime Mobile App — Design Spec
**Ngày:** 2026-08-09
**Trạng thái:** Draft — chờ review
**Nền tảng:** Flutter iOS-first (Android giai đoạn 2)
**Animation:** Rive + Flutter implicit animations

---

## 1. Tóm tắt trạng thái hiện tại

### Đã hoàn thành ✅
- **Backend API v1** — Sanctum Auth, Children, Tasks, TaskLogs, Rewards, Analytics, PIN verification
- **Web Dashboard** — Inertia.js + Vue 3 + PrimeVue: 6 module (Dashboard, Trẻ em, Nhiệm vụ, Chờ duyệt, Phần thưởng, Báo cáo)
- **Domain Layer (DDD)** — Entities: Child, Pet, Task, TaskLog, Reward, Family. Enums: PetStage, PetMood, PetSpecies, TaskCategory, Recurrence, VerificationMode, TaskLogStatus

### Chưa làm ❌ (trong scope Mobile App)
- Flutter App (toàn bộ)
- BE API endpoints bổ sung cho Mobile (child profile detail, today's tasks, praise log, streak update, pet mood update, reward redemption history)
- Rive animation assets cho 6 loài thú cưng × 3 giai đoạn × 3 mood
- iOS Family Controls integration (App Blocking)
- Push Notification system (Firebase Cloud Messaging)

---

## 2. Kiến trúc Flutter App

### 2.1 Tech Stack

| Layer | Công nghệ |
|---|---|
| **Framework** | Flutter 3.x (Dart) |
| **State Management** | Riverpod 2.x (code generation) |
| **Routing** | GoRouter |
| **HTTP Client** | Dio + Interceptors (token management) |
| **Local Storage** | SharedPreferences (token), Hive (cache) |
| **Animation** | Rive (thú cưng), Flutter implicit animations (UI) |
| **Push Notification** | Firebase Cloud Messaging (FCM) |
| **iOS Native** | MethodChannel → Swift (Family Controls, ManagedSettings, DeviceActivity) |
| **Image/Camera** | image_picker |
| **Charts** | fl_chart |

### 2.2 Architecture — Clean Architecture (match BE)

```
lib/
├── core/                     # Shared utilities
│   ├── api/                  # Dio client, interceptors, API response model
│   ├── theme/                # Colors, typography, spacing (pastel system)
│   ├── animations/           # Shared animation helpers, transitions
│   ├── router/               # GoRouter configuration
│   └── storage/              # Local storage abstractions
├── features/
│   ├── auth/                 # Login (PIN cho trẻ, email cho bố mẹ)
│   │   ├── data/             # Repository impl, DTOs
│   │   ├── domain/           # Entities, repository interface
│   │   └── presentation/     # Screens, widgets, providers
│   ├── home/                 # Màn hình chính trẻ em (thú cưng + stats)
│   ├── tasks/                # Nhiệm vụ hôm nay, submit, history
│   ├── rewards/              # Đổi phần thưởng, shop
│   ├── pet/                  # Thú cưng ảo, tủ đồ, skin
│   ├── praise/               # Nhật ký khen (sticker từ bố mẹ)
│   ├── parent/               # Quick parent view (duyệt, tổng quan)
│   └── blocking/             # iOS App Blocking (native bridge)
├── shared/
│   ├── widgets/              # Reusable UI components
│   └── models/               # Shared data models
└── main.dart
```

---

## 3. Các Module Tính năng Chi tiết

### 3.1 Module Auth — Đăng nhập 2 Role

**Màn hình chào (Splash Screen)**
- Logo KidTime animation: scale bounce in + particle stars bay xung quanh
- Auto-check token → navigate to Home hoặc Login

**Màn hình chọn Role**
- 2 card lớn bo tròn: "👶 Bé đăng nhập" vs "👨‍👩‍👧 Bố mẹ đăng nhập"
- Hover/tap: card scale up 1.05 + shadow mở rộng + background color pulse
- Background: gradient pastel ấm (peach → cream)

**Đăng nhập Bé (PIN)**
- Chọn avatar bé (danh sách từ API `/v1/children`)
- 4 ô PIN tròn lớn, mỗi ô fill animation (scale + color change)
- Sai PIN: shake animation toàn form (horizontal oscillation 3 lần)
- Đúng: confetti burst nhỏ + navigate smooth

**Đăng nhập Bố mẹ (Email + Password)**
- Form đơn giản, style giống Web Dashboard
- Redirect vào Parent Quick View

---

### 3.2 Module Home — Màn hình chính Trẻ em (CỐT LÕI)

Đây là **trung tâm trải nghiệm** — trẻ mở app là thấy ngay.

**Layout:** Full-screen, scroll vertical

```
┌─────────────────────────────────┐
│  [Rank Badge]  Xin chào, Nam!   │  ← Header
│  🔥 12 ngày · ⭐ 45 Sao         │
├─────────────────────────────────┤
│                                 │
│        🐱 THÚ CƯNG ẢO          │  ← Rive animation center
│     (idle breathing + blink)    │
│   ────── Progress bar ──────    │  ← Lên cấp thú cưng
│    Baby → Teen (65/100 ⭐)      │
│                                 │
├─────────────────────────────────┤
│  📋 NHIỆM VỤ HÔM NAY          │  ← Scroll ngang theo category
│  [🏠 Dọn phòng +3⭐] [📚...]   │
├─────────────────────────────────┤
│  [🎁 Đổi thưởng]  [👕 Tủ đồ]  │  ← Quick action buttons
│  [📖 Nhật ký khen] [📊 Stats]  │
└─────────────────────────────────┘
```

**Animation chi tiết:**
- **Thú cưng idle**: Rive loop — nhịp thở nhẹ + chớp mắt ngẫu nhiên (mỗi 3-5s), 60fps
- **Pet mood states**: 3 state machine trong Rive:
  - 😴 Sad (0 nhiệm vụ hôm nay): ủ rũ, mắt nhắm, mưa nhỏ trên đầu
  - 😊 Normal (1-2 nhiệm vụ): vui vẻ, đuôi/tai nhẹ nhàng
  - 🥳 Happy (≥3 nhiệm vụ): nhảy múa, hearts pop, vẫy tay
- **Streak counter**: Số 🔥 bounce lên khi tăng, có flame particle effect
- **Sao counter**: Khi nhận sao mới → số cũ count up animation + golden star particle burst
- **Progress bar**: Animated fill với shimmer highlight (giống loading bar nhưng nằm cố định)

---

### 3.3 Module Tasks — Nhiệm vụ Hôm nay

**Danh sách nhiệm vụ:**
- Grouped theo category tabs (cuộn ngang): 🏠 Việc nhà | 📚 Học tập | 🏃 Vận động | 🥦 Ăn uống | 😴 Giấc ngủ
- Mỗi task card:
  - Icon lớn + tiêu đề + badge sao thưởng
  - Trạng thái: ⬜ Chưa làm | 📸 Chờ duyệt | ✅ Đã duyệt | ❌ Bị từ chối
  - Tap → mở Task Detail screen

**Task Detail + Submit:**
- Hiển thị: icon, tên, mô tả, số sao, chế độ xác nhận
- 3 flow submit:
  - **📸 Ảnh**: Mở camera/gallery → preview → nút "Nộp bài" → upload photo → animation "Đang gửi..." (loading spinner dạng star spin) → thành công: checkmark draw animation
  - **🔑 PIN**: Hiện ô nhập PIN 4 số → bố mẹ nhập → approve ngay → sao cộng tức thì + pet happy bounce
  - **✅ Tự động**: Tap "Hoàn thành" → checkmark draw + sao cộng ngay

**Animation khi hoàn thành nhiệm vụ:**
1. Checkmark draw animation (stroke path animation 600ms)
2. Star burst: 5-8 particle stars bay ra từ icon → bay lên thanh sao
3. Sao counter increment animation (count up + pulse)
4. Pet reaction: jump + heart emoji pop (nếu visible)
5. Nếu streak tăng: 🔥 flame animation + bounce number

---

### 3.4 Module Rewards — Đổi Phần thưởng

**Shop layout:**
- Grid 2 cột, card bo tròn lớn
- Mỗi card: emoji icon + tên + "X ⭐ cần" + nút đổi
- Card chưa đủ sao: opacity 0.5, badge "Cần thêm Y ⭐"
- Card đủ sao: glow border animation (soft pulse shadow)

**Flow đổi thưởng:**
1. Tap card → ConfirmDialog slide up từ dưới (bottom sheet)
2. Xác nhận → animation sequence:
   - Gift box 🎁 scale up → shake → mở nắp
   - Ribbon bay ra hai bên (Rive)
   - Nội dung phần thưởng xuất hiện (text fade in + bounce)
   - Confetti shower (particle system) full screen 2 giây
   - Sao counter giảm (count down animation)

---

### 3.5 Module Pet — Thú cưng Ảo & Tủ đồ

**Pet Detail Screen:**
- Thú cưng chiếm 60% screen, Rive fullscreen mode
- Tap pet → pet phản hồi (wave tay, nháy mắt, hiệu ứng tùy loài)
- Info: Tên, loài, giai đoạn, mood hiện tại

**Tủ đồ (Wardrobe):**
- Grid skin theo loài: Default, Mùa hè, Mùa đông, Đặc biệt
- Mỗi skin: preview thumbnail + giá sao + trạng thái (🔓 Đã mở / 🔒 Khóa)
- Mua skin: animation mở khóa (lock icon break → sparkle → skin apply lên pet)
- Đổi skin: pet morph animation (fade out → fade in dạng mới)

**Lên cấp thú cưng (Evolution):**
- Khi đạt milestone sao → trigger full-screen cutscene:
  1. Background dim + spotlight lên pet
  2. Sparkle particles xoay quanh pet
  3. Pet morph: baby → teen hoặc teen → adult (Rive state transition 2s)
  4. Confetti shower + chữ "CHÚC MỪNG! 🎉" bounce in
  5. New stage badge xuất hiện + auto screenshot prompt

---

### 3.6 Module Praise — Nhật ký Khen từ Bố mẹ

**Praise Feed:**
- Timeline dọc, mỗi entry: sticker emoji lớn + message + ngày giờ + nhiệm vụ liên quan
- Entry mới: slide in từ phải + sticker bounce animation
- Khi bố mẹ duyệt nhiệm vụ + gửi sticker → push notification + hiệu ứng trên Home screen:
  - Sticker emoji bay vào từ trên xuống, nảy 2 lần, rồi đậu vào vị trí
  - Sound effect ngắn (chime)

---

### 3.7 Module App Blocking — iOS Family Controls (NATIVE)

> Đây là tính năng iOS-only, dùng Swift native code bridge qua `MethodChannel`.

**Kiến trúc iOS Native:**
```
ios/
├── Runner/
│   └── AppDelegate.swift
├── KidTimeShieldConfig/         # ShieldConfigurationExtension
│   └── ShieldConfigurationExtension.swift
├── KidTimeDeviceMonitor/        # DeviceActivityMonitorExtension
│   └── DeviceActivityMonitorExtension.swift
└── Shared/
    └── FamilyControlsBridge.swift  # MethodChannel bridge
```

**Flow:**
1. Bố mẹ chọn app bị khóa (từ Web Dashboard hoặc Parent Quick View) → lưu vào BE
2. App iOS lấy danh sách blocked apps từ BE API
3. `ManagedSettings` khóa các app
4. Bé mở YouTube → hiện Shield screen custom:
   - Pet buồn + "Hết Sao rồi 😢"
   - Nút "Về KidTime làm nhiệm vụ" → navigate về app
5. Bé kiếm đủ Sao → đổi phần thưởng "Thời gian màn hình" → app tự mở khóa
6. Hết thời gian hoặc hết Sao → khóa lại tự động

**Shield Screen Custom (iOS Extension):**
- Background: pastel gradient soft
- Pet animation (Lottie — extensions không support Rive) thú cưng buồn, mắt ướt
- Text: "Hãy làm nhiệm vụ để mở khóa nhé!" (font Nunito)
- Nút duy nhất: "🏠 Về KidTime" (rounded, primary color)

---

### 3.8 Module Parent Quick View — Duyệt nhanh cho Bố mẹ

> Bố mẹ dùng CÙNG Flutter app nhưng login bằng email → thấy màn hình khác.

**Dashboard nhanh:**
- Tổng quan: sao hôm nay, nhiệm vụ chờ duyệt (badge đỏ), streak mỗi con
- Card từng con: avatar + tên + pet mood emoji + stats

**Duyệt nhiệm vụ:**
- Swipeable cards (giống Tinder):
  - Swipe phải = ✅ Duyệt (chọn sticker tặng)
  - Swipe trái = ❌ Từ chối (nhập lý do)
- Xem ảnh chụp fullscreen trước khi duyệt
- Haptic feedback khi swipe

---

## 4. Hệ thống Design Visual

### 4.1 Color Palette (Pastel Warm)

```dart
// Primary palette — App trẻ em
static const primary     = Color(0xFFFFB347); // Peach Orange
static const secondary   = Color(0xFFA8E6CF); // Mint Green
static const accent      = Color(0xFFFFD3E8); // Baby Pink
static const background  = Color(0xFFFFFBF0); // Warm White
static const surface     = Color(0xFFFFFFFF); // Pure White
static const text        = Color(0xFF3D2B1F); // Warm Brown
static const textLight   = Color(0xFF8B7355); // Light Brown

// Category colors
static const housework   = Color(0xFFFFB347); // Orange
static const study       = Color(0xFF87CEEB); // Sky Blue
static const exercise    = Color(0xFFA8E6CF); // Mint
static const eating      = Color(0xFFFFD700); // Golden
static const sleep       = Color(0xFFC8A2C8); // Lavender
```

### 4.2 Typography

```dart
// Font: Nunito (match web dashboard)
// Headings: Nunito ExtraBold
// Body: Nunito SemiBold
// Small: Nunito Regular

// Sizes:
// Hero title:    28sp
// Section title: 22sp
// Card title:    18sp
// Body:          16sp
// Caption:       13sp
// Badge:         11sp
```

### 4.3 Spacing & Shapes

```dart
// Border radius system:
static const radiusS  = 12.0;  // Small elements (badges, chips)
static const radiusM  = 16.0;  // Medium (cards, inputs)
static const radiusL  = 24.0;  // Large (panels, modals)
static const radiusXL = 32.0;  // Extra large (main containers)

// Padding/margin base: 8dp grid
// Cards: 16-24dp padding
// Sections: 24-32dp spacing
```

### 4.4 Animation System Specs

| Animation | Duration | Curve | Trigger |
|---|---|---|---|
| Page transition | 350ms | `Curves.easeInOutCubic` | Navigation |
| Card tap feedback | 150ms | `Curves.easeOut` | Tap down/up |
| Card hover/press | 200ms | `Curves.easeOutBack` | Touch |
| Star burst particles | 800ms | Custom spring | Task complete |
| Counter increment | 600ms | `Curves.easeOutExpo` | Value change |
| Streak flame | 500ms | `Curves.bounceOut` | Streak increase |
| Sticker fly-in | 600ms | `Curves.elasticOut` | Praise received |
| Confetti shower | 2000ms | Linear (gravity) | Milestone/redeem |
| Pet mood change | 1000ms | `Curves.easeInOut` | State transition |
| Pet evolution | 3000ms | Multi-phase | Stage change |
| Shield screen appear | 400ms | `Curves.decelerate` | App blocked |
| Swipe card (parent) | 300ms | Spring physics | Gesture |
| PIN dot fill | 200ms | `Curves.easeOut` | Key press |
| Shake (error) | 500ms | Oscillation 3x | Validation error |

---

## 5. Backend API Upgrades Cần Thiết

### 5.1 API Endpoints mới cần thêm

| Method | Endpoint | Mục đích |
|---|---|---|
| `GET` | `/v1/children/{id}/profile` | Profile chi tiết trẻ (pet, rank, stats, mood) |
| `GET` | `/v1/children/{id}/tasks/today` | Danh sách nhiệm vụ hôm nay cho trẻ |
| `GET` | `/v1/children/{id}/tasks/history` | Lịch sử nhiệm vụ đã hoàn thành |
| `GET` | `/v1/children/{id}/praise` | Nhật ký khen (sticker từ bố mẹ) |
| `POST` | `/v1/children/{id}/streak/check` | Kiểm tra + cập nhật streak hàng ngày |
| `GET` | `/v1/children/{id}/pet` | Pet detail (species, stage, mood, skin) |
| `POST` | `/v1/children/{id}/pet/skin` | Mua hoặc đổi skin thú cưng |
| `GET` | `/v1/children/{id}/rewards/history` | Lịch sử đổi phần thưởng |
| `POST` | `/v1/notifications/register` | Đăng ký FCM token cho push notification |
| `GET` | `/v1/blocking/apps` | Lấy danh sách app bị khóa |
| `POST` | `/v1/blocking/apps` | Cập nhật danh sách app bị khóa |
| `GET` | `/v1/children/{id}/screen-time` | Lịch sử thời gian sử dụng app |

### 5.2 Domain Model Changes

- **Pet entity**: Thêm `unlockedSkins: array`, `activeSkin: string`, method `unlockSkin()`, `changeSkin()`
- **Child entity**: Thêm method `updateStreak()`, `checkStreakExpiry()`
- **Reward entity**: Thêm `type: enum(screen_time, physical)`, `duration_minutes: ?int`
- **Bảng mới**: `reward_redemptions` (child_id, reward_id, redeemed_at)
- **Bảng mới**: `pet_skins` (pet_id, skin_name, unlocked_at)
- **Bảng mới**: `blocked_apps` (family_id, app_bundle_id, app_name)
- **Bảng mới**: `screen_time_logs` (child_id, app_bundle_id, duration_seconds, date)
- **Bảng mới**: `fcm_tokens` (user_id, token, device_type, created_at)

### 5.3 Push Notification Events

| Event | Recipient | Nội dung |
|---|---|---|
| Trẻ nộp nhiệm vụ | Bố mẹ | "{child.name} đã nộp: {task.title}" |
| Bố mẹ duyệt | Trẻ | "Bố mẹ đã duyệt! +{stars}⭐" + sticker |
| Bố mẹ từ chối | Trẻ | "Nhiệm vụ bị từ chối: {reason}" |
| Streak milestone | Trẻ | "🔥 Chuỗi {days} ngày! Giỏi quá!" |
| Pet evolution | Trẻ | "🎉 Thú cưng đã lên cấp {stage}!" |

---

## 6. Rive Animation Assets Cần Tạo

### 6.1 Thú cưng — 6 loài × 3 stage × 3 mood = 54 states

Mỗi file `.riv` = 1 loài, chứa state machine:
- **Inputs**: `stage` (baby/teen/adult), `mood` (sad/normal/happy), `skin` (default/summer/winter/special)
- **States**: idle loop cho mỗi combo
- **Triggers**: `tap` (phản hồi khi chạm), `celebrate` (khi hoàn thành task), `evolve` (lên cấp)

| File | Loài | Dung lượng mục tiêu |
|---|---|---|
| `cat.riv` | 🐱 Mèo | < 500KB |
| `bunny.riv` | 🐰 Thỏ | < 500KB |
| `bear.riv` | 🐻 Gấu | < 500KB |
| `dinosaur.riv` | 🦕 Khủng long | < 500KB |
| `penguin.riv` | 🐧 Chim cánh cụt | < 500KB |
| `dragon.riv` | 🐲 Rồng | < 500KB |

### 6.2 UI Effects

| File | Mô tả |
|---|---|
| `star_burst.riv` | Particle stars bay ra khi nhận sao |
| `confetti.riv` | Confetti shower cho milestones |
| `gift_open.riv` | Gift box mở + ribbon cho redeem |
| `checkmark.riv` | Animated checkmark cho task complete |
| `flame.riv` | Streak flame animation |
| `shield_pet_sad.riv` | Pet buồn cho Shield screen (dùng Lottie fallback cho Extension) |

---

## 7. Phân Rã Sprint

### Sprint 1 (Tuần 1-2): Foundation + Auth + Home
- Setup Flutter project, Clean Architecture folder structure
- Core: theme, Dio client, Riverpod setup, GoRouter config
- Auth module: splash, role selection, PIN login, email login
- Home screen: static layout + Rive pet placeholder
- BE: API endpoint `/children/{id}/profile`, `/children/{id}/tasks/today`

### Sprint 2 (Tuần 3-4): Tasks + Star System
- Task list screen (grouped by category)
- Task detail + submit flow (photo, PIN, auto)
- Star award animations
- Streak check + update
- BE: Streak logic, push notification groundwork

### Sprint 3 (Tuần 5-6): Rewards + Pet System
- Reward shop screen
- Redeem flow + animations
- Pet detail screen + wardrobe
- Skin purchase + change
- Pet evolution cutscene
- BE: `pet_skins`, `reward_redemptions` tables + endpoints

### Sprint 4 (Tuần 7-8): Praise + Parent View
- Praise feed timeline
- Push notifications (FCM)
- Parent Quick View dashboard
- Swipeable approval cards
- BE: FCM integration, notification events

### Sprint 5 (Tuần 9-10): App Blocking (iOS Native)
- Swift native extensions (Shield, DeviceActivity)
- MethodChannel bridge
- Block/unblock flow
- Shield screen UI
- BE: `blocked_apps`, `screen_time_logs` endpoints

### Sprint 6 (Tuần 11-12): Polish + Testing
- Animation polish pass (all transitions)
- Performance optimization
- Integration testing
- Beta build for TestFlight

---

*Spec được tạo qua phiên brainstorming ngày 2026-08-09*
