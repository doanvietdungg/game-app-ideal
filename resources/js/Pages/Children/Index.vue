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

const deleteChild = async (child) => {
  const confirmed = await confirmRef.value.open()
  if (confirmed) {
    router.delete(`/children/${child.id}`)
  }
}
</script>

<template>
  <div class="space-y-6">
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-2xl font-extrabold text-gray-800 tracking-tight">Hồ sơ Trẻ em</h1>
        <p class="text-sm text-gray-500 mt-1">Quản lý các con trong gia đình (tối đa 5 trẻ)</p>
      </div>
      <Link href="/children/create">
        <Button label="Thêm con" icon="pi pi-plus" class="rounded-2xl font-bold" />
      </Link>
    </div>

    <div class="grid grid-cols-3 gap-6">
      <div v-for="child in children" :key="child.id" class="bg-white rounded-3xl p-6 shadow-sm border border-gray-100 flex flex-col justify-between">
        <div>
          <div class="flex items-start justify-between mb-4">
            <div class="w-16 h-16 rounded-2xl bg-primary-50 flex items-center justify-center text-4xl shadow-inner">
              {{ petEmoji[child.pet?.species] || '🐾' }}
            </div>
            <Button icon="pi pi-trash" severity="danger" size="small" text rounded @click="deleteChild(child)" />
          </div>

          <h3 class="font-extrabold text-gray-800 text-xl">{{ child.name }}</h3>
          <p class="text-gray-400 font-semibold text-sm mt-0.5">{{ child.age }} tuổi · Thú cưng: {{ child.pet?.species || 'Mèo' }} ({{ child.pet?.stage || 'baby' }})</p>
        </div>

        <div class="mt-6 grid grid-cols-3 gap-2 pt-4 border-t border-gray-100 text-center">
          <div class="bg-gray-50 rounded-2xl p-2.5">
            <p class="font-extrabold text-primary text-base">{{ child.available_stars }}</p>
            <p class="text-[11px] font-bold text-gray-400 uppercase">Sao khả dụng</p>
          </div>
          <div class="bg-gray-50 rounded-2xl p-2.5">
            <p class="font-extrabold text-gray-800 text-base">{{ child.total_stars }}</p>
            <p class="text-[11px] font-bold text-gray-400 uppercase">Tổng Sao</p>
          </div>
          <div class="bg-gray-50 rounded-2xl p-2.5">
            <p class="font-extrabold text-amber-500 text-base">🔥 {{ child.streak_days }}</p>
            <p class="text-[11px] font-bold text-gray-400 uppercase">Streak</p>
          </div>
        </div>
      </div>

      <div v-if="!children?.length" class="col-span-3 text-center py-16 bg-white rounded-3xl border border-gray-100">
        <div class="text-5xl mb-4">👶</div>
        <p class="font-bold text-gray-600">Chưa có trẻ nào trong gia đình</p>
        <p class="text-gray-400 text-sm mt-1 mb-6">Thêm con đầu tiên để bắt đầu tạo nhiệm vụ!</p>
        <Link href="/children/create">
          <Button label="Thêm bé ngay" icon="pi pi-plus" />
        </Link>
      </div>
    </div>

    <ConfirmDialog ref="confirmRef" message="Xóa hồ sơ trẻ sẽ xóa toàn bộ tiến trình nhiệm vụ và Sao của bé." />
  </div>
</template>
