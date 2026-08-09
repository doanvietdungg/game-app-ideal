<script setup>
import { ref } from 'vue'
import { router } from '@inertiajs/vue3'
import AppLayout from '@/Layouts/AppLayout.vue'
import Button from 'primevue/button'

defineOptions({ layout: AppLayout })

const props = defineProps({ logs: Array })

const stickers = ['🌟', '🎉', '👏', '💪', '🏆', '❤️', '🥰', '😍']
const approvingId = ref(null)
const selectedSticker = ref(null)
const rejectingId = ref(null)
const rejectReason = ref('')

const approve = (log) => {
  router.post(`/pending/${log.id}/approve`, {
    sticker: selectedSticker.value ? { emoji: selectedSticker.value, message: 'Giỏi lắm!' } : null,
  }, {
    onSuccess: () => {
      approvingId.value = null
      selectedSticker.value = null
    },
  })
}

const reject = (log) => {
  router.post(`/pending/${log.id}/reject`, {
    reason: rejectReason.value,
  }, {
    onSuccess: () => {
      rejectingId.value = null
      rejectReason.value = ''
    },
  })
}
</script>

<template>
  <div class="space-y-6">
    <div>
      <h1 class="text-2xl font-extrabold text-gray-800 tracking-tight">Duyệt Nhiệm vụ Chờ</h1>
      <p class="text-sm text-gray-500 mt-1">{{ logs?.length || 0 }} nhiệm vụ đang chờ bố mẹ xác nhận</p>
    </div>

    <div v-if="!logs?.length" class="text-center py-20 bg-white rounded-3xl border border-gray-100 shadow-sm">
      <div class="text-6xl mb-4">✅</div>
      <p class="font-extrabold text-gray-700 text-lg">Không có nhiệm vụ nào chờ duyệt!</p>
      <p class="text-gray-400 text-sm mt-1">Tất cả bài nộp của các con đã được xử lý xong.</p>
    </div>

    <div class="space-y-4">
      <div v-for="log in logs" :key="log.id" class="bg-white rounded-3xl p-6 shadow-sm border border-gray-100 flex gap-6 items-start">
        <!-- Photo Preview -->
        <div class="w-28 h-28 rounded-2xl bg-gray-100 flex-shrink-0 overflow-hidden border border-gray-200 flex items-center justify-center">
          <img v-if="log.photo_url" :src="log.photo_url" class="w-full h-full object-cover" alt="Ảnh bằng chứng" />
          <span v-else class="text-4xl">{{ log.task.icon || '📸' }}</span>
        </div>

        <div class="flex-1 min-w-0">
          <div class="flex items-start justify-between">
            <div>
              <h3 class="font-extrabold text-gray-800 text-lg">{{ log.task.title }}</h3>
              <p class="text-gray-400 font-semibold text-xs mt-0.5">Thực hiện bởi: <span class="text-gray-700 font-bold">{{ log.child.name }}</span> · Nộp lúc {{ log.submitted_at }}</p>
            </div>
            <span class="bg-amber-50 text-amber-600 font-extrabold text-sm px-3.5 py-1 rounded-full">+{{ log.task.stars }} ⭐</span>
          </div>

          <!-- Approve Sticker Picker -->
          <div v-if="approvingId === log.id" class="mt-4 p-4 bg-primary-50/50 rounded-2xl border border-primary-100">
            <p class="text-xs font-extrabold text-primary uppercase tracking-wider mb-2">Chọn Sticker khen ngợi tặng bé (Tùy chọn):</p>
            <div class="flex gap-2 flex-wrap mb-4">
              <button v-for="s in stickers" :key="s" type="button" @click="selectedSticker = selectedSticker === s ? null : s"
                :class="['text-3xl p-2 rounded-xl transition-transform hover:scale-110', selectedSticker === s ? 'bg-white ring-2 ring-primary shadow-sm' : 'hover:bg-white/50']">
                {{ s }}
              </button>
            </div>
            <div class="flex gap-2">
              <Button label="Hủy" severity="secondary" size="small" class="font-bold" @click="approvingId = null" />
              <Button label="Xác nhận Duyệt ✅" severity="success" size="small" class="font-bold" @click="approve(log)" />
            </div>
          </div>

          <!-- Reject Form -->
          <div v-else-if="rejectingId === log.id" class="mt-4 p-4 bg-red-50/50 rounded-2xl border border-red-100">
            <p class="text-xs font-extrabold text-red-500 uppercase tracking-wider mb-2">Lý do từ chối (Gửi cho bé xem):</p>
            <input v-model="rejectReason" type="text" placeholder="Ví dụ: Ảnh chụp chưa rõ phòng ngủ..." class="w-full text-sm rounded-xl border-gray-200 mb-3" />
            <div class="flex gap-2">
              <Button label="Hủy" severity="secondary" size="small" class="font-bold" @click="rejectingId = null" />
              <Button label="Từ chối ❌" severity="danger" size="small" class="font-bold" @click="reject(log)" />
            </div>
          </div>

          <!-- Default Actions -->
          <div v-else class="flex gap-3 mt-5">
            <Button label="✅ Duyệt nhiệm vụ" severity="success" class="font-bold rounded-xl" @click="approvingId = log.id" />
            <Button label="❌ Từ chối" severity="danger" outlined class="font-bold rounded-xl" @click="rejectingId = log.id" />
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
