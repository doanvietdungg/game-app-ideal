<script setup>
import { ref, computed } from 'vue'
import { useForm, Link } from '@inertiajs/vue3'
import AppLayout from '@/Layouts/AppLayout.vue'
import FormField from '@/Components/FormField.vue'
import InputText from 'primevue/inputtext'
import Select from 'primevue/select'
import InputNumber from 'primevue/inputnumber'
import Button from 'primevue/button'

defineOptions({ layout: AppLayout })

const props = defineProps({
  children: Array,
  templates: Array,
})

const categories = [
  { label: '🏠 Việc nhà', value: 'housework' },
  { label: '📚 Học tập', value: 'study' },
  { label: '🏃 Vận động', value: 'exercise' },
  { label: '🥦 Ăn uống', value: 'eating' },
  { label: '😴 Giấc ngủ', value: 'sleep' },
]

const modes = [
  { label: '📸 Ảnh chứng minh', value: 'photo' },
  { label: '🔑 PIN bố mẹ', value: 'pin' },
  { label: '✅ Tự động', value: 'auto' },
]

const recurrences = [
  { label: 'Một lần', value: 'once' },
  { label: 'Hàng ngày', value: 'daily' },
  { label: 'T2 – T6 (Học tập)', value: 'weekdays' },
  { label: 'Hàng tuần', value: 'weekly' },
]

const form = useForm({
  title: '',
  description: '',
  icon: '📌',
  category: 'housework',
  stars: 3,
  verification_mode: 'photo',
  recurrence: 'once',
  child_id: null,
})

const selectedCatFilter = ref('all')
const filteredTemplates = computed(() =>
  selectedCatFilter.value === 'all'
    ? props.templates
    : props.templates.filter(t => t.category === selectedCatFilter.value)
)

const applyTemplate = (tpl) => {
  form.title = tpl.title
  form.category = tpl.category
  form.stars = tpl.stars
  form.verification_mode = tpl.verification_mode
  form.recurrence = tpl.recurrence
  form.icon = tpl.icon || '📌'
}

const submit = () => {
  form.post('/tasks')
}
</script>

<template>
  <div class="max-w-5xl space-y-6">
    <div>
      <h1 class="text-2xl font-extrabold text-gray-800 tracking-tight">Tạo Nhiệm vụ Mới</h1>
      <p class="text-sm text-gray-500 mt-1">Chọn từ Thư viện mẫu hoặc tự thiết lập nhiệm vụ cho con</p>
    </div>

    <div class="grid grid-cols-5 gap-6 items-start">
      <!-- Template Library Sidebar -->
      <div class="col-span-2 bg-white rounded-3xl p-6 shadow-sm border border-gray-100 space-y-4">
        <h2 class="font-extrabold text-gray-800 text-base">📚 Thư viện mẫu</h2>

        <div class="flex gap-1.5 flex-wrap">
          <button v-for="cat in [{ label: 'Tất cả', value: 'all' }, ...categories]" :key="cat.value"
            type="button" @click="selectedCatFilter = cat.value"
            :class="['text-xs font-extrabold px-3 py-1.5 rounded-full transition-colors',
              selectedCatFilter === cat.value ? 'bg-primary text-white' : 'bg-gray-100 text-gray-600 hover:bg-gray-200']">
            {{ cat.label }}
          </button>
        </div>

        <div class="space-y-2 max-h-[380px] overflow-y-auto pr-1">
          <button v-for="tpl in filteredTemplates" :key="tpl.id" type="button" @click="applyTemplate(tpl)"
            class="w-full text-left p-3 rounded-2xl hover:bg-primary-50 transition-all border border-transparent hover:border-primary-100 group flex items-center gap-3">
            <span class="text-2xl">{{ tpl.icon }}</span>
            <div class="flex-1 min-w-0">
              <p class="font-extrabold text-gray-800 text-sm group-hover:text-primary truncate">{{ tpl.title }}</p>
              <p class="text-[11px] font-semibold text-gray-400">+{{ tpl.stars }} ⭐ · {{ tpl.verification_mode }}</p>
            </div>
            <i class="pi pi-plus text-gray-300 group-hover:text-primary text-xs"></i>
          </button>
        </div>
      </div>

      <!-- Custom Form -->
      <form @submit.prevent="submit" class="col-span-3 bg-white rounded-3xl p-6 shadow-sm border border-gray-100 space-y-4">
        <h2 class="font-extrabold text-gray-800 text-base mb-2">✏️ Chi tiết nhiệm vụ</h2>

        <FormField label="Tên nhiệm vụ" :error="form.errors.title" required>
          <InputText v-model="form.title" placeholder="Ví dụ: Dọn dẹp phòng ngủ" class="w-full" :invalid="!!form.errors.title" />
        </FormField>

        <div class="grid grid-cols-2 gap-4">
          <FormField label="Danh mục" :error="form.errors.category" required>
            <Select v-model="form.category" :options="categories" optionLabel="label" optionValue="value" class="w-full" />
          </FormField>
          <FormField label="Số Sao thưởng" :error="form.errors.stars" required>
            <InputNumber v-model="form.stars" :min="1" :max="20" showButtons class="w-full" />
          </FormField>
        </div>

        <FormField label="Chế độ xác nhận" :error="form.errors.verification_mode" required>
          <Select v-model="form.verification_mode" :options="modes" optionLabel="label" optionValue="value" class="w-full" />
        </FormField>

        <FormField label="Lặp lịch" :error="form.errors.recurrence" required>
          <Select v-model="form.recurrence" :options="recurrences" optionLabel="label" optionValue="value" class="w-full" />
        </FormField>

        <FormField label="Giao cho trẻ (Để trống = Áp dụng tất cả con)" :error="form.errors.child_id">
          <Select v-model="form.child_id" :options="children" optionLabel="name" optionValue="id" placeholder="Tất cả các con" showClear class="w-full" />
        </FormField>

        <div class="flex gap-3 pt-4 border-t border-gray-100">
          <Link href="/tasks" class="flex-1">
            <Button type="button" label="Hủy" severity="secondary" class="w-full font-bold" />
          </Link>
          <Button type="submit" label="Tạo nhiệm vụ" class="flex-1 font-bold" :loading="form.processing" />
        </div>
      </form>
    </div>
  </div>
</template>
