<script setup>
import { computed } from 'vue'
import { router } from '@inertiajs/vue3'
import AppLayout from '@/Layouts/AppLayout.vue'
import StatCard from '@/Components/StatCard.vue'
import Select from 'primevue/select'
import { Bar, Doughnut } from 'vue-chartjs'
import { Chart as ChartJS, CategoryScale, LinearScale, BarElement, ArcElement, Tooltip, Legend } from 'chart.js'

ChartJS.register(CategoryScale, LinearScale, BarElement, ArcElement, Tooltip, Legend)

defineOptions({ layout: AppLayout })

const props = defineProps({
  children: Array,
  selectedChildId: Number,
  child: Object,
  weekChart: Array,
  categoryChart: Object,
  stats: Object,
})

const onChildChange = (e) => {
  router.get('/analytics', { child_id: e.value }, { preserveState: true })
}

const barChartData = computed(() => ({
  labels: props.weekChart?.map(d => d.label) || [],
  datasets: [
    {
      label: 'Nhiệm vụ',
      data: props.weekChart?.map(d => d.count) || [],
      backgroundColor: '#6C63FF',
      borderRadius: 8,
    },
    {
      label: 'Sao kiếm',
      data: props.weekChart?.map(d => d.stars) || [],
      backgroundColor: '#48CAE4',
      borderRadius: 8,
    },
  ],
}))

const categoryChartData = computed(() => {
  const keys = Object.keys(props.categoryChart || {})
  const values = Object.values(props.categoryChart || {})

  return {
    labels: keys,
    datasets: [
      {
        data: values,
        backgroundColor: ['#6C63FF', '#48CAE4', '#FFB347', '#A8E6CF', '#FFD3E8'],
      },
    ],
  }
})
</script>

<template>
  <div class="space-y-6">
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-2xl font-extrabold text-gray-800 tracking-tight">Báo cáo & Phân tích Tuần</h1>
        <p class="text-sm text-gray-500 mt-1">Theo dõi tần suất hoàn thành nhiệm vụ và số Sao tích lũy của con</p>
      </div>

      <div v-if="children?.length" class="w-64">
        <Select :modelValue="selectedChildId" :options="children" optionLabel="name" optionValue="id" @change="onChildChange" class="w-full font-bold" />
      </div>
    </div>

    <div v-if="child" class="space-y-6">
      <!-- Top Stats -->
      <div class="grid grid-cols-4 gap-5">
        <StatCard label="Nhiệm vụ tuần này" :value="stats.tasksCompleted" icon="pi-check-square" color="primary" />
        <StatCard label="Sao thưởng tuần này" :value="`${stats.starsEarned} ⭐`" icon="pi-star" color="sky" />
        <StatCard label="Sao chưa dùng" :value="`${child.available_stars} ⭐`" icon="pi-wallet" color="amber" />
        <StatCard label="Chuỗi rèn luyện" :value="`🔥 ${child.streak_days} ngày`" icon="pi-bolt" color="green" />
      </div>

      <!-- Charts Row -->
      <div class="grid grid-cols-3 gap-6">
        <div class="col-span-2 bg-white rounded-3xl p-6 shadow-sm border border-gray-100">
          <h2 class="font-extrabold text-gray-800 text-lg mb-4">📊 Số bài làm & Sao theo ngày</h2>
          <div class="h-64">
            <Bar :data="barChartData" :options="{ responsive: true, maintainAspectRatio: false }" />
          </div>
        </div>

        <div class="bg-white rounded-3xl p-6 shadow-sm border border-gray-100">
          <h2 class="font-extrabold text-gray-800 text-lg mb-4">🍕 Phân bổ theo Danh mục</h2>
          <div class="h-64 flex items-center justify-center">
            <Doughnut v-if="Object.keys(categoryChart || {}).length" :data="categoryChartData" :options="{ responsive: true, maintainAspectRatio: false }" />
            <p v-else class="text-gray-400 text-sm font-semibold">Chưa có bài tập tuần này</p>
          </div>
        </div>
      </div>
    </div>

    <div v-else class="text-center py-20 bg-white rounded-3xl border border-gray-100 shadow-sm">
      <div class="text-5xl mb-3">📈</div>
      <p class="font-extrabold text-gray-700 text-lg">Chưa chọn hồ sơ trẻ</p>
      <p class="text-gray-400 text-sm mt-1">Vui lòng thêm bé vào gia đình để xem báo cáo chi tiết.</p>
    </div>
  </div>
</template>
