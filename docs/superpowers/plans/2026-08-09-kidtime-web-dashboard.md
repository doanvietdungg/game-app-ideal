# KidTime Web Dashboard Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Xây dựng Web Dashboard cho bố mẹ bằng Laravel 11 + Vue 3 + Inertia.js — quản lý gia đình, nhiệm vụ, app blocking, phần thưởng, và xem báo cáo phân tích.

**Architecture:** Laravel 11 phục vụ cả API (cho Flutter) lẫn Web (qua Inertia.js). Web dùng session auth (Sanctum stateful). Inertia.js là bridge — controller Laravel trả về Vue component thay vì Blade. State management dùng Pinia. Chart dùng Chart.js qua vue-chartjs.

**Tech Stack:** Laravel 11, Inertia.js v2, Vue 3 (Composition API + `<script setup>`), Pinia, Tailwind CSS v3, PrimeVue 4, Chart.js + vue-chartjs, Vite, Ziggy (Laravel routes trong JS).

## Global Constraints

- Vue 3 Composition API với `<script setup>` — không dùng Options API
- Tailwind CSS v3 — utility-first, không viết CSS thuần
- PrimeVue 4 cho form components (InputText, Dropdown, DataTable...)
- Font: Nunito (Google Fonts) cho toàn bộ web
- Color palette bố mẹ: Primary `#6C63FF`, Secondary `#48CAE4`, Background `#F8F9FF`
- Tất cả text tiếng Việt
- Mọi form phải có validation hiển thị lỗi inline (không dùng alert)
- Mọi action destructive (xóa) phải có confirm dialog
- Responsive: hoạt động tốt ở 1280px+ (desktop-first)

---

## Task 1: Project Setup — Laravel + Inertia.js + Vue 3

**Files:**
- Modify: `package.json`
- Modify: `vite.config.js`
- Modify: `resources/js/app.js`
- Create: `resources/js/bootstrap.js`
- Create: `resources/css/app.css`
- Modify: `resources/views/app.blade.php`
- Create: `resources/js/Layouts/AppLayout.vue`
- Create: `resources/js/Layouts/AuthLayout.vue`
- Modify: `routes/web.php`

**Interfaces:**
- Produces: Laravel + Inertia.js + Vue 3 hoạt động, layout cơ bản, Tailwind + PrimeVue sẵn sàng

- [ ] **Step 1: Cài packages**

```bash
composer require inertiajs/inertia-laravel tightenco/ziggy
npm install @inertiajs/vue3 vue @vitejs/plugin-vue pinia
npm install tailwindcss @tailwindcss/forms autoprefixer postcss
npm install primevue @primevue/themes primeicons
npm install chart.js vue-chartjs
npm install @vueuse/core axios
npx tailwindcss init -p
```

- [ ] **Step 2: Cấu hình Vite**

```js
// vite.config.js
import { defineConfig } from 'vite'
import laravel from 'laravel-vite-plugin'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
    plugins: [
        laravel({ input: ['resources/css/app.css', 'resources/js/app.js'], refresh: true }),
        vue({ template: { transformAssetUrls: { base: null, includeAbsolute: false } } }),
    ],
    resolve: { alias: { '@': '/resources/js' } },
})
```

- [ ] **Step 3: Cấu hình Tailwind**

```js
// tailwind.config.js
export default {
    content: ['./resources/**/*.{js,vue,blade.php}'],
    theme: {
        extend: {
            colors: {
                primary: { DEFAULT: '#6C63FF', 50: '#f0effe', 100: '#e3e0fd', 500: '#6C63FF', 600: '#5a52e6', 700: '#4840cc' },
                sky: { DEFAULT: '#48CAE4' },
            },
            fontFamily: { sans: ['Nunito', 'sans-serif'] },
        },
    },
    plugins: [require('@tailwindcss/forms')],
}
```

- [ ] **Step 4: Cài Inertia middleware**

```bash
php artisan inertia:middleware
```

Thêm vào `bootstrap/app.php`:
```php
->withMiddleware(function (Middleware $middleware) {
    $middleware->web(append: [\App\Http\Middleware\HandleInertiaRequests::class]);
})
```

- [ ] **Step 5: Tạo Blade root view**

```html
<!-- resources/views/app.blade.php -->
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>KidTime — Quản lý gia đình</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Nunito:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    @routes
    @vite(['resources/css/app.css', 'resources/js/app.js'])
    @inertiaHead
</head>
<body class="font-sans bg-[#F8F9FF] antialiased">
    @inertia
</body>
</html>
```

- [ ] **Step 6: Khởi tạo Vue + Inertia**

```js
// resources/js/app.js
import { createApp, h } from 'vue'
import { createInertiaApp } from '@inertiajs/vue3'
import { resolvePageComponent } from 'laravel-vite-plugin/inertia-helpers'
import { ZiggyVue } from '../../vendor/tightenco/ziggy'
import { createPinia } from 'pinia'
import PrimeVue from 'primevue/config'
import Aura from '@primevue/themes/aura'
import 'primeicons/primeicons.css'
import '../css/app.css'

createInertiaApp({
    title: (title) => title ? `${title} — KidTime` : 'KidTime',
    resolve: (name) => resolvePageComponent(`./Pages/${name}.vue`, import.meta.glob('./Pages/**/*.vue')),
    setup({ el, App, props, plugin }) {
        createApp({ render: () => h(App, props) })
            .use(plugin)
            .use(ZiggyVue)
            .use(createPinia())
            .use(PrimeVue, { theme: { preset: Aura, options: { darkModeSelector: false } } })
            .mount(el)
    },
    progress: { color: '#6C63FF' },
})
```

- [ ] **Step 7: Tạo AppLayout (Layout chính sau đăng nhập)**

```vue
<!-- resources/js/Layouts/AppLayout.vue -->
<script setup>
import { Link, usePage } from '@inertiajs/vue3'
import { computed } from 'vue'

const page = usePage()
const user = computed(() => page.props.auth.user)
</script>

<template>
  <div class="min-h-screen flex">
    <!-- Sidebar -->
    <aside class="w-64 bg-white border-r border-gray-100 flex flex-col shadow-sm">
      <!-- Logo -->
      <div class="p-6 border-b border-gray-100">
        <div class="flex items-center gap-3">
          <div class="w-9 h-9 rounded-xl bg-primary flex items-center justify-center text-white font-bold text-lg">K</div>
          <span class="font-extrabold text-xl text-gray-800">KidTime</span>
        </div>
      </div>

      <!-- Nav -->
      <nav class="flex-1 p-4 space-y-1">
        <Link :href="route('dashboard')" class="nav-item" :class="{ active: $page.component === 'Dashboard' }">
          <i class="pi pi-home text-base"></i> Dashboard
        </Link>
        <Link :href="route('children.index')" class="nav-item" :class="{ active: $page.component.startsWith('Children') }">
          <i class="pi pi-users text-base"></i> Trẻ em
        </Link>
        <Link :href="route('tasks.index')" class="nav-item" :class="{ active: $page.component.startsWith('Tasks') }">
          <i class="pi pi-check-square text-base"></i> Nhiệm vụ
        </Link>
        <Link :href="route('rewards.index')" class="nav-item" :class="{ active: $page.component.startsWith('Rewards') }">
          <i class="pi pi-gift text-base"></i> Phần thưởng
        </Link>
        <Link :href="route('pending.index')" class="nav-item relative" :class="{ active: $page.component.startsWith('Pending') }">
          <i class="pi pi-bell text-base"></i> Chờ duyệt
          <span v-if="page.props.pendingCount > 0" class="absolute right-3 top-2.5 bg-red-500 text-white text-xs rounded-full w-5 h-5 flex items-center justify-center font-bold">
            {{ page.props.pendingCount }}
          </span>
        </Link>
        <Link :href="route('analytics.index')" class="nav-item" :class="{ active: $page.component.startsWith('Analytics') }">
          <i class="pi pi-chart-bar text-base"></i> Báo cáo
        </Link>
        <Link :href="route('settings.index')" class="nav-item" :class="{ active: $page.component.startsWith('Settings') }">
          <i class="pi pi-cog text-base"></i> Cài đặt
        </Link>
      </nav>

      <!-- User info -->
      <div class="p-4 border-t border-gray-100">
        <div class="flex items-center gap-3 p-3 rounded-xl hover:bg-gray-50 transition-colors">
          <div class="w-8 h-8 rounded-full bg-primary-100 flex items-center justify-center text-primary font-bold text-sm">
            {{ user?.name?.[0] }}
          </div>
          <div class="flex-1 min-w-0">
            <p class="text-sm font-semibold text-gray-800 truncate">{{ user?.name }}</p>
          </div>
          <Link :href="route('logout')" method="post" as="button" class="text-gray-400 hover:text-red-500 transition-colors">
            <i class="pi pi-sign-out text-sm"></i>
          </Link>
        </div>
      </div>
    </aside>

    <!-- Main content -->
    <main class="flex-1 overflow-auto">
      <div class="p-8">
        <slot />
      </div>
    </main>
  </div>
</template>

<style scoped>
.nav-item {
  @apply flex items-center gap-3 px-4 py-2.5 rounded-xl text-gray-600 font-medium text-sm transition-all duration-150 hover:bg-primary-50 hover:text-primary;
}
.nav-item.active {
  @apply bg-primary-50 text-primary font-semibold;
}
</style>
```

- [ ] **Step 8: Tạo AuthLayout (Login/Register)**

```vue
<!-- resources/js/Layouts/AuthLayout.vue -->
<template>
  <div class="min-h-screen bg-gradient-to-br from-primary-50 via-white to-sky-50 flex items-center justify-center p-4">
    <div class="w-full max-w-md">
      <div class="text-center mb-8">
        <div class="w-16 h-16 rounded-2xl bg-primary mx-auto flex items-center justify-center text-white font-extrabold text-3xl shadow-lg shadow-primary/25 mb-4">K</div>
        <h1 class="text-2xl font-extrabold text-gray-800">KidTime</h1>
        <p class="text-gray-500 text-sm mt-1">Quản lý thời gian màn hình cho trẻ</p>
      </div>
      <div class="bg-white rounded-2xl shadow-xl shadow-gray-100/50 p-8">
        <slot />
      </div>
    </div>
  </div>
</template>
```

- [ ] **Step 9: Tạo Inertia HandleInertiaRequests middleware (share auth + pendingCount)**

```php
// app/Http/Middleware/HandleInertiaRequests.php
public function share(Request $request): array {
    return [
        ...parent::share($request),
        'auth' => ['user' => $request->user()],
        'pendingCount' => fn() => $request->user()
            ? TaskLog::whereHas('child', fn($q) => $q->where('family_id', $request->user()->family_id))
                ->where('status', TaskLogStatus::Submitted)->count()
            : 0,
        'flash' => ['success' => fn() => $request->session()->get('success'),
                    'error' => fn() => $request->session()->get('error')],
    ];
}
```

- [ ] **Step 10: Chạy dev server**

```bash
npm run dev
php artisan serve
```

Mở http://localhost:8000 — xác nhận không có lỗi console.

- [ ] **Step 11: Commit**

```bash
git add -A
git commit -m "feat: setup Laravel + Inertia.js + Vue 3 + Tailwind + PrimeVue"
```

---

## Task 2: Authentication Pages (Login + Register)

**Files:**
- Create: `app/Http/Controllers/Web/AuthController.php`
- Create: `resources/js/Pages/Auth/Login.vue`
- Create: `resources/js/Pages/Auth/Register.vue`
- Create: `resources/js/Components/FormField.vue`
- Modify: `routes/web.php`

**Interfaces:**
- Consumes: `AuthLayout`, session auth (Sanctum stateful)
- Produces: `/login`, `/register` hoạt động, redirect về `/dashboard` sau khi đăng nhập

- [ ] **Step 1: Tạo reusable FormField component**

```vue
<!-- resources/js/Components/FormField.vue -->
<script setup>
defineProps({ label: String, error: String, required: Boolean })
</script>
<template>
  <div class="space-y-1.5">
    <label class="block text-sm font-semibold text-gray-700">
      {{ label }} <span v-if="required" class="text-red-500">*</span>
    </label>
    <slot />
    <p v-if="error" class="text-xs text-red-500 flex items-center gap-1">
      <i class="pi pi-exclamation-circle text-xs"></i> {{ error }}
    </p>
  </div>
</template>
```

- [ ] **Step 2: Tạo Login page**

```vue
<!-- resources/js/Pages/Auth/Login.vue -->
<script setup>
import { useForm } from '@inertiajs/vue3'
import AuthLayout from '@/Layouts/AuthLayout.vue'
import FormField from '@/Components/FormField.vue'
import InputText from 'primevue/inputtext'
import Password from 'primevue/password'
import Button from 'primevue/button'

defineOptions({ layout: AuthLayout })

const form = useForm({ email: '', password: '', remember: false })

const submit = () => form.post(route('login'), { onError: () => form.reset('password') })
</script>

<template>
  <div>
    <h2 class="text-xl font-extrabold text-gray-800 mb-6">Đăng nhập</h2>
    <form @submit.prevent="submit" class="space-y-5">
      <FormField label="Email" :error="form.errors.email" required>
        <InputText v-model="form.email" type="email" placeholder="email@example.com"
          class="w-full" :invalid="!!form.errors.email" autocomplete="email" />
      </FormField>
      <FormField label="Mật khẩu" :error="form.errors.password" required>
        <Password v-model="form.password" placeholder="••••••••"
          class="w-full" :invalid="!!form.errors.password" :feedback="false" toggleMask />
      </FormField>
      <Button type="submit" label="Đăng nhập" class="w-full" :loading="form.processing" />
    </form>
    <p class="text-center text-sm text-gray-500 mt-6">
      Chưa có tài khoản?
      <Link :href="route('register')" class="text-primary font-semibold hover:underline">Đăng ký</Link>
    </p>
  </div>
</template>
```

- [ ] **Step 3: Tạo Register page**

```vue
<!-- resources/js/Pages/Auth/Register.vue -->
<script setup>
import { useForm } from '@inertiajs/vue3'
import AuthLayout from '@/Layouts/AuthLayout.vue'
import FormField from '@/Components/FormField.vue'
import InputText from 'primevue/inputtext'
import Password from 'primevue/password'
import Button from 'primevue/button'

defineOptions({ layout: AuthLayout })

const form = useForm({
  name: '', email: '', password: '', password_confirmation: '',
  family_name: '', family_pin: '',
})

const submit = () => form.post(route('register'))
</script>

<template>
  <div>
    <h2 class="text-xl font-extrabold text-gray-800 mb-6">Tạo tài khoản</h2>
    <form @submit.prevent="submit" class="space-y-4">
      <div class="grid grid-cols-2 gap-4">
        <FormField label="Họ và tên" :error="form.errors.name" required>
          <InputText v-model="form.name" placeholder="Nguyễn Văn A" class="w-full" :invalid="!!form.errors.name" />
        </FormField>
        <FormField label="Email" :error="form.errors.email" required>
          <InputText v-model="form.email" type="email" placeholder="email@example.com" class="w-full" :invalid="!!form.errors.email" />
        </FormField>
      </div>
      <div class="grid grid-cols-2 gap-4">
        <FormField label="Mật khẩu" :error="form.errors.password" required>
          <Password v-model="form.password" class="w-full" :invalid="!!form.errors.password" toggleMask />
        </FormField>
        <FormField label="Xác nhận mật khẩu" :error="form.errors.password_confirmation">
          <Password v-model="form.password_confirmation" class="w-full" :feedback="false" toggleMask />
        </FormField>
      </div>
      <div class="border-t pt-4 mt-2">
        <p class="text-xs font-semibold text-gray-500 uppercase tracking-wider mb-3">Thông tin gia đình</p>
        <div class="grid grid-cols-2 gap-4">
          <FormField label="Tên gia đình" :error="form.errors.family_name" required>
            <InputText v-model="form.family_name" placeholder="Gia đình Nguyễn" class="w-full" :invalid="!!form.errors.family_name" />
          </FormField>
          <FormField label="PIN trẻ đăng nhập (4 số)" :error="form.errors.family_pin" required>
            <InputText v-model="form.family_pin" placeholder="1234" maxlength="4" class="w-full" :invalid="!!form.errors.family_pin" />
          </FormField>
        </div>
      </div>
      <Button type="submit" label="Tạo tài khoản" class="w-full mt-2" :loading="form.processing" />
    </form>
    <p class="text-center text-sm text-gray-500 mt-6">
      Đã có tài khoản? <Link :href="route('login')" class="text-primary font-semibold hover:underline">Đăng nhập</Link>
    </p>
  </div>
</template>
```

- [ ] **Step 4: Tạo Web AuthController**

```php
// app/Http/Controllers/Web/AuthController.php
class AuthController extends Controller {
    public function showLogin() { return inertia('Auth/Login'); }
    public function showRegister() { return inertia('Auth/Register'); }

    public function login(LoginRequest $request) {
        if (!Auth::attempt($request->only('email', 'password'), $request->boolean('remember'))) {
            throw ValidationException::withMessages(['email' => 'Email hoặc mật khẩu không đúng.']);
        }
        $request->session()->regenerate();
        return redirect()->intended(route('dashboard'));
    }

    public function register(RegisterRequest $request) {
        $family = Family::create(['name' => $request->family_name, 'pin' => Hash::make($request->family_pin)]);
        $user = User::create([
            'name' => $request->name, 'email' => $request->email,
            'password' => Hash::make($request->password),
            'family_id' => $family->id, 'role' => 'parent',
        ]);
        Auth::login($user);
        return redirect()->route('dashboard');
    }

    public function logout(Request $request) {
        Auth::logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();
        return redirect()->route('login');
    }
}
```

- [ ] **Step 5: Thêm routes web**

```php
// routes/web.php
Route::middleware('guest')->group(function () {
    Route::get('/login', [AuthController::class, 'showLogin'])->name('login');
    Route::post('/login', [AuthController::class, 'login']);
    Route::get('/register', [AuthController::class, 'showRegister'])->name('register');
    Route::post('/register', [AuthController::class, 'register']);
});

Route::middleware('auth')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout'])->name('logout');
    // ... các routes khác
});
```

- [ ] **Step 6: Test thủ công**

Mở http://localhost:8000/register → điền form → submit → xác nhận redirect về /dashboard.

- [ ] **Step 7: Commit**

```bash
git add resources/js/Pages/Auth/ resources/js/Components/FormField.vue app/Http/Controllers/Web/AuthController.php routes/web.php
git commit -m "feat: add login and register pages with Inertia + Vue 3"
```

---

## Task 3: Dashboard Tổng quan

**Files:**
- Create: `app/Http/Controllers/Web/DashboardController.php`
- Create: `resources/js/Pages/Dashboard.vue`
- Create: `resources/js/Components/StatCard.vue`
- Create: `resources/js/Components/ChildAvatarCard.vue`
- Modify: `routes/web.php`

**Interfaces:**
- Consumes: `Child`, `TaskLog`, `AppLayout`
- Produces: `/dashboard` — hiện tổng quan: số con, nhiệm vụ hôm nay, sao, pending count, chart tuần

- [ ] **Step 1: Tạo DashboardController**

```php
// app/Http/Controllers/Web/DashboardController.php
class DashboardController extends Controller {
    public function index(Request $request) {
        $familyId = $request->user()->family_id;
        $children = Child::where('family_id', $familyId)->with('pet')->get();

        $todayLogs = TaskLog::whereHas('child', fn($q) => $q->where('family_id', $familyId))
            ->whereDate('due_date', today())
            ->with(['task', 'child'])
            ->get();

        // Chart data: 7 ngày gần nhất
        $weekData = collect(range(6, 0))->map(function ($daysAgo) use ($familyId) {
            $date = now()->subDays($daysAgo)->toDateString();
            $count = TaskLog::whereHas('child', fn($q) => $q->where('family_id', $familyId))
                ->where('status', TaskLogStatus::Approved)
                ->whereDate('due_date', $date)->count();
            return ['date' => $date, 'label' => now()->subDays($daysAgo)->locale('vi')->isoFormat('ddd'), 'count' => $count];
        });

        return inertia('Dashboard', [
            'children' => $children,
            'todayLogs' => $todayLogs,
            'weekData' => $weekData,
            'stats' => [
                'totalChildren' => $children->count(),
                'pendingReview' => $todayLogs->where('status', TaskLogStatus::Submitted->value)->count(),
                'completedToday' => $todayLogs->where('status', TaskLogStatus::Approved->value)->count(),
                'totalStarsToday' => $todayLogs->where('status', TaskLogStatus::Approved->value)->sum(fn($l) => $l->task->stars ?? 0),
            ],
        ]);
    }
}
```

- [ ] **Step 2: Tạo StatCard component**

```vue
<!-- resources/js/Components/StatCard.vue -->
<script setup>
defineProps({ label: String, value: [String, Number], icon: String, color: { type: String, default: 'primary' }, trend: String })
const colors = { primary: 'bg-primary-50 text-primary', sky: 'bg-sky-50 text-sky-500', green: 'bg-green-50 text-green-600', amber: 'bg-amber-50 text-amber-600' }
</script>
<template>
  <div class="bg-white rounded-2xl p-6 shadow-sm border border-gray-100 flex items-center gap-5">
    <div :class="['w-12 h-12 rounded-xl flex items-center justify-center text-xl', colors[color]]">
      <i :class="`pi ${icon}`"></i>
    </div>
    <div>
      <p class="text-2xl font-extrabold text-gray-800">{{ value }}</p>
      <p class="text-sm text-gray-500 font-medium">{{ label }}</p>
    </div>
  </div>
</template>
```

- [ ] **Step 3: Tạo Dashboard page**

```vue
<!-- resources/js/Pages/Dashboard.vue -->
<script setup>
import { computed } from 'vue'
import { Link } from '@inertiajs/vue3'
import AppLayout from '@/Layouts/AppLayout.vue'
import StatCard from '@/Components/StatCard.vue'
import { Bar } from 'vue-chartjs'
import { Chart as ChartJS, CategoryScale, LinearScale, BarElement, Tooltip } from 'chart.js'
ChartJS.register(CategoryScale, LinearScale, BarElement, Tooltip)

defineOptions({ layout: AppLayout })
const props = defineProps({ children: Array, stats: Object, weekData: Array, todayLogs: Array })

const chartData = computed(() => ({
  labels: props.weekData.map(d => d.label),
  datasets: [{ data: props.weekData.map(d => d.count), backgroundColor: '#6C63FF', borderRadius: 8, borderSkipped: false }]
}))
const chartOptions = { responsive: true, maintainAspectRatio: false, plugins: { legend: { display: false } }, scales: { y: { beginAtZero: true, ticks: { stepSize: 1 }, grid: { color: '#f3f4f6' } }, x: { grid: { display: false } } } }

const rankLabel = (rank) => ({ bronze: '🥉 Bronze', silver: '🥈 Silver', gold: '🥇 Gold', platinum: '💎 Platinum', diamond: '👑 Diamond' })[rank] ?? rank
</script>

<template>
  <div class="space-y-8">
    <!-- Header -->
    <div>
      <h1 class="text-2xl font-extrabold text-gray-800">Dashboard</h1>
      <p class="text-gray-500 text-sm mt-1">Tổng quan hoạt động gia đình hôm nay</p>
    </div>

    <!-- Stats -->
    <div class="grid grid-cols-4 gap-4">
      <StatCard label="Trẻ em" :value="stats.totalChildren" icon="pi-users" color="primary" />
      <StatCard label="Chờ duyệt" :value="stats.pendingReview" icon="pi-bell" color="amber" />
      <StatCard label="Hoàn thành hôm nay" :value="stats.completedToday" icon="pi-check-circle" color="green" />
      <StatCard label="Sao kiếm được hôm nay" :value="`${stats.totalStarsToday} ⭐`" icon="pi-star" color="sky" />
    </div>

    <div class="grid grid-cols-3 gap-6">
      <!-- Chart -->
      <div class="col-span-2 bg-white rounded-2xl p-6 shadow-sm border border-gray-100">
        <h2 class="font-extrabold text-gray-800 mb-4">Hoạt động 7 ngày qua</h2>
        <div class="h-48">
          <Bar :data="chartData" :options="chartOptions" />
        </div>
      </div>

      <!-- Children quick view -->
      <div class="bg-white rounded-2xl p-6 shadow-sm border border-gray-100">
        <div class="flex items-center justify-between mb-4">
          <h2 class="font-extrabold text-gray-800">Trẻ em</h2>
          <Link :href="route('children.index')" class="text-xs text-primary font-semibold hover:underline">Xem tất cả</Link>
        </div>
        <div class="space-y-3">
          <div v-for="child in children" :key="child.id" class="flex items-center gap-3 p-3 rounded-xl hover:bg-gray-50 transition-colors">
            <div class="w-10 h-10 rounded-full bg-primary-50 flex items-center justify-center text-lg font-bold text-primary">
              {{ child.name[0] }}
            </div>
            <div class="flex-1 min-w-0">
              <p class="font-semibold text-gray-800 text-sm">{{ child.name }}</p>
              <p class="text-xs text-gray-400">{{ rankLabel(child.rank) }} · {{ child.available_stars }}⭐ có thể dùng</p>
            </div>
            <span class="text-sm">🔥 {{ child.streak_days }}</span>
          </div>
          <div v-if="!children.length" class="text-center py-4 text-gray-400 text-sm">
            Chưa có trẻ nào. <Link :href="route('children.create')" class="text-primary font-semibold">Thêm ngay</Link>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
```

- [ ] **Step 4: Thêm route + commit**

```php
Route::get('/dashboard', [DashboardController::class, 'index'])->name('dashboard');
Route::get('/', fn() => redirect()->route('dashboard'));
```

```bash
git add resources/js/Pages/Dashboard.vue resources/js/Components/ app/Http/Controllers/Web/DashboardController.php
git commit -m "feat: add dashboard with stats, weekly chart, and children overview"
```

---

## Task 4: Quản lý Trẻ em (CRUD)

**Files:**
- Create: `app/Http/Controllers/Web/ChildController.php`
- Create: `resources/js/Pages/Children/Index.vue`
- Create: `resources/js/Pages/Children/Create.vue`
- Create: `resources/js/Pages/Children/Edit.vue`
- Create: `resources/js/Components/ConfirmDialog.vue`
- Modify: `routes/web.php`

**Interfaces:**
- Produces: `/children` (list), `/children/create`, `/children/{id}/edit` — CRUD đầy đủ

- [ ] **Step 1: Tạo ChildController (Web)**

```php
// app/Http/Controllers/Web/ChildController.php
class ChildController extends Controller {
    public function index(Request $request) {
        $children = Child::where('family_id', $request->user()->family_id)->with('pet')->get();
        return inertia('Children/Index', ['children' => $children]);
    }

    public function create() {
        return inertia('Children/Create', [
            'petSpecies' => PetSpecies::cases(),
        ]);
    }

    public function store(StoreChildRequest $request) {
        $familyId = $request->user()->family_id;
        if (Child::where('family_id', $familyId)->count() >= 5) {
            return back()->withErrors(['name' => 'Gia đình tối đa 5 trẻ em.']);
        }
        $child = Child::create([...$request->validated(), 'family_id' => $familyId]);
        Pet::create(['child_id' => $child->id, 'species' => $request->pet_species]);
        return redirect()->route('children.index')->with('success', "Đã thêm {$child->name}!");
    }

    public function edit(Child $child) {
        return inertia('Children/Edit', ['child' => $child->load('pet'), 'petSpecies' => PetSpecies::cases()]);
    }

    public function update(UpdateChildRequest $request, Child $child) {
        $child->update($request->validated());
        return redirect()->route('children.index')->with('success', 'Đã cập nhật thông tin.');
    }

    public function destroy(Child $child) {
        $name = $child->name;
        $child->delete();
        return redirect()->route('children.index')->with('success', "Đã xóa {$name}.");
    }
}
```

- [ ] **Step 2: Tạo ConfirmDialog component**

```vue
<!-- resources/js/Components/ConfirmDialog.vue -->
<script setup>
import { ref } from 'vue'
import Button from 'primevue/button'

const show = ref(false)
const resolve = ref(null)

const open = () => new Promise(r => { resolve.value = r; show.value = true })
const confirm = () => { resolve.value(true); show.value = false }
const cancel = () => { resolve.value(false); show.value = false }

defineExpose({ open })
defineProps({ title: { type: String, default: 'Xác nhận xóa' }, message: { type: String, default: 'Bạn có chắc chắn muốn xóa không? Hành động này không thể hoàn tác.' } })
</script>

<template>
  <Teleport to="body">
    <Transition enter-active-class="transition-all duration-200" leave-active-class="transition-all duration-200" enter-from-class="opacity-0" leave-to-class="opacity-0">
      <div v-if="show" class="fixed inset-0 bg-black/40 z-50 flex items-center justify-center p-4" @click.self="cancel">
        <div class="bg-white rounded-2xl p-6 max-w-sm w-full shadow-2xl">
          <div class="w-12 h-12 rounded-full bg-red-50 flex items-center justify-center mx-auto mb-4">
            <i class="pi pi-exclamation-triangle text-red-500 text-xl"></i>
          </div>
          <h3 class="text-lg font-extrabold text-gray-800 text-center">{{ title }}</h3>
          <p class="text-gray-500 text-sm text-center mt-2 mb-6">{{ message }}</p>
          <div class="flex gap-3">
            <Button label="Hủy" severity="secondary" class="flex-1" @click="cancel" />
            <Button label="Xóa" severity="danger" class="flex-1" @click="confirm" />
          </div>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>
```

- [ ] **Step 3: Tạo Children/Index page**

```vue
<!-- resources/js/Pages/Children/Index.vue -->
<script setup>
import { ref } from 'vue'
import { Link, router } from '@inertiajs/vue3'
import AppLayout from '@/Layouts/AppLayout.vue'
import ConfirmDialog from '@/Components/ConfirmDialog.vue'
import Button from 'primevue/button'

defineOptions({ layout: AppLayout })
const props = defineProps({ children: Array })
const confirmRef = ref(null)

const petEmoji = { cat: '🐱', bunny: '🐰', bear: '🐻', dinosaur: '🦕', penguin: '🐧', dragon: '🐲' }
const rankLabel = (rank) => ({ bronze: '🥉 Bronze', silver: '🥈 Silver', gold: '🥇 Gold', platinum: '💎 Platinum', diamond: '👑 Diamond' }[rank] ?? rank)

const deleteChild = async (child) => {
  const confirmed = await confirmRef.value.open()
  if (confirmed) router.delete(route('children.destroy', child.id))
}
</script>

<template>
  <div class="space-y-6">
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-2xl font-extrabold text-gray-800">Trẻ em</h1>
        <p class="text-sm text-gray-500 mt-1">Quản lý hồ sơ các con trong gia đình (tối đa 5)</p>
      </div>
      <Link :href="route('children.create')">
        <Button label="Thêm trẻ" icon="pi pi-plus" />
      </Link>
    </div>

    <div class="grid grid-cols-3 gap-5">
      <div v-for="child in children" :key="child.id"
        class="bg-white rounded-2xl p-6 shadow-sm border border-gray-100 hover:shadow-md transition-shadow">
        <div class="flex items-start justify-between mb-4">
          <div class="w-14 h-14 rounded-2xl bg-primary-50 flex items-center justify-center text-3xl">
            {{ petEmoji[child.pet?.species] ?? '🐾' }}
          </div>
          <div class="flex gap-2">
            <Link :href="route('children.edit', child.id)">
              <Button icon="pi pi-pencil" severity="secondary" size="small" text rounded />
            </Link>
            <Button icon="pi pi-trash" severity="danger" size="small" text rounded @click="deleteChild(child)" />
          </div>
        </div>
        <h3 class="font-extrabold text-gray-800 text-lg">{{ child.name }}</h3>
        <p class="text-gray-400 text-sm">{{ child.age }} tuổi · {{ rankLabel(child.rank) }}</p>
        <div class="mt-4 grid grid-cols-3 gap-3 pt-4 border-t border-gray-50">
          <div class="text-center">
            <p class="font-bold text-gray-800">{{ child.available_stars }}</p>
            <p class="text-xs text-gray-400">Sao còn</p>
          </div>
          <div class="text-center">
            <p class="font-bold text-gray-800">{{ child.total_stars }}</p>
            <p class="text-xs text-gray-400">Tổng sao</p>
          </div>
          <div class="text-center">
            <p class="font-bold text-gray-800">🔥 {{ child.streak_days }}</p>
            <p class="text-xs text-gray-400">Streak</p>
          </div>
        </div>
      </div>

      <!-- Empty state -->
      <div v-if="!children.length" class="col-span-3 text-center py-16 bg-white rounded-2xl border border-gray-100">
        <div class="text-5xl mb-4">👶</div>
        <p class="font-bold text-gray-600">Chưa có trẻ nào</p>
        <p class="text-gray-400 text-sm mt-1 mb-6">Thêm con đầu tiên vào gia đình</p>
        <Link :href="route('children.create')"><Button label="Thêm ngay" icon="pi pi-plus" /></Link>
      </div>
    </div>

    <ConfirmDialog ref="confirmRef" message="Xóa trẻ sẽ xóa toàn bộ dữ liệu nhiệm vụ và Sao của bé." />
  </div>
</template>
```

- [ ] **Step 4: Thêm routes + commit**

```php
Route::resource('children', ChildController::class)->except(['show']);
```

```bash
git add resources/js/Pages/Children/ resources/js/Components/ConfirmDialog.vue app/Http/Controllers/Web/ChildController.php
git commit -m "feat: add children management pages (CRUD) with confirm dialog"
```

---

## Task 5: Quản lý Nhiệm vụ

**Files:**
- Create: `app/Http/Controllers/Web/TaskController.php`
- Create: `resources/js/Pages/Tasks/Index.vue`
- Create: `resources/js/Pages/Tasks/Create.vue`
- Modify: `routes/web.php`

**Interfaces:**
- Produces: `/tasks` list + filter, `/tasks/create` form với template library

- [ ] **Step 1: Tạo TaskController (Web)**

```php
// app/Http/Controllers/Web/TaskController.php
class TaskController extends Controller {
    public function index(Request $request) {
        $tasks = Task::where('family_id', $request->user()->family_id)
            ->with('child')->orderByDesc('created_at')->get();
        $children = Child::where('family_id', $request->user()->family_id)->get(['id', 'name']);
        return inertia('Tasks/Index', compact('tasks', 'children'));
    }

    public function create(Request $request) {
        $children = Child::where('family_id', $request->user()->family_id)->get(['id', 'name']);
        $templates = Task::where('is_template', true)->get();
        return inertia('Tasks/Create', compact('children', 'templates'));
    }

    public function store(StoreTaskRequest $request) {
        Task::create([...$request->validated(), 'family_id' => $request->user()->family_id]);
        return redirect()->route('tasks.index')->with('success', 'Đã tạo nhiệm vụ!');
    }

    public function destroy(Task $task) {
        $task->delete();
        return redirect()->route('tasks.index')->with('success', 'Đã xóa nhiệm vụ.');
    }
}
```

- [ ] **Step 2: Tạo Tasks/Create page (với template library)**

```vue
<!-- resources/js/Pages/Tasks/Create.vue -->
<script setup>
import { ref, computed } from 'vue'
import { useForm } from '@inertiajs/vue3'
import AppLayout from '@/Layouts/AppLayout.vue'
import FormField from '@/Components/FormField.vue'
import InputText from 'primevue/inputtext'
import Textarea from 'primevue/textarea'
import Select from 'primevue/select'
import InputNumber from 'primevue/inputnumber'
import Button from 'primevue/button'
import ToggleButton from 'primevue/togglebutton'

defineOptions({ layout: AppLayout })
const props = defineProps({ children: Array, templates: Array })

const categories = [
  { label: '🏠 Việc nhà', value: 'housework' }, { label: '📚 Học tập', value: 'study' },
  { label: '🏃 Vận động', value: 'exercise' }, { label: '🥦 Ăn uống', value: 'eating' },
  { label: '😴 Giấc ngủ', value: 'sleep' },
]
const verificationModes = [
  { label: '📸 Ảnh chứng minh', value: 'photo' },
  { label: '🔑 PIN bố mẹ', value: 'pin' },
  { label: '✅ Tự động', value: 'auto' },
]
const recurrences = [
  { label: 'Một lần', value: 'once' }, { label: 'Hàng ngày', value: 'daily' },
  { label: 'Ngày trong tuần (T2–T6)', value: 'weekdays' }, { label: 'Hàng tuần', value: 'weekly' },
]

const form = useForm({ title: '', description: '', category: 'housework', stars: 3, verification_mode: 'photo', recurrence: 'once', child_id: null, icon: '' })

// Template selection
const selectedCategory = ref('all')
const filteredTemplates = computed(() =>
  selectedCategory.value === 'all' ? props.templates : props.templates.filter(t => t.category === selectedCategory.value)
)
const applyTemplate = (tpl) => {
  form.title = tpl.title; form.category = tpl.category
  form.stars = tpl.stars; form.verification_mode = tpl.verification_mode
  form.recurrence = tpl.recurrence; form.icon = tpl.icon ?? ''
}

const submit = () => form.post(route('tasks.store'))
</script>

<template>
  <div class="max-w-4xl space-y-6">
    <div><h1 class="text-2xl font-extrabold text-gray-800">Tạo nhiệm vụ mới</h1></div>

    <div class="grid grid-cols-2 gap-6">
      <!-- Template library -->
      <div class="bg-white rounded-2xl p-6 shadow-sm border border-gray-100">
        <h2 class="font-extrabold text-gray-800 mb-4">📚 Thư viện mẫu</h2>
        <div class="flex gap-2 mb-4 flex-wrap">
          <button v-for="cat in [{ label: 'Tất cả', value: 'all' }, ...categories]" :key="cat.value"
            @click="selectedCategory = cat.value"
            :class="['text-xs font-semibold px-3 py-1.5 rounded-full transition-colors', selectedCategory === cat.value ? 'bg-primary text-white' : 'bg-gray-100 text-gray-600 hover:bg-gray-200']">
            {{ cat.label }}
          </button>
        </div>
        <div class="space-y-2 max-h-72 overflow-y-auto pr-1">
          <button v-for="tpl in filteredTemplates" :key="tpl.id" @click="applyTemplate(tpl)"
            class="w-full text-left p-3 rounded-xl hover:bg-primary-50 transition-colors border border-transparent hover:border-primary-100 group">
            <div class="flex items-center gap-3">
              <span class="text-xl">{{ tpl.icon }}</span>
              <div class="flex-1">
                <p class="font-semibold text-gray-700 text-sm group-hover:text-primary">{{ tpl.title }}</p>
                <p class="text-xs text-gray-400">{{ tpl.stars }}⭐ · {{ tpl.verification_mode }}</p>
              </div>
              <i class="pi pi-arrow-right text-gray-300 group-hover:text-primary text-xs"></i>
            </div>
          </button>
        </div>
      </div>

      <!-- Form -->
      <form @submit.prevent="submit" class="bg-white rounded-2xl p-6 shadow-sm border border-gray-100 space-y-4">
        <h2 class="font-extrabold text-gray-800 mb-4">✏️ Thông tin nhiệm vụ</h2>
        <FormField label="Tên nhiệm vụ" :error="form.errors.title" required>
          <InputText v-model="form.title" placeholder="Dọn phòng ngủ" class="w-full" :invalid="!!form.errors.title" />
        </FormField>
        <div class="grid grid-cols-2 gap-4">
          <FormField label="Danh mục" :error="form.errors.category">
            <Select v-model="form.category" :options="categories" optionLabel="label" optionValue="value" class="w-full" />
          </FormField>
          <FormField label="Số Sao thưởng" :error="form.errors.stars">
            <InputNumber v-model="form.stars" :min="1" :max="20" showButtons class="w-full" />
          </FormField>
        </div>
        <FormField label="Cách xác nhận" :error="form.errors.verification_mode">
          <Select v-model="form.verification_mode" :options="verificationModes" optionLabel="label" optionValue="value" class="w-full" />
        </FormField>
        <FormField label="Lặp lịch" :error="form.errors.recurrence">
          <Select v-model="form.recurrence" :options="recurrences" optionLabel="label" optionValue="value" class="w-full" />
        </FormField>
        <FormField label="Giao cho trẻ (để trống = tất cả)" :error="form.errors.child_id">
          <Select v-model="form.child_id" :options="children" optionLabel="name" optionValue="id" placeholder="Tất cả trẻ" showClear class="w-full" />
        </FormField>
        <div class="flex gap-3 pt-2">
          <Button type="button" label="Hủy" severity="secondary" class="flex-1" @click="$inertia.visit(route('tasks.index'))" />
          <Button type="submit" label="Tạo nhiệm vụ" class="flex-1" :loading="form.processing" />
        </div>
      </form>
    </div>
  </div>
</template>
```

- [ ] **Step 3: Thêm routes + commit**

```php
Route::resource('tasks', TaskController::class)->only(['index', 'create', 'store', 'destroy']);
```

```bash
git add resources/js/Pages/Tasks/ app/Http/Controllers/Web/TaskController.php routes/web.php
git commit -m "feat: add task management with template library picker"
```

---

## Task 6: Duyệt Nhiệm vụ (Pending Review)

**Files:**
- Create: `app/Http/Controllers/Web/PendingController.php`
- Create: `resources/js/Pages/Pending/Index.vue`
- Modify: `routes/web.php`

**Interfaces:**
- Produces: `/pending` — list task logs chờ duyệt, duyệt/từ chối + gửi sticker inline

- [ ] **Step 1: Tạo PendingController**

```php
// app/Http/Controllers/Web/PendingController.php
class PendingController extends Controller {
    public function index(Request $request) {
        $logs = TaskLog::whereHas('child', fn($q) => $q->where('family_id', $request->user()->family_id))
            ->where('status', TaskLogStatus::Submitted)
            ->with(['task', 'child'])
            ->latest('submitted_at')->get();
        return inertia('Pending/Index', ['logs' => $logs]);
    }

    public function approve(Request $request, TaskLog $log) {
        $request->validate(['sticker' => 'nullable|array', 'sticker.emoji' => 'required_with:sticker|string']);
        $log->update(['status' => TaskLogStatus::Approved, 'parent_sticker' => $request->sticker, 'reviewed_at' => now()]);
        app(StarService::class)->award($log->child, $log->task->stars);
        app(StreakService::class)->update($log->child);
        return back()->with('success', "Đã duyệt nhiệm vụ của {$log->child->name}! (+{$log->task->stars}⭐)");
    }

    public function reject(Request $request, TaskLog $log) {
        $request->validate(['reason' => 'nullable|string|max:255']);
        $log->update(['status' => TaskLogStatus::Rejected, 'rejection_reason' => $request->reason, 'reviewed_at' => now()]);
        return back()->with('success', "Đã từ chối nhiệm vụ.");
    }
}
```

- [ ] **Step 2: Tạo Pending/Index page**

```vue
<!-- resources/js/Pages/Pending/Index.vue -->
<script setup>
import { ref } from 'vue'
import { router } from '@inertiajs/vue3'
import AppLayout from '@/Layouts/AppLayout.vue'
import Button from 'primevue/button'
import Textarea from 'primevue/textarea'

defineOptions({ layout: AppLayout })
const props = defineProps({ logs: Array })

const stickers = ['🌟', '🎉', '👏', '💪', '🏆', '❤️', '🥰', '😍']
const approving = ref(null) // log id đang mở sticker picker
const selectedSticker = ref(null)
const rejectingId = ref(null)
const rejectReason = ref('')

const approve = (log) => {
  router.post(route('pending.approve', log.id), {
    sticker: selectedSticker.value ? { emoji: selectedSticker.value } : null
  }, { onSuccess: () => { approving.value = null; selectedSticker.value = null } })
}

const reject = (log) => {
  router.post(route('pending.reject', log.id), { reason: rejectReason.value },
    { onSuccess: () => { rejectingId.value = null; rejectReason.value = '' } })
}
</script>

<template>
  <div class="space-y-6">
    <div>
      <h1 class="text-2xl font-extrabold text-gray-800">Chờ duyệt</h1>
      <p class="text-sm text-gray-500 mt-1">{{ logs.length }} nhiệm vụ đang chờ xác nhận của bạn</p>
    </div>

    <div v-if="!logs.length" class="text-center py-20 bg-white rounded-2xl border border-gray-100">
      <div class="text-5xl mb-4">✅</div>
      <p class="font-bold text-gray-600">Không có gì cần duyệt</p>
      <p class="text-gray-400 text-sm mt-1">Tất cả nhiệm vụ đã được xử lý!</p>
    </div>

    <div class="space-y-4">
      <div v-for="log in logs" :key="log.id" class="bg-white rounded-2xl p-6 shadow-sm border border-gray-100">
        <div class="flex gap-5">
          <!-- Photo -->
          <div class="w-24 h-24 rounded-xl overflow-hidden bg-gray-100 flex-shrink-0">
            <img v-if="log.photo_path" :src="`/storage/${log.photo_path}`" class="w-full h-full object-cover" alt="Ảnh nhiệm vụ" />
            <div v-else class="w-full h-full flex items-center justify-center text-3xl">{{ log.task.icon }}</div>
          </div>

          <div class="flex-1">
            <div class="flex items-start justify-between">
              <div>
                <p class="font-extrabold text-gray-800 text-lg">{{ log.task.title }}</p>
                <p class="text-gray-400 text-sm">{{ log.child.name }} · Nộp lúc {{ new Date(log.submitted_at).toLocaleString('vi-VN') }}</p>
              </div>
              <span class="bg-amber-50 text-amber-600 text-sm font-bold px-3 py-1 rounded-full">+{{ log.task.stars }}⭐</span>
            </div>

            <!-- Sticker picker (khi duyệt) -->
            <div v-if="approving === log.id" class="mt-4 p-4 bg-gray-50 rounded-xl">
              <p class="text-sm font-semibold text-gray-600 mb-2">Gửi lời khen kèm (tùy chọn):</p>
              <div class="flex gap-2 flex-wrap mb-3">
                <button v-for="s in stickers" :key="s" @click="selectedSticker = selectedSticker === s ? null : s"
                  :class="['text-2xl p-2 rounded-xl transition-all', selectedSticker === s ? 'bg-primary-50 ring-2 ring-primary' : 'hover:bg-gray-100']">{{ s }}</button>
              </div>
              <div class="flex gap-2">
                <Button label="Hủy" severity="secondary" size="small" @click="approving = null" />
                <Button label="Xác nhận duyệt ✅" severity="success" size="small" @click="approve(log)" />
              </div>
            </div>

            <!-- Reject reason -->
            <div v-else-if="rejectingId === log.id" class="mt-4 p-4 bg-red-50 rounded-xl">
              <Textarea v-model="rejectReason" placeholder="Lý do từ chối (tùy chọn)..." rows="2" class="w-full mb-3" />
              <div class="flex gap-2">
                <Button label="Hủy" severity="secondary" size="small" @click="rejectingId = null" />
                <Button label="Từ chối ❌" severity="danger" size="small" @click="reject(log)" />
              </div>
            </div>

            <!-- Actions -->
            <div v-else class="flex gap-3 mt-4">
              <Button label="✅ Duyệt" severity="success" @click="approving = log.id" />
              <Button label="❌ Từ chối" severity="danger" outlined @click="rejectingId = log.id" />
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
```

- [ ] **Step 3: Thêm routes + commit**

```php
Route::get('/pending', [PendingController::class, 'index'])->name('pending.index');
Route::post('/pending/{log}/approve', [PendingController::class, 'approve'])->name('pending.approve');
Route::post('/pending/{log}/reject', [PendingController::class, 'reject'])->name('pending.reject');
```

```bash
git add resources/js/Pages/Pending/ app/Http/Controllers/Web/PendingController.php routes/web.php
git commit -m "feat: add pending review page with sticker picker and reject reason"
```

---

## Task 7: Quản lý Phần thưởng + App Blocking Config

**Files:**
- Create: `app/Http/Controllers/Web/RewardController.php`
- Create: `resources/js/Pages/Rewards/Index.vue`
- Modify: `routes/web.php`

**Interfaces:**
- Produces: `/rewards` — danh sách phần thưởng (screen time + thực tế), tạo/xóa

- [ ] **Step 1: Tạo RewardController (Web)**

```php
// app/Http/Controllers/Web/RewardController.php
class RewardController extends Controller {
    public function index(Request $request) {
        $rewards = Reward::where('family_id', $request->user()->family_id)->orderByDesc('created_at')->get();
        $children = Child::where('family_id', $request->user()->family_id)->get(['id', 'name']);
        $redemptions = RewardRedemption::whereHas('reward', fn($q) => $q->where('family_id', $request->user()->family_id))
            ->where('status', 'pending')->with(['reward', 'child'])->latest()->get();
        return inertia('Rewards/Index', compact('rewards', 'children', 'redemptions'));
    }

    public function store(Request $request) {
        $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
            'stars_required' => 'required|integer|min:1',
        ]);
        Reward::create([...$request->validated(), 'family_id' => $request->user()->family_id]);
        return back()->with('success', 'Đã tạo phần thưởng!');
    }

    public function destroy(Reward $reward) {
        $reward->delete();
        return back()->with('success', 'Đã xóa phần thưởng.');
    }

    public function fulfill(RewardRedemption $redemption) {
        $redemption->update(['status' => 'fulfilled']);
        return back()->with('success', 'Đã đánh dấu hoàn thành phần thưởng!');
    }
}
```

- [ ] **Step 2: Thêm routes + commit**

```php
Route::resource('rewards', RewardController::class)->only(['index', 'store', 'destroy']);
Route::post('/rewards/redemptions/{redemption}/fulfill', [RewardController::class, 'fulfill'])->name('rewards.fulfill');
```

```bash
git add resources/js/Pages/Rewards/ app/Http/Controllers/Web/RewardController.php routes/web.php
git commit -m "feat: add rewards management with redemption fulfillment"
```

---

## Task 8: Trang Báo cáo Analytics

**Files:**
- Create: `app/Http/Controllers/Web/AnalyticsController.php`
- Create: `resources/js/Pages/Analytics/Index.vue`
- Modify: `routes/web.php`

**Interfaces:**
- Produces: `/analytics` — biểu đồ tuần, phân bổ danh mục, so sánh tuần trước, per-child view

- [ ] **Step 1: Tạo AnalyticsController (Web)**

```php
// app/Http/Controllers/Web/AnalyticsController.php
class AnalyticsController extends Controller {
    public function index(Request $request) {
        $familyId = $request->user()->family_id;
        $children = Child::where('family_id', $familyId)->get();
        $childId = $request->get('child_id', $children->first()?->id);

        if (!$childId) return inertia('Analytics/Index', ['children' => $children, 'data' => null]);

        $child = Child::find($childId);
        $startOfWeek = now()->startOfWeek();
        $lastWeekStart = now()->subWeek()->startOfWeek();

        $thisWeekLogs = TaskLog::where('child_id', $childId)->where('status', TaskLogStatus::Approved)
            ->whereBetween('due_date', [$startOfWeek, now()])->with('task')->get();
        $lastWeekLogs = TaskLog::where('child_id', $childId)->where('status', TaskLogStatus::Approved)
            ->whereBetween('due_date', [$lastWeekStart, $startOfWeek->copy()->subDay()])->with('task')->get();

        $weekChartData = collect(range(0, 6))->map(function($i) use ($startOfWeek, $thisWeekLogs) {
            $date = $startOfWeek->copy()->addDays($i);
            $dayLogs = $thisWeekLogs->filter(fn($l) => $l->due_date->toDateString() === $date->toDateString());
            return ['label' => $date->locale('vi')->isoFormat('ddd D/M'), 'count' => $dayLogs->count(), 'stars' => $dayLogs->sum(fn($l) => $l->task->stars)];
        });

        $categoryData = $thisWeekLogs->groupBy(fn($l) => $l->task->category->label())->map->count();

        return inertia('Analytics/Index', [
            'children' => $children,
            'selectedChildId' => (int)$childId,
            'child' => $child,
            'data' => [
                'weekChart' => $weekChartData,
                'categoryChart' => $categoryData,
                'thisWeekCompleted' => $thisWeekLogs->count(),
                'lastWeekCompleted' => $lastWeekLogs->count(),
                'thisWeekStars' => $thisWeekLogs->sum(fn($l) => $l->task->stars),
                'lastWeekStars' => $lastWeekLogs->sum(fn($l) => $l->task->stars),
                'currentStreak' => $child->streak_days,
                'totalStars' => $child->total_stars,
                'rank' => $child->rank(),
            ],
        ]);
    }
}
```

- [ ] **Step 2: Thêm routes + commit**

```php
Route::get('/analytics', [AnalyticsController::class, 'index'])->name('analytics.index');
```

```bash
git add resources/js/Pages/Analytics/ app/Http/Controllers/Web/AnalyticsController.php routes/web.php
git commit -m "feat: add analytics page with weekly chart, category breakdown, and week-over-week comparison"
```

---

## Tóm tắt Web Routes

| Method | URL | Name | Controller |
|---|---|---|---|
| GET | `/login` | login | Auth@showLogin |
| POST | `/login` | — | Auth@login |
| GET | `/register` | register | Auth@showRegister |
| POST | `/register` | — | Auth@register |
| POST | `/logout` | logout | Auth@logout |
| GET | `/dashboard` | dashboard | Dashboard@index |
| GET | `/children` | children.index | Child@index |
| GET | `/children/create` | children.create | Child@create |
| POST | `/children` | children.store | Child@store |
| GET | `/children/{id}/edit` | children.edit | Child@edit |
| PUT | `/children/{id}` | children.update | Child@update |
| DELETE | `/children/{id}` | children.destroy | Child@destroy |
| GET | `/tasks` | tasks.index | Task@index |
| GET | `/tasks/create` | tasks.create | Task@create |
| POST | `/tasks` | tasks.store | Task@store |
| DELETE | `/tasks/{id}` | tasks.destroy | Task@destroy |
| GET | `/pending` | pending.index | Pending@index |
| POST | `/pending/{id}/approve` | pending.approve | Pending@approve |
| POST | `/pending/{id}/reject` | pending.reject | Pending@reject |
| GET | `/rewards` | rewards.index | Reward@index |
| POST | `/rewards` | rewards.store | Reward@store |
| DELETE | `/rewards/{id}` | rewards.destroy | Reward@destroy |
| GET | `/analytics` | analytics.index | Analytics@index |
