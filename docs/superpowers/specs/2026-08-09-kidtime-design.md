# KidTime — Design Spec (Full Version)
**Ngày:** 2026-08-09  
**Trạng thái:** Updated — App Blocking mechanic added  
**Version:** Full Product (không phải MVP)

---

## 1. Bối cảnh & Vấn đề

Trẻ em Việt Nam (6–10 tuổi) ngày càng nghiện điện thoại / màn hình. Các giải pháp hiện có (Google Family Link, Screen Time của iOS) chỉ **kiểm soát cưỡng bức** — khoá màn hình, đặt giới hạn — nhưng không tạo ra động lực nội tại khiến trẻ tự nguyện hợp tác.

**Pain point của bố mẹ Việt:**
- Cãi nhau với con mỗi khi thu điện thoại
- Không có công cụ kết nối "làm việc tốt → được thưởng thời gian màn hình"
- Bố mẹ bận, không muốn phải mở máy tính mỗi khi cần duyệt

**Insight cốt lõi:** Trẻ em sẵn sàng hợp tác nếu có động lực rõ ràng và công bằng. Thay vì cưỡng bức, hãy biến việc "kiếm thời gian màn hình" thành một trò chơi thú vị.

---

## 2. Giải pháp — KidTime

Nền tảng 2 vai:
- **Bố mẹ** = người quản lý: tạo nhiệm vụ, cài phần thưởng, duyệt, xem báo cáo phân tích sâu
- **Trẻ em** = người chơi game: hoàn thành nhiệm vụ, kiếm Sao ⭐, nuôi thú cưng ảo, đổi phần thưởng, xây dựng streak

---

## 3. Đối tượng người dùng

| | Đặc điểm |
|---|---|
| **Trẻ em** | 6–10 tuổi (tiểu học), đọc được, thích game, bị thu hút bởi màu sắc & animation |
| **Bố mẹ** | 25–35 tuổi, Millennials Việt Nam, dùng smartphone thành thạo, bận rộn, muốn giải pháp tiện lợi |

**Thị trường:** Việt Nam (nội địa), tiếng Việt.

---

## 4. Nền tảng

| Nền tảng | Đối tượng | Công nghệ |
|---|---|---|
| **Mobile App iOS** | Trẻ em (app chơi + khoá app) + Bố mẹ (duyệt nhanh) | Flutter + Swift Native Extension |
| **Mobile App Android** | Giai đoạn 2 — sau iOS ổn định | Flutter + Accessibility Service |
| **Web Dashboard** | Bố mẹ (setup, báo cáo chi tiết) | Laravel 11 + Vue 3 + Inertia.js |
| **Backend API** | Phục vụ cả Flutter lẫn Web | Laravel 11 REST API |

> **iOS-first:** Ra mắt iOS trước vì Apple có API chính thức (`Family Controls` entitlement). Android sẽ phát triển sau.

---

## 5. Design Visual

### 5.1 Phong cách

**Cute & Pastel — Animal Crossing / Pokémon inspired**

- **Màu sắc:** Pastel ấm (peach, mint, lavender, butter yellow, baby blue) — không dùng màu nguyên chất chói
- **Typography:** Bo tròn, thân thiện — font như Nunito / Fredoka One
- **Hình dạng:** Bo góc nhiều, không có cạnh sắc
- **Nhân vật:** Chibi-style, mắt to, biểu cảm rõ ràng
- **Background:** Gradient nhẹ, có texture hạt nhỏ (grain texture) tạo cảm giác ấm áp
- **Icons:** Line icon bo tròn, stroke dày, có shadow nhẹ

### 5.2 Animation nguyên tắc

Tất cả animation tuân theo **"Snappy & Bouncy"** — nhanh khi bắt đầu, nảy nhẹ khi dừng:

| Loại | Mô tả kỹ thuật |
|---|---|
| **Idle thú cưng** | Loop breathing + eye blink, 60fps, Rive animation |
| **Nhận Sao** | Particle burst hình sao + scale up/down bounce + âm thanh |
| **Hoàn thành nhiệm vụ** | Checkmark draw animation → thú cưng jump + heart pop |
| **Lên cấp thú cưng** | Full-screen cutscene: sparkles → morph shape → confetti shower |
| **Streak mới** | Flame animation 🔥 + số đếm bounce lên |
| **Chuyển màn hình** | Slide + spring physics (damping 0.7) |
| **Button tap** | Scale down 0.92 → release bounce |
| **Phần thưởng mở khóa** | Gift box mở → ribbon bay → nội dung xuất hiện |
| **Thú cưng buồn (2 ngày không làm)** | Slow droop animation + rain drops trên đầu |

### 5.3 Thú cưng — 6 loài

| Loài | Màu chủ đạo | Cá tính |
|---|---|---|
| 🐱 Mèo | Orange pastel | Lười biếng dễ thương, ngủ gật khi idle |
| 🐰 Thỏ | Pink pastel | Nhảy nhảy liên tục, tai vểnh |
| 🐻 Gấu | Brown pastel | Chậm chạp, ôm bụng, cute |
| 🦕 Khủng long | Mint green | Nghịch ngợm, đuôi vẫy |
| 🐧 Chim cánh cụt | Blue/white | Waddle animation, hay trượt ngã |
| 🐲 Rồng nhỏ | Purple pastel | Phun lửa nhỏ khi vui, hiếm/đặc biệt |

Mỗi loài có **4 skin/trang phục** mở khóa bằng Sao:
- Default (miễn phí)
- Mùa hè (áo phao, kính mát)
- Mùa đông (khăn quàng, mũ len)
- Đặc biệt (trang phục siêu anh hùng / hoàng gia)

### 5.4 Màu sắc cho từng nhóm

**App trẻ em (Flutter):**
- Primary: `#FFB347` (Peach Orange)
- Secondary: `#A8E6CF` (Mint Green)
- Accent: `#FFD3E8` (Baby Pink)
- Background: `#FFFBF0` (Warm White)
- Text: `#3D2B1F` (Warm Brown)

**Web Dashboard bố mẹ (Laravel + Vue):**
- Primary: `#6C63FF` (Soft Indigo)
- Secondary: `#48CAE4` (Sky Blue)
- Background: `#F8F9FF` (Cool White)
- Surface: `#FFFFFF`
- Text: `#1A1A2E`

---

## 6. Tính năng đầy đủ

### 6.1 App Trẻ em (Flutter)

#### Màn hình chính
- Thú cưng ảo hiển thị trung tâm với idle animation liên tục
- Thanh Sao hiện tại + progress bar lên cấp
- Streak counter 🔥 (chuỗi ngày liên tiếp)
- Level / Rank badge (Bronze → Silver → Gold → Platinum → Diamond)
- Danh sách nhiệm vụ hôm nay (cuộn ngang theo danh mục)
- Nút "Đổi phần thưởng" + "Tủ đồ thú cưng"

#### Hệ thống nhiệm vụ

**5 danh mục + lặp lịch:**

| Danh mục | Icon | Ví dụ nhiệm vụ | Stars |
|---|---|---|---|
| 🏠 Việc nhà | 🧹 | Dọn phòng, rửa bát, gấp quần áo | 2–3 ⭐ |
| 📚 Học tập | ✏️ | Đọc sách 20 phút, làm bài tập xong | 3–5 ⭐ |
| 🏃 Vận động | 🚴 | Ra ngoài chơi 30 phút, đạp xe | 3–4 ⭐ |
| 🥦 Ăn uống | 🍱 | Ăn hết rau, ăn đúng giờ | 2–3 ⭐ |
| 😴 Giấc ngủ | 🌙 | Tắt điện thoại trước 9h, ngủ đúng giờ | 3–4 ⭐ |

Nhiệm vụ có thể cài **lặp lịch:**
- Một lần
- Hàng ngày (VD: "Đánh răng buổi tối")
- Các ngày trong tuần (VD: "Học bài — Thứ 2–6")
- Hàng tuần (VD: "Dọn phòng — mỗi Chủ nhật")

#### Hệ thống Sao ⭐
- Tích lũy, không mất theo ngày
- Dùng đổi phần thưởng bố mẹ tạo + skin thú cưng
- Hiển thị lịch sử kiếm/tiêu Sao

#### Streak 🔥
- Đếm số ngày liên tiếp hoàn thành ít nhất 1 nhiệm vụ
- Milestone streak (7 ngày, 30 ngày, 100 ngày) → thưởng Sao bonus lớn + animation đặc biệt
- Nếu bỏ 1 ngày → streak về 0

#### Hệ thống Level / Rank

| Rank | Yêu cầu Sao tích lũy | Badge màu |
|---|---|---|
| 🥉 Bronze | 0–99 ⭐ | Nâu ấm |
| 🥈 Silver | 100–299 ⭐ | Bạc sáng |
| 🥇 Gold | 300–699 ⭐ | Vàng |
| 💎 Platinum | 700–1499 ⭐ | Tím platinum |
| 👑 Diamond | 1500+ ⭐ | Xanh kim cương |

#### Thú cưng ảo (Tamagotchi-style)

**3 giai đoạn phát triển:**
- Giai đoạn 1 — Baby: 0–99 Sao tích lũy
- Giai đoạn 2 — Teen: 100–399 Sao tích lũy
- Giai đoạn 3 — Adult: 400+ Sao tích lũy

**3 trạng thái hàng ngày:**
- 😴 Ủ rũ — không làm nhiệm vụ nào
- 😊 Vui — hoàn thành 1–2 nhiệm vụ
- 🥳 Siêu vui / nhảy múa — hoàn thành ≥ 3 nhiệm vụ

Không làm nhiệm vụ 2 ngày → thú cưng animation "buồn, có mưa nhỏ trên đầu"

#### Lời khen từ bố mẹ
- Bố mẹ gửi sticker / emoji praise khi duyệt nhiệm vụ
- Trẻ nhận thông báo + hiện trên màn hình: sticker nổi lên với animation bounce
- Lưu lại trong "Nhật ký khen" — trẻ xem lại được

#### Hệ thống App Blocking (Cơ chế cốt lõi)

Đây là **vòng lặp chính** của toàn sản phẩm — không phải honor system:

```
Bố mẹ cài danh sách app bị khoá (YouTube, TikTok, game...)
→ KidTime dùng iOS Screen Time API khoá các app đó
→ Bé muốn xem YouTube → Hiện màn hình Shield của KidTime
→ Bé làm nhiệm vụ → Kiếm Sao ⭐
→ Đủ Sao → KidTime tự động mở khoá → Bé xem được
→ Hết thời gian / hết Sao → Khoá lại tự động
```

**2 loại phần thưởng bố mẹ tạo:**

| Loại | Cơ chế | Ví dụ |
|---|---|---|
| ⏱️ **Thời gian màn hình** | Khoá kỹ thuật, tự mở theo Sao | "5 ⭐ = 30 phút YouTube" |
| 🎁 **Phần thưởng thực tế** | Honor system (bố mẹ thực hiện tay) | "20 ⭐ = đi ăn kem cuối tuần" |

**Trạng thái khi bé hết Sao (available_stars = 0):**
- Tất cả app trong danh sách bị khoá bởi iOS
- Bé mở YouTube → Hiện màn hình Shield tùy chỉnh của KidTime
- Shield hiện: thú cưng buồn + câu "Hết Sao rồi 😢 Hãy làm nhiệm vụ để mở khoá nhé!"
- Nút duy nhất: "Về KidTime làm nhiệm vụ" → mở app KidTime
- Bé hoàn thành nhiệm vụ → Kiếm Sao → App tự mở khoá ngay

**iOS Technical Stack cho App Blocking:**
- Framework: `FamilyControls` + `ManagedSettings` + `DeviceActivity` (iOS 16+)
- Yêu cầu: `Family Controls entitlement` (phải xin Apple cấp)
- Native extension: `ShieldConfigurationExtension` (tùy chỉnh màn hình khoá)
- Native extension: `DeviceActivityMonitorExtension` (background monitoring)
- Bridge: Flutter ↔ Swift qua `MethodChannel`

---

### 6.2 App Bố mẹ (Flutter — cùng app, role riêng)

> **Kiến trúc:** 1 app Flutter, phân role khi đăng nhập. Trẻ: PIN 4 số. Bố mẹ: email + password.

#### Trang chủ bố mẹ (mobile)
- Tổng quan nhanh: Sao từng con hôm nay, streak, trạng thái thú cưng
- Nhiệm vụ chờ duyệt (badge đỏ)
- Phần thưởng đang chờ thực hiện

#### Duyệt nhiệm vụ
- Push notification → vuốt → [✅ Duyệt + 💬 Gửi sticker] [❌ Từ chối + lý do]
- Xem ảnh trước khi duyệt
- Gửi kèm lời khen / sticker khi duyệt

---

### 6.3 Web Dashboard bố mẹ (Laravel + Vue)

#### Quản lý gia đình
- Thêm tối đa 5 trẻ trong 1 tài khoản gia đình
- Mỗi trẻ có hồ sơ riêng: tên, tuổi, avatar, loại thú cưng

#### Quản lý nhiệm vụ
- Thư viện mẫu sẵn có (phân theo danh mục)
- Tạo nhiệm vụ tùy chỉnh
- Cài lịch lặp (một lần / hàng ngày / theo tuần)
- Chọn chế độ xác nhận: 📸 Ảnh / 🔑 PIN / ✅ Tự động

#### Quản lý App Blocking
- Bố mẹ chọn **danh sách app bị khoá** từ danh sách app đã cài trên điện thoại con (qua `FamilyActivityPicker` của iOS)
- Cài quy tắc: khoá hoàn toàn khi Sao = 0, hoặc khoá từ khung giờ cụ thể (VD: sau 9pm)
- Xem lịch sử thời gian bé dùng từng app

#### Quản lý phần thưởng
- **Thời gian màn hình:** Tạo gói "X ⭐ = Y phút" cho từng app (VD: "5 ⭐ = 30 phút YouTube")
- **Phần thưởng thực tế:** Tạo phần thưởng honor system (VD: "20 ⭐ = đi ăn kem")
- Kích hoạt / tắt phần thưởng

#### Báo cáo & Phân tích (đẹp, chi tiết)
- **Dashboard tuần:** Sao kiếm/tiêu, nhiệm vụ hoàn thành, streak
- **Biểu đồ cột:** Hoạt động theo ngày trong tuần
- **Biểu đồ tròn:** Phân bổ theo danh mục nhiệm vụ
- **Timeline:** Lịch sử hoạt động theo ngày
- **So sánh tuần trước:** % thay đổi
- Xuất báo cáo PDF (tính năng cao cấp)

---

### 6.4 Hệ thống xác nhận 3 chế độ

| Chế độ | Khi nào dùng | Luồng |
|---|---|---|
| 📸 **Ảnh chứng minh** | Bố mẹ không ở cạnh | Con chụp ảnh → nộp → Bố mẹ duyệt qua push notification |
| 🔑 **PIN bố mẹ** | Bố mẹ ở cạnh | Con bấm "Xong" → Màn hình PIN → Bố mẹ nhập 4 số → Sao cộng ngay |
| ✅ **Tự động** | Hoàn toàn tin tưởng | Con bấm "Xong" → Sao cộng ngay |

---

## 7. Yêu cầu kỹ thuật đặc biệt (iOS)

### Family Controls Entitlement
- Phải đăng ký và được Apple phê duyệt trước khi submit App Store
- Cần cung cấp: mô tả use case, privacy policy, mục đích dùng API
- Thời gian phê duyệt: thường 1–2 tuần
- Link đăng ký: https://developer.apple.com/contact/request/family-controls-distribution

### iOS Extensions cần tạo
| Extension | Chức năng |
|---|---|
| `ShieldConfigurationExtension` | Tùy chỉnh màn hình hiện khi app bị khoá |
| `DeviceActivityMonitorExtension` | Chạy nền, theo dõi & khoá/mở app tự động |

---

## 8. Kiếm tiền (Monetization — định hướng sau)

Miễn phí hoàn toàn trong giai đoạn đầu. Hướng tiềm năng sau:
- Premium subscription: báo cáo nâng cao, nhiều trẻ hơn, skin độc quyền
- Skin thú cưng theo mùa / sự kiện đặc biệt

---

## 9. Success Criteria

- App blocking hoạt động ổn định, không bypass được
- Trẻ tự mở app mỗi ngày không cần nhắc
- Streak trung bình ≥ 5 ngày sau tuần đầu
- Bố mẹ duyệt nhiệm vụ qua app mobile, không cần mở web hàng ngày
- Trẻ đạt rank Silver trong 30 ngày đầu
- Giảm thời gian màn hình ngoài kế hoạch ≥ 30% so với trước khi dùng app

---

*Spec được tạo qua phiên brainstorming ngày 2026-08-09*
