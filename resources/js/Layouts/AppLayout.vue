<script setup>
import { Link, usePage } from '@inertiajs/vue3'
import { computed } from 'vue'

const page = usePage()
const user = computed(() => page.props.auth?.user)
const pendingCount = computed(() => page.props.pendingCount || 0)
const flash = computed(() => page.props.flash)
</script>

<template>
  <div class="min-h-screen flex bg-[#F8F9FF]">
    <!-- Sidebar -->
    <aside class="w-64 bg-white border-r border-gray-100 flex flex-col shadow-sm fixed inset-y-0 z-30">
      <!-- Logo -->
      <div class="p-5 border-b border-gray-100">
        <div class="flex items-center gap-3">
          <img src="/images/admin-logo.png" alt="KidTime Admin Logo" class="w-12 h-12 rounded-full shadow-md object-cover bg-white" />
          <div>
            <span class="font-extrabold text-xl text-gray-800 tracking-tight">KidTime</span>
            <p class="text-[10px] uppercase font-extrabold text-primary tracking-wider">Parent Hub</p>
          </div>
        </div>
      </div>




      <!-- Navigation Links -->
      <nav class="flex-1 p-4 space-y-1.5 overflow-y-auto">
        <Link href="/dashboard" class="nav-item" :class="{ active: $page.component === 'Dashboard' }">
          <i class="pi pi-home text-base"></i> Dashboard
        </Link>
        <Link href="/children" class="nav-item" :class="{ active: $page.component.startsWith('Children') }">
          <i class="pi pi-users text-base"></i> Trẻ em
        </Link>
        <Link href="/tasks" class="nav-item" :class="{ active: $page.component.startsWith('Tasks') }">
          <i class="pi pi-check-square text-base"></i> Nhiệm vụ
        </Link>
        <Link href="/pending" class="nav-item relative" :class="{ active: $page.component.startsWith('Pending') }">
          <i class="pi pi-bell text-base"></i> Chờ duyệt
          <span v-if="pendingCount > 0" class="absolute right-3 bg-red-500 text-white text-[10px] font-extrabold px-2 py-0.5 rounded-full">
            {{ pendingCount }}
          </span>
        </Link>
        <Link href="/rewards" class="nav-item" :class="{ active: $page.component.startsWith('Rewards') }">
          <i class="pi pi-gift text-base"></i> Phần thưởng
        </Link>
        <Link href="/analytics" class="nav-item" :class="{ active: $page.component.startsWith('Analytics') }">
          <i class="pi pi-chart-bar text-base"></i> Báo cáo
        </Link>
      </nav>

      <!-- User Info & Logout -->
      <div class="p-4 border-t border-gray-100">
        <div class="flex items-center gap-3 p-3 rounded-2xl bg-gray-50 border border-gray-100">
          <div class="w-9 h-9 rounded-xl bg-primary-100 text-primary flex items-center justify-center font-bold text-sm">
            {{ user?.name ? user.name[0].toUpperCase() : 'P' }}
          </div>
          <div class="flex-1 min-w-0">
            <p class="text-sm font-extrabold text-gray-800 truncate">{{ user?.name || 'Bố mẹ' }}</p>
            <p class="text-xs text-gray-400 truncate">{{ user?.email }}</p>
          </div>
          <Link href="/logout" method="post" as="button" class="text-gray-400 hover:text-red-500 transition-colors p-1">
            <i class="pi pi-sign-out text-sm"></i>
          </Link>
        </div>
      </div>
    </aside>

    <!-- Main Content Area -->
    <main class="flex-1 pl-64 overflow-auto min-h-screen">
      <!-- Flash Alert -->
      <div v-if="flash?.success" class="bg-green-500 text-white text-sm font-semibold px-6 py-3 flex items-center justify-between shadow-md">
        <span>✅ {{ flash.success }}</span>
      </div>
      <div v-if="flash?.error" class="bg-red-500 text-white text-sm font-semibold px-6 py-3 flex items-center justify-between shadow-md">
        <span>⚠️ {{ flash.error }}</span>
      </div>

      <div class="p-8 max-w-7xl mx-auto">
        <slot />
      </div>
    </main>
  </div>
</template>

<style scoped>
.nav-item {
  @apply flex items-center gap-3 px-4 py-3 rounded-2xl text-gray-600 font-semibold text-sm transition-all duration-150 hover:bg-primary-50 hover:text-primary;
}
.nav-item.active {
  @apply bg-primary text-white font-extrabold shadow-md shadow-primary/20;
}
</style>
