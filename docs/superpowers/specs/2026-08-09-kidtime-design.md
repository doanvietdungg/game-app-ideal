# KidTime — Design Spec
**Ngày:** 2026-08-09  
**Trạng thái:** Draft — chờ review

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
- **Bố mẹ** = người quản lý: tạo nhiệm vụ, cài phần thưởng, duyệt, xem báo cáo
- **Trẻ em** = người chơi game: hoàn thành nhiệm vụ, kiếm Sao ⭐, nuôi thú cưng ảo, đổi phần thưởng

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
| **Mobile App (iOS + Android)** | Trẻ em (app chơi) + Bố mẹ (app duyệt nhanh) | Flutter |
| **Web Dashboard** | Bố mẹ (setup, báo cáo chi tiết) | Laravel 11 + Vue 3 + Inertia.js |
| **Backend API** | Phục vụ cả Flutter lẫn Web | Laravel 11 REST API |

---

## 5. Tính năng cốt lõi

### 5.1 App Trẻ em (Flutter)

#### Màn hình chính
- Thú cưng ảo hiển thị trung tâm với idle animation (thở nhẹ, nhảy nhẹ)
- Thanh Sao hiện tại + tiến trình lên cấp thú cưng
- Danh sách nhiệm vụ hôm nay (có thể cuộn)
- Nút "Đổi phần thưởng" góc phải

#### Hệ thống nhiệm vụ

Mỗi nhiệm vụ có:
- Tên + icon danh mục
- Số Sao thưởng khi hoàn thành
- Chế độ xác nhận (xem mục 5.3)
- Trạng thái: Chờ làm / Đã nộp / Đã duyệt / Bị từ chối

**5 danh mục nhiệm vụ mẫu:**

| Danh mục | Icon | Ví dụ nhiệm vụ | Stars |
|---|---|---|---|
| 🏠 Việc nhà | 🧹 | Dọn phòng, rửa bát, gấp quần áo | 2–3 ⭐ |
| 📚 Học tập | ✏️ | Đọc sách 20 phút, làm bài tập xong | 3–5 ⭐ |
| 🏃 Vận động | 🚴 | Ra ngoài chơi 30 phút, đạp xe | 3–4 ⭐ |
| 🥦 Ăn uống | 🍱 | Ăn hết rau, ăn đúng giờ | 2–3 ⭐ |
| 😴 Giấc ngủ | 🌙 | Tắt điện thoại trước 9h, ngủ đúng giờ | 3–4 ⭐ |

#### Hệ thống Sao ⭐
- Trẻ kiếm Sao bằng cách hoàn thành nhiệm vụ được duyệt
- Sao tích lũy, không mất theo ngày
- Dùng Sao đổi phần thưởng do bố mẹ định nghĩa

#### Thú cưng ảo (Tamagotchi-style)
- Mỗi trẻ có 1 thú cưng riêng (chọn loài khi đăng ký: mèo / thỏ / gấu...)
- **3 giai đoạn phát triển:** Nhỏ → Thiếu niên → Trưởng thành (mỗi giai đoạn cần đủ Sao tích lũy)
- **3 trạng thái hàng ngày:**
  - 😴 Buồn ngủ / Ủ rũ — không làm nhiệm vụ nào hôm nay
  - 😊 Bình thường — làm ít nhất 1 nhiệm vụ
  - 🥳 Phấn khích / Nhảy múa — hoàn thành ≥ 3 nhiệm vụ
- Không làm nhiệm vụ 2 ngày liên tiếp → thú cưng có animation "buồn, xỉu" → trẻ muốn quay lại

#### Animation trọng tâm
- **Idle:** Thú cưng thở nhẹ, chớp mắt, nhúc nhích liên tục
- **Nhận Sao:** Mưa sao vàng rơi xuống + âm thanh vui
- **Lên cấp thú cưng:** Cutscene ngắn biến đổi hình dạng + confetti
- **Hoàn thành nhiệm vụ:** Checkmark animation + thú cưng nhảy múa
- **Chuyển màn hình:** Slide mượt + bounce effect

#### Đổi phần thưởng
- Trẻ xem danh sách phần thưởng bố mẹ tạo (tên + số Sao cần)
- Bấm "Đổi" → xác nhận → Sao bị trừ → bố mẹ nhận thông báo
- Bố mẹ thực hiện phần thưởng trong thực tế (không cần unlock kỹ thuật)

---

### 5.2 App Bố mẹ (Flutter — cùng app, role riêng)

> **Quyết định kiến trúc:** Bố mẹ và trẻ em dùng **cùng 1 app Flutter**, phân biệt bằng vai trò khi đăng nhập. Trẻ đăng nhập bằng PIN đơn giản. Bố mẹ đăng nhập bằng email/mật khẩu.

#### Tính năng bố mẹ trên app mobile
- **Thông báo duyệt nhiệm vụ:** nhận push notification → vuốt → duyệt / từ chối ngay
- **Xem nhanh:** Sao con hiện tại, nhiệm vụ hôm nay, trạng thái thú cưng
- **Duyệt ảnh:** xem ảnh trẻ nộp kèm nhiệm vụ

#### Tính năng bố mẹ trên Web Dashboard
- Quản lý hồ sơ trẻ (thêm, sửa, xóa)
- Tạo / chỉnh sửa nhiệm vụ (chọn từ thư viện mẫu hoặc tự tạo)
- Cài phần thưởng (tên, mô tả, số Sao cần đổi)
- Xem báo cáo tuần: số nhiệm vụ hoàn thành, Sao kiếm / đã đổi, biểu đồ theo ngày
- Cài đặt tài khoản gia đình

---

### 5.3 Hệ thống xác nhận nhiệm vụ (3 chế độ)

Bố mẹ chọn chế độ khi **tạo nhiệm vụ:**

| Chế độ | Khi nào dùng | Luồng xác nhận |
|---|---|---|
| 📸 **Ảnh chứng minh** | Bố mẹ không ở cạnh con | Con chụp ảnh → nộp → Bố mẹ duyệt qua app (push notification) |
| 🔑 **PIN bố mẹ** | Bố mẹ ở cạnh, không muốn mở app | Con bấm "Xong" → Màn hình hiện ô nhập PIN → Bố mẹ nhập PIN 4 số → Sao cộng ngay |
| ✅ **Tự động** | Bố mẹ hoàn toàn tin tưởng | Con bấm "Xong" → Sao cộng ngay, không xác nhận thêm |

**Luồng duyệt push notification (chế độ Ảnh):**
```
Con bấm Nộp ảnh
→ Bố mẹ nhận: "Bé Nam vừa nộp: Dọn phòng 🧹 [Xem ảnh]"
→ Vuốt notification → Hiện ảnh + [✅ Duyệt] [❌ Từ chối]
→ Bố mẹ bấm Duyệt
→ Con nhận Sao ngay + thú cưng nhảy vui
```

---

## 6. Kiếm tiền (Monetization)

**MVP:** Miễn phí hoàn toàn — tập trung xây dựng user base và validate sản phẩm trước.

*(Hướng monetization sẽ được xem xét sau khi có traction)*

---

## 7. Những gì KHÔNG có trong MVP

- AI xác minh ảnh tự động (giữ lại bố mẹ duyệt thủ công — đơn giản hơn, tin cậy hơn)
- Nhiều trẻ / nhiều gia đình trong 1 tài khoản (MVP: 1 tài khoản = 1 gia đình, tối đa 2 trẻ)
- Leaderboard / so sánh với trẻ khác
- Tích hợp mở khóa kỹ thuật với app bên thứ ba (YouTube, game...)
- Thú cưng bị "chết" nếu không chăm (giữ trải nghiệm tích cực, không gây stress)

---

## 8. Success Criteria

- Trẻ tự mở app mỗi ngày mà không cần bố mẹ nhắc
- Bố mẹ không cần mở web để xử lý tác vụ hàng ngày thông thường
- Trẻ hoàn thành ≥ 3 nhiệm vụ/tuần
- Thú cưng đạt giai đoạn 2 (Thiếu niên) trong vòng 30 ngày dùng liên tục

---

*Spec được tạo qua phiên brainstorming ngày 2026-08-09*
