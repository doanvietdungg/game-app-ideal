<script setup>
import { computed } from 'vue'
import { Link } from '@inertiajs/vue3'
import AppLayout from '@/Layouts/AppLayout.vue'
import StatCard from '@/Components/StatCard.vue'
import { Bar } from 'vue-chartjs'
import { Chart as ChartJS, CategoryScale, LinearScale, BarElement, Tooltip } from 'chart.js'

ChartJS.register(CategoryScale, LinearScale, BarElement, Tooltip)

defineOptions({ layout: AppLayout })

const props = defineProps({
  children: Array,
  stats: Object,
  weekData: Array,
})

const chartData = computed(() => ({
  labels: props.weekData?.map(d => d.label) || [],
  datasets: [
    {
      data: props.weekData?.map(d => d.count) || [],
      backgroundColor: '#6C63FF',
      borderRadius: 8,
    },
  ],
}))

const chartOptions = {
  responsive: true,
  maintainAspectRatio: false,
  plugins: { legend: { display: false } },
  scales: {
    y: { beginAtZero: true, ticks: { stepSize: 1 }, grid: { color: '#f3f4f6' } },
    x: { grid: { display: false } },
  },
}

const petEmoji = { cat: '🐱', bunny: '🐰', bear: '🐻', dinosaur: '🦕', penguin: '🐧', dragon: '🐲' }
</script>

<template>
  <div class="space-y-8">
    <div>
      <h1 class="text-2xl font-extrabold text-gray-800 tracking-tight">Dashboard Bố mẹ</h1>
      <p class="text-gray-500 text-sm mt-1">Tổng quan hoạt động và tiến trình nhiệm vụ của các con hôm nay</p>
    </div>

    <!-- Stats Row -->
    <div class="grid grid-cols-4 gap-5">
      <StatCard label="Tổng số Trẻ em" :value="stats.totalChildren" icon="pi-users" color="primary" />
      <StatCard label="Nhiệm vụ Chờ duyệt" :value="stats.pendingReview" icon="pi-bell" color="amber" />
      <StatCard label="Hoàn thành hôm nay" :value="stats.completedToday" icon="pi-check-circle" color="green" />
      <StatCard label="Sao thưởng hôm nay" :value="`${stats.totalStarsToday} ⭐`" icon="pi-star" color="sky" />
    </div>

    <div class="grid grid-cols-3 gap-6">
      <!-- Activity Bar Chart -->
      <div class="col-span-2 bg-white rounded-3xl p-6 shadow-sm border border-gray-100">
        <h2 class="font-extrabold text-gray-800 text-lg mb-4">📊 Nhiệm vụ hoàn thành 7 ngày qua</h2>
        <div class="h-56">
          <Bar :data="chartData" :options="chartOptions" />
        </div>
      </div>

      <!-- Quick Children List -->
      <div class="bg-white rounded-3xl p-6 shadow-sm border border-gray-100">
        <div class="flex items-center justify-between mb-4">
          <h2 class="font-extrabold text-gray-800 text-lg">👶 Danh sách các con</h2>
          <Link href="/children" class="text-xs text-primary font-bold hover:underline">Quản lý</Link>
        </div>

        <div class="space-y-3">
          <div v-for="child in children" :key="child.id" class="flex items-center gap-3 p-3 rounded-2xl bg-gray-50 border border-gray-100">
            <div class="w-11 h-11 rounded-2xl bg-primary-50 flex items-center justify-center text-2xl">
              {{ petEmoji[child.pet?.species] || '🐾' }}
            </div>
            <div class="flex-1 min-w-0">
              <p class="font-extrabold text-gray-800 text-sm truncate">{{ child.name }}</p>
              <p class="text-xs text-gray-400 font-semibold">{{ child.available_stars }} ⭐ khả dụng · Cấp {{ child.pet?.stage || 'baby' }}</p>
            </div>
            <span class="text-sm font-extrabold">🔥 {{ child.streak_days }}</span>
          </div>

          <div v-if="!children?.length" class="text-center py-6 text-gray-400 text-sm">
            Chưa có hồ sơ trẻ nào.
            <Link href="/children/create" class="text-primary font-bold block mt-1">Thêm con đầu tiên</Link>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
