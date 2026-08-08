<script setup>
import { ref } from 'vue'
import { useForm, router } from '@inertiajs/vue3'
import AppLayout from '@/Layouts/AppLayout.vue'
import FormField from '@/Components/FormField.vue'
import ConfirmDialog from '@/Components/ConfirmDialog.vue'
import InputText from 'primevue/inputtext'
import InputNumber from 'primevue/inputnumber'
import Button from 'primevue/button'

defineOptions({ layout: AppLayout })

const props = defineProps({ rewards: Array })
const confirmRef = ref(null)

const form = useForm({
  title: '',
  description: '',
  stars_required: 5,
})

const submit = () => {
  form.post('/rewards', {
    onSuccess: () => form.reset(),
  })
}

const deleteReward = async (reward) => {
  const confirmed = await confirmRef.value.open()
  if (confirmed) {
    router.delete(`/rewards/${reward.id}`)
  }
}
</script>

<template>
  <div class="space-y-6 max-w-5xl">
    <div>
      <h1 class="text-2xl font-extrabold text-gray-800 tracking-tight">Quản lý Phần thưởng</h1>
      <p class="text-sm text-gray-500 mt-1">Cài đặt gói Thời gian màn hình & Phần thưởng thực tế cho con</p>
    </div>

    <div class="grid grid-cols-3 gap-6 items-start">
      <!-- Create Reward Form -->
      <form @submit.prevent="submit" class="bg-white rounded-3xl p-6 shadow-sm border border-gray-100 space-y-4">
        <h2 class="font-extrabold text-gray-800 text-lg mb-2">🎁 Tạo phần thưởng mới</h2>

        <FormField label="Tên phần thưởng" :error="form.errors.title" required>
          <InputText v-model="form.title" placeholder="Ví dụ: Xem YouTube 30 phút" class="w-full" :invalid="!!form.errors.title" />
        </FormField>

        <FormField label="Số Sao cần đổi" :error="form.errors.stars_required" required>
          <InputNumber v-model="form.stars_required" :min="1" :max="9999" showButtons class="w-full" />
        </FormField>

        <FormField label="Mô tả chi tiết" :error="form.errors.description">
          <InputText v-model="form.description" placeholder="Áp dụng sau khi làm xong bài tập" class="w-full" />
        </FormField>

        <Button type="submit" label="Tạo phần thưởng" class="w-full font-bold mt-2" :loading="form.processing" />
      </form>

      <!-- Rewards List -->
      <div class="col-span-2 space-y-3">
        <div v-for="reward in rewards" :key="reward.id" class="bg-white rounded-3xl p-5 shadow-sm border border-gray-100 flex items-center justify-between">
          <div class="flex items-center gap-4">
            <div class="w-12 h-12 rounded-2xl bg-amber-50 text-amber-500 flex items-center justify-center text-2xl font-bold">
              🎁
            </div>
            <div>
              <h3 class="font-extrabold text-gray-800 text-base">{{ reward.title }}</h3>
              <p class="text-xs text-gray-400 font-semibold mt-0.5">{{ reward.description || 'Phần thưởng do bố mẹ tạo' }}</p>
            </div>
          </div>

          <div class="flex items-center gap-3">
            <span class="bg-primary-50 text-primary font-extrabold text-sm px-4 py-1.5 rounded-full">{{ reward.stars_required }} ⭐</span>
            <Button icon="pi pi-trash" severity="danger" size="small" text rounded @click="deleteReward(reward)" />
          </div>
        </div>

        <div v-if="!rewards?.length" class="text-center py-16 bg-white rounded-3xl border border-gray-100">
          <div class="text-4xl mb-3">🎁</div>
          <p class="font-bold text-gray-600">Chưa có phần thưởng nào</p>
          <p class="text-gray-400 text-sm mt-1">Tạo phần thưởng đầu tiên để khuyến khích trẻ tích lũy Sao!</p>
        </div>
      </div>
    </div>

    <ConfirmDialog ref="confirmRef" message="Bạn có chắc chắn muốn xóa phần thưởng này không?" />
  </div>
</template>
