# 🚀 KidTime — Smart Child Habit & Gamified Management Platform

> Nền tảng quản lý habit & phân công nhiệm vụ cho trẻ em kết hợp thú cưng hoạt hình sinh động, khóa ứng dụng giải trí thông minh và giao diện quản lý phụ huynh hiện đại.

---

## 🌟 Kiến Trúc Dự Án (Monorepo)

```
game-app-ideal/
├── backend/                  # Laravel 11 Clean DDD Architecture Backend
│   ├── app/                  # Domain, Infrastructure, Application & UI Layers
│   ├── resources/js/         # Parent Web Dashboard (Inertia.js + Vue 3 + PrimeVue)
│   ├── routes/               # API & Web routes
│   └── tests/                # PHPUnit & Feature Test Suites (15/15 passed)
└── mobile/                   # Flutter Clean Architecture Mobile App
    ├── lib/                  # Sprints 1-10 Features, Vector Physics Engine, Router
    ├── ios/                  # iOS Native Swift FamilyControls MethodChannel Bridge
    └── test/                 # Flutter Widget Test Suites (16/16 passed)
```

---

## 🛠️ Công Nghệ Sử Dụng (Tech Stack)

### Phía Backend & Web Dashboard
- **Laravel 11**: Clean Domain-Driven Design (DDD) Architecture.
- **Sanctum Auth**: Xác thực Email cho Bố mẹ & PIN 4 số nhanh gọn cho Trẻ em.
- **Inertia.js v2**: Bridge nối Laravel Controller trả về Vue 3 SPA không cần viết API thừa.
- **Vue 3 + PrimeVue 4**: Composition API `<script setup>`, PrimeVue components, Chart.js.
- **Tailwind CSS v3**: Thiết kế chuẩn màu sắc phụ huynh (`#6C63FF`, `#48CAE4`).

### Phía Mobile App
- **Flutter 3.x**: Cross-platform (iOS, Android, macOS).
- **Interactive Physics Vector Pet Engine**: `CustomPainter` rendering 60 FPS, Gaze/Eye tracking physics, Squish & Stretch lò xo, Drag-and-drop food magnet attraction, Particle Emitter overlay.
- **Multi-Species Support**: 🐱 Mèo Mimi, 🐶 Chó Rex, 🐉 Rồng Spark, 🐰 Thỏ Miffy.
- **iOS Native Swift FamilyControls Bridge**: Native Swift code quản lý `ManagedSettingsStore`.
- **Audio FX Sound Engine**: Tiếng nhai nhồm nhàm 🍖, tiếng cười khúc khích 😸, tiếng pháo hoa 🎺, tiếng ting-ting ⭐.

---

## 🚀 Hướng Dẫn Chạy Dự Án (Getting Started)

### 1. Phía Backend & Web Dashboard
```bash
# Chạy Docker Services
docker compose up -d

# Thực thi Migrate & Seed
docker compose exec app php artisan migrate --seed

# Chạy kiểm thử Backend
docker compose exec app php artisan test
```

### 2. Build Frontend Web Dashboard
```bash
cd backend
npm install
npm run build
```

### 3. Phía Mobile App (Flutter)
```bash
cd mobile
flutter pub get
flutter test
flutter run
```

---

## 🧪 Kết Quả Kiểm Thử (Verification)

- **Flutter Widget Tests**: `16/16 passed` 🟢
- **Laravel Backend Tests**: `15/15 passed` 🟢
- **Vite Bundle Build**: `899 modules built cleanly in 1.1s` 🟢

---

## 📄 Giấy Phép & Tác Quyền
Dự án được bảo hộ bởi bản quyền mở KidTime Platform.
