<script setup>
import { ref } from 'vue'
import { Link, router } from '@inertiajs/vue3'
import AppLayout from '@/Layouts/AppLayout.vue'
import ConfirmDialog from '@/Components/ConfirmDialog.vue'
import Button from 'primevue/button'

defineOptions({ layout: AppLayout })

const props = defineProps({
  tasks: Array,
  children: Array,
})

const confirmRef = ref(null)

const categoryLabels = {
  housework: '🏠 Việc nhà',
  study: '📚 Học tập',
  exercise: '🏃 Vận động',
  eating: '🥦 Ăn uống',
  sleep: '😴 Giấc ngủ',
}

const modeLabels = {
  photo: '📸 Ảnh chứng minh',
  pin: '🔑 PIN bố mẹ',
  auto: '✅ Tự động',
}

const deleteTask = async (task) => {
  const confirmed = await confirmRef.value.open()
  if (confirmed) {
    router.delete(`/tasks/${task.id}`)
  }
}
</script>

<template>
  <div class="space-y-6">
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-2xl font-extrabold text-gray-800 tracking-tight">Danh sách Nhiệm vụ</h1>
        <p class="text-sm text-gray-500 mt-1">Quản lý nhiệm vụ giao cho các con trong gia đình</p>
      </div>
      <Link href="/tasks/create">
        <Button label="Tạo nhiệm vụ" icon="pi pi-plus" class="rounded-2xl font-bold" />
      </Link>
    </div>

    <div class="grid grid-cols-3 gap-5">
      <div v-for="task in tasks" :key="task.id" class="bg-white rounded-3xl p-6 shadow-sm border border-gray-100 flex flex-col justify-between">
        <div>
          <div class="flex items-start justify-between mb-3">
            <span class="text-3xl">{{ task.icon || '📌' }}</span>
            <div class="flex items-center gap-2">
              <span class="bg-amber-50 text-amber-600 font-extrabold text-xs px-3 py-1 rounded-full">+{{ task.stars }} ⭐</span>
              <Button icon="pi pi-trash" severity="danger" size="small" text rounded @click="deleteTask(task)" />
            </div>
          </div>

          <h3 class="font-extrabold text-gray-800 text-lg">{{ task.title }}</h3>
          <p v-if="task.description" class="text-gray-500 text-sm mt-1 line-clamp-2">{{ task.description }}</p>
        </div>

        <div class="mt-4 pt-4 border-t border-gray-100 flex items-center justify-between text-xs font-semibold text-gray-400">
          <span>{{ categoryLabels[task.category] || task.category }}</span>
          <span>{{ modeLabels[task.verification_mode] || task.verification_mode }}</span>
        </div>
      </div>

      <div v-if="!tasks?.length" class="col-span-3 text-center py-16 bg-white rounded-3xl border border-gray-100">
        <div class="text-5xl mb-4">📝</div>
        <p class="font-bold text-gray-600">Chưa có nhiệm vụ nào được tạo</p>
        <p class="text-gray-400 text-sm mt-1 mb-6">Chọn nhiệm vụ từ thư viện mẫu hoặc tự thiết lập!</p>
        <Link href="/tasks/create">
          <Button label="Tạo nhiệm vụ ngay" icon="pi pi-plus" />
        </Link>
      </div>
    </div>

    <ConfirmDialog ref="confirmRef" message="Bạn có chắc chắn muốn xóa nhiệm vụ này không?" />
  </div>
</template>
