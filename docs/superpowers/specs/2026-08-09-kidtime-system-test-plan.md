# KidTime — Kiểm Thử Thủ Công Toàn Bộ Hệ Thống (Manual QA Test Cases)

> **Chuẩn bị trước khi test:**
> - Web Dashboard: mở `http://localhost:8000`
> - Mobile App: mở `http://localhost:8080`
> - Tài khoản Bố mẹ: `parent@kidtime.com` / `password123`
> - Mã PIN trẻ em: `1234`

---

## Luồng 1: Đăng Nhập & Chọn Vai Trò

### TC-1.1 — Splash Screen tự động chuyển trang
- **Bước 1:** Mở `http://localhost:8080`
- **Bước 2:** Quan sát màn hình Splash có logo KidTime và dòng chữ *"Nhiệm vụ nhỏ · Niềm vui to"*
- **Bước 3:** Chờ khoảng 2-3 giây
- **Kỳ vọng:** Tự động chuyển sang màn hình Chọn Vai Trò

### TC-1.2 — Chọn vai trò "Bé yêu"
- **Bước 1:** Ở màn hình Chọn Vai Trò, bấm vào thẻ **"🧒 Bé yêu"**
- **Kỳ vọng:** Chuyển sang màn hình chọn bé (hiện danh sách Bé Nam, Bé Linh)

### TC-1.3 — Chọn bé và nhập PIN đúng
- **Bước 1:** Chọn **Bé Nam 👦**
- **Bước 2:** Nhập PIN `1234` trên bàn phím số
- **Kỳ vọng:** Chuyển sang Trang chủ của bé, hiện *"Xin chào, Nam! 👋"*

### TC-1.4 — Nhập PIN sai rồi xóa
- **Bước 1:** Chọn Bé Nam, nhập `12`
- **Bước 2:** Bấm nút **Xóa (⌫)**
- **Kỳ vọng:** PIN hiển thị chỉ còn `1` (1 chấm tròn đã điền)

### TC-1.5 — Chọn vai trò "Bố mẹ"
- **Bước 1:** Quay lại màn hình Chọn Vai Trò
- **Bước 2:** Bấm vào thẻ **"👨‍👩‍👧 Bố mẹ"**
- **Kỳ vọng:** Chuyển sang màn hình Duyệt bài Phụ huynh

### TC-1.6 — Đăng nhập Web Dashboard
- **Bước 1:** Mở `http://localhost:8000/login`
- **Bước 2:** Nhập Email: `parent@kidtime.com`, Password: `password123`
- **Bước 3:** Bấm **Đăng nhập**
- **Kỳ vọng:** Chuyển sang Dashboard Bố mẹ, hiện *"Dashboard Bố mẹ"* + thống kê

### TC-1.7 — Đăng nhập Web sai mật khẩu
- **Bước 1:** Mở `http://localhost:8000/login`
- **Bước 2:** Nhập Email: `parent@kidtime.com`, Password: `saimatkhau`
- **Bước 3:** Bấm **Đăng nhập**
- **Kỳ vọng:** Ở lại trang login, hiện thông báo lỗi *"Email hoặc mật khẩu không chính xác"*

### TC-1.8 — Truy cập Dashboard khi chưa đăng nhập
- **Bước 1:** Mở tab ẩn danh (Incognito), truy cập `http://localhost:8000/dashboard`
- **Kỳ vọng:** Bị redirect về trang `/login`

---

## Luồng 2: Trang Chủ Trẻ Em & Thú Cưng

### TC-2.1 — Trang chủ hiển thị đầy đủ thông tin
- **Bước 1:** Đăng nhập Bé Nam trên Mobile App
- **Kỳ vọng:** Thấy đủ các mục:
  - Lời chào *"Xin chào, Nam! 👋"*
  - Danh hiệu *"Hạng Bạc"*
  - Streak *"12 ngày"* 🔥
  - Sao *"45 Sao"* ⭐
  - Thú cưng *"Mimi đang vui vẻ 😊"* + thanh kinh nghiệm

### TC-2.2 — Thú cưng có hoạt hình vật lý
- **Bước 1:** Ở Trang chủ, quan sát con Mèo Mimi
- **Kỳ vọng:** Mèo có hiệu ứng nảy nhẹ (lò xo), mắt nhìn theo con trỏ chuột / ngón tay

### TC-2.3 — Nhiệm vụ hôm nay hiển thị trên Trang chủ
- **Bước 1:** Cuộn xuống phần *"Việc hôm nay của con"*
- **Kỳ vọng:** Hiện 3 thẻ nhiệm vụ nhanh (VD: Dọn dẹp phòng, Đọc sách, Rửa chén đĩa) kèm số Sao thưởng

### TC-2.4 — Lối tắt nhanh hoạt động
- **Bước 1:** Cuộn xuống phần *"Lối tắt nhanh"*
- **Bước 2:** Bấm vào **"Đổi quà"**
- **Kỳ vọng:** Chuyển sang trang Cửa Hàng Đổi Quà

### TC-2.5 — Thanh điều hướng dưới cùng (Bottom Navigation)
- **Bước 1:** Bấm tab **"Nhiệm vụ"** trên thanh dưới
- **Kỳ vọng:** Chuyển sang tab Danh sách Nhiệm vụ
- **Bước 2:** Bấm tab **"Đổi quà"**
- **Kỳ vọng:** Chuyển sang tab Đổi Quà
- **Bước 3:** Bấm tab **"Thống kê"**
- **Kỳ vọng:** Chuyển sang tab Thống kê & Streak
- **Bước 4:** Bấm tab **"Trang chủ"**
- **Kỳ vọng:** Quay về Trang chủ

---

## Luồng 3: Danh Sách Nhiệm Vụ & Phân Loại

### TC-3.1 — Danh sách nhiệm vụ hiển thị đầy đủ
- **Bước 1:** Vào tab **Nhiệm vụ** trên Mobile App
- **Kỳ vọng:** Hiện tiêu đề *"📋 Nhiệm vụ của con"* và danh sách nhiệm vụ kèm emoji + số Sao

### TC-3.2 — Phân loại nhiệm vụ theo Tab
- **Bước 1:** Bấm tab **"🏠 Việc nhà"**
- **Kỳ vọng:** Chỉ hiện nhiệm vụ category `housework` (VD: Dọn phòng, Rửa bát, Quét nhà)
- **Bước 2:** Bấm tab **"📚 Học tập"**
- **Kỳ vọng:** Chỉ hiện nhiệm vụ category `study` (VD: Đọc sách 20 phút)
- **Bước 3:** Bấm tab **"Tất cả"**
- **Kỳ vọng:** Hiện lại tất cả nhiệm vụ

### TC-3.3 — Trạng thái nhiệm vụ hiển thị đúng màu
- **Bước 1:** Quan sát danh sách nhiệm vụ
- **Kỳ vọng:**
  - Nhiệm vụ `todo` → Nhãn **"Chưa làm"** (⚪ hoặc màu xám)
  - Nhiệm vụ `submitted` → Nhãn **"Chờ duyệt"** (🟠 cam)
  - Nhiệm vụ `approved` → Nhãn **"Đã duyệt"** (🟢 xanh lá)

### TC-3.4 — Bấm vào nhiệm vụ mở chi tiết
- **Bước 1:** Bấm vào thẻ nhiệm vụ *"Dọn phòng ngủ"*
- **Kỳ vọng:** Mở trang chi tiết nhiệm vụ, hiện mô tả + số Sao + kiểu xác minh (Ảnh chụp / Mã PIN)

### TC-3.5 — Nộp bài nhiệm vụ
- **Bước 1:** Ở trang chi tiết nhiệm vụ, bấm **"Chụp ảnh kết quả"** hoặc **"Nộp bài"**
- **Kỳ vọng:** Hiện thông báo *"Đã nộp bài, chờ bố mẹ duyệt"*, trạng thái chuyển sang `submitted`

---

## Luồng 4: Bố Mẹ Duyệt Bài (Web Dashboard + Mobile App)

### TC-4.1 — Web Dashboard hiển thị thống kê tổng quan
- **Bước 1:** Đăng nhập `http://localhost:8000` với tài khoản bố mẹ
- **Kỳ vọng:** Dashboard hiện đủ 4 thẻ: Tổng số Trẻ em, Nhiệm vụ Chờ duyệt, Hoàn thành hôm nay, Sao thưởng

### TC-4.2 — Web Dashboard: xem danh sách Trẻ em
- **Bước 1:** Bấm menu **"Trẻ em"** ở sidebar trái
- **Kỳ vọng:** Hiện danh sách **Bé Nam 😸** (50 Sao, Streak 7) và **Bé Linh 🐰** (38 Sao, Streak 5)

### TC-4.3 — Web Dashboard: xem Nhiệm vụ
- **Bước 1:** Bấm menu **"Nhiệm vụ"**
- **Kỳ vọng:** Hiện danh sách nhiệm vụ với cột Tên, Sao thưởng, Category, Kiểu xác minh

### TC-4.4 — Web Dashboard: mở trang Chờ duyệt
- **Bước 1:** Bấm menu **"Chờ duyệt"**
- **Kỳ vọng:** Hiện danh sách bài nộp đang ở trạng thái `submitted` (nếu có)

### TC-4.5 — Web Dashboard: duyệt bài 1-chạm
- **Điều kiện:** Có ít nhất 1 bài nộp chờ duyệt
- **Bước 1:** Bấm menu **"Chờ duyệt"**
- **Bước 2:** Bấm nút **"Duyệt ✅"** bên cạnh 1 bài nộp
- **Kỳ vọng:** Bài biến mất khỏi danh sách chờ duyệt, Sao thưởng cộng cho bé

### TC-4.6 — Web Dashboard: từ chối bài
- **Điều kiện:** Có ít nhất 1 bài nộp chờ duyệt
- **Bước 1:** Bấm nút **"Từ chối ❌"**
- **Kỳ vọng:** Bài biến mất, Sao KHÔNG được cộng

### TC-4.7 — Mobile App: Bố mẹ duyệt bài
- **Bước 1:** Trên Mobile App, chọn vai trò **"Bố mẹ"**
- **Bước 2:** Quan sát màn hình Duyệt bài Phụ huynh
- **Kỳ vọng:** Hiện tiêu đề *"Phụ Huynh — Duyệt Bài 👨‍👩‍👧"* và danh sách bài chờ duyệt (nếu có)

### TC-4.8 — Đồng bộ duyệt: Duyệt trên Web → Mobile cập nhật
- **Bước 1:** Mở Web Dashboard, duyệt 1 bài tập
- **Bước 2:** Quay lại Mobile App, vào tab **Nhiệm vụ**, kéo refresh hoặc F5
- **Kỳ vọng:** Bài vừa duyệt hiện trạng thái **"Đã duyệt 🟢"** trên Mobile App

---

## Luồng 5: Đổi Quà & Phần Thưởng

### TC-5.1 — Mobile App: xem danh sách Quà
- **Bước 1:** Vào tab **"Đổi quà"** trên thanh điều hướng dưới
- **Kỳ vọng:** Hiện tiêu đề *"Cửa Hàng Đổi Quà 🎁"* + số Sao hiện tại + danh sách quà kèm giá Sao

### TC-5.2 — Mobile App: đổi quà (đủ Sao)
- **Điều kiện:** Bé có đủ Sao để đổi quà
- **Bước 1:** Bấm nút **"30 ⭐"** (hoặc giá Sao) bên cạnh 1 phần thưởng
- **Bước 2:** Xác nhận đổi quà trong popup
- **Kỳ vọng:** Hiện thông báo *"Đã gửi yêu cầu đổi... thành công! 🎉"*, số Sao giảm

### TC-5.3 — Mobile App: đổi quà (thiếu Sao)
- **Điều kiện:** Bé có ít Sao hơn giá quà
- **Bước 1:** Quan sát nút bấm bên cạnh quà đắt tiền
- **Kỳ vọng:** Nút bị xám / disabled, không bấm được

### TC-5.4 — Web Dashboard: xem danh sách Phần thưởng
- **Bước 1:** Bấm menu **"Phần thưởng"** trên Web Dashboard
- **Kỳ vọng:** Hiện danh sách phần thưởng với Tên, Mô tả, Số Sao yêu cầu

### TC-5.5 — Web Dashboard: tạo phần thưởng mới
- **Bước 1:** Bấm **"Tạo phần thưởng mới"**
- **Bước 2:** Nhập Tên: "Đi công viên nước", Sao: 200
- **Bước 3:** Bấm **Lưu**
- **Kỳ vọng:** Quà mới xuất hiện trong danh sách

---

## Luồng 6: Thú Cưng — Tương Tác & Cửa Hàng Skin

### TC-6.1 — Trang thú cưng hiển thị đầy đủ
- **Bước 1:** Trên Mobile App, vào trang **Thú cưng** (từ Lối tắt "Chăm bé" hoặc route `/pet`)
- **Kỳ vọng:** Hiện Mèo Mimi kèm:
  - Trạng thái *"Mimi đang vui vẻ 😊"*
  - Thanh **Độ no nê** (VD: 60%)
  - Số Sao hiện tại
  - Nút **"Cho ăn"** và **"Chọc nhột"**

### TC-6.2 — Cho thú cưng ăn
- **Bước 1:** Bấm nút **"Cho ăn (-2 ⭐)"**
- **Kỳ vọng:**
  - Sao giảm 2 (VD: 45 → 43)
  - Thanh Độ no tăng (VD: 60% → 75%)
  - Phản hồi: *"Mimi ăn ngon miệng lắm! 🍖"*

### TC-6.3 — Chọc nhột thú cưng
- **Bước 1:** Bấm nút **"Chọc nhột"**
- **Kỳ vọng:** Phản hồi *"Hahaha, nhột quá chủ nhân ơi! 😂"*

### TC-6.4 — Cửa hàng Skin hiển thị đúng
- **Bước 1:** Vào route `/store` (từ Lối tắt "Tủ đồ")
- **Kỳ vọng:** Hiện tiêu đề *"🛍️ Cửa hàng & Tủ đồ"* + danh sách skin (Mèo Robot 🤖 - 15 Sao, Mèo Ninja 🥷 - 30 Sao)

### TC-6.5 — Mua skin thú cưng
- **Bước 1:** Bấm vào nút mua **Mèo Robot 🤖** (15 Sao)
- **Kỳ vọng:** Sao giảm 15, skin được mở khóa, hiện trạng thái "Đã mở khóa"

### TC-6.6 — Chọn loài thú cưng
- **Bước 1:** Vào route `/pet/select`
- **Kỳ vọng:** Hiện 4 loài: Mèo Mimi 🐱, Chó Rex 🐶, Rồng Spark 🐉, Thỏ Miffy 🐰

---

## Luồng 7: Gamification — Streak, Bảng Xếp Hạng, Timer, Gallery

### TC-7.1 — Trang Thống kê & Streak
- **Bước 1:** Vào tab **"Thống kê"** trên thanh điều hướng dưới
- **Kỳ vọng:** Hiện:
  - Tiêu đề *"Báo Cáo & Streak 🔥"*
  - Chuỗi Streak *"5 Ngày"*
  - Biểu đồ nhiệm vụ hoàn thành theo tuần

### TC-7.2 — Bảng Xếp Hạng Gia Đình
- **Bước 1:** Vào route `/family/leaderboard`
- **Kỳ vọng:** Hiện:
  - Tiêu đề *"Bảng Xếp Hạng Thi Đua 🏆"*
  - Bục vinh quang 🥇 🥈 🥉 xếp hạng các bé theo số Sao

### TC-7.3 — Đồng Hồ Pomodoro hiển thị đúng
- **Bước 1:** Vào route `/tasks/timer`
- **Kỳ vọng:** Hiện:
  - Tiêu đề *"Đồng Hồ Tập Trung ⏳"*
  - Đồng hồ hiện **25:00**
  - Nút **"Bắt đầu học"**

### TC-7.4 — Đồng Hồ Pomodoro đếm ngược
- **Bước 1:** Bấm nút **"Bắt đầu học"**
- **Bước 2:** Chờ 2-3 giây
- **Kỳ vọng:** Đồng hồ đếm ngược (VD: 24:58, 24:57...), nút đổi thành **"Tạm dừng"**

### TC-7.5 — Góc Kỷ Niệm & Lời Khen
- **Bước 1:** Vào route `/praise-gallery`
- **Kỳ vọng:** Hiện:
  - Tiêu đề *"Góc Kỷ Niệm & Lời Khen 💖"*
  - Feed ảnh bài nộp kèm sticker khen ngợi (VD: *"Xuất sắc!"*)

### TC-7.6 — Trung tâm Thông Báo
- **Bước 1:** Vào route `/notifications`
- **Kỳ vọng:** Hiện:
  - Tiêu đề *"Thông Báo 🔔"*
  - Danh sách thông báo (VD: *"🎉 Bài tập đã được duyệt!"*)

### TC-7.7 — Web Dashboard: Báo cáo & Biểu đồ
- **Bước 1:** Trên Web Dashboard, bấm menu **"Báo cáo"**
- **Kỳ vọng:** Hiện biểu đồ Chart.js nhiệm vụ hoàn thành 7 ngày qua

---

## Luồng 8: Cài Đặt & Responsive

### TC-8.1 — Trang Cài đặt hiển thị đầy đủ
- **Bước 1:** Vào route `/profile/settings`
- **Kỳ vọng:** Hiện:
  - Tiêu đề *"Cài Đặt & Hồ Sơ ⚙️"*
  - Tên bé *"Bé Nam 👦"*
  - Toggle **"Âm thanh hiệu ứng (Sound FX)"**
  - Toggle **"Thông báo"**

### TC-8.2 — Bật/Tắt Sound FX
- **Bước 1:** Bấm toggle **"Âm thanh hiệu ứng (Sound FX)"**
- **Kỳ vọng:** Toggle chuyển trạng thái ON ↔ OFF

### TC-8.3 — Khung iPhone trên Web
- **Bước 1:** Mở `http://localhost:8080` trên trình duyệt Desktop (màn hình rộng > 600px)
- **Kỳ vọng:** App hiển thị bên trong khung viền iPhone 15 Pro với Dynamic Island ở trên, nền xám bên ngoài

### TC-8.4 — Responsive: Mobile nhỏ không có khung
- **Bước 1:** Thu nhỏ cửa sổ trình duyệt xuống < 600px (hoặc dùng DevTools chọn iPhone)
- **Kỳ vọng:** App hiển thị toàn màn hình, KHÔNG có khung iPhone bao quanh

---

## Tổng Kết

| Luồng | Số Test Case | Nơi Test |
|-------|-------------|----------|
| 1. Đăng Nhập & Chọn Vai Trò | 8 | Mobile App + Web |
| 2. Trang Chủ & Thú Cưng | 5 | Mobile App |
| 3. Danh Sách Nhiệm Vụ | 5 | Mobile App |
| 4. Duyệt Bài (Web + Mobile) | 8 | Web + Mobile |
| 5. Đổi Quà & Phần Thưởng | 5 | Mobile App + Web |
| 6. Thú Cưng & Cửa Hàng Skin | 6 | Mobile App |
| 7. Gamification | 7 | Mobile App + Web |
| 8. Cài Đặt & Responsive | 4 | Mobile App + Web |
| **TỔNG CỘNG** | **48 Test Cases** | |
