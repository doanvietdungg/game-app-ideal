<script setup>
import { useForm, Link } from '@inertiajs/vue3'
import AppLayout from '@/Layouts/AppLayout.vue'
import FormField from '@/Components/FormField.vue'
import InputText from 'primevue/inputtext'
import InputNumber from 'primevue/inputnumber'
import Button from 'primevue/button'

defineOptions({ layout: AppLayout })

const form = useForm({
  name: '',
  age: 7,
  pet_species: 'cat',
})

const pets = [
  { species: 'cat', emoji: '🐱', name: 'Mèo con' },
  { species: 'bunny', emoji: '🐰', name: 'Thỏ ngọc' },
  { species: 'bear', emoji: '🐻', name: 'Gấu nâu' },
  { species: 'dinosaur', emoji: '🦕', name: 'Khủng long' },
  { species: 'penguin', emoji: '🐧', name: 'Chim cánh cụt' },
  { species: 'dragon', emoji: '🐲', name: 'Rồng nhỏ' },
]

const submit = () => {
  form.post('/children')
}
</script>

<template>
  <div class="max-w-2xl mx-auto space-y-6">
    <div>
      <h1 class="text-2xl font-extrabold text-gray-800 tracking-tight">Thêm Trẻ em Mới</h1>
      <p class="text-sm text-gray-500 mt-1">Tạo hồ sơ và chọn Thú cưng đồng hành cho bé</p>
    </div>

    <form @submit.prevent="submit" class="bg-white rounded-3xl p-8 shadow-sm border border-gray-100 space-y-6">
      <div class="grid grid-cols-2 gap-4">
        <FormField label="Tên gọi của bé" :error="form.errors.name" required>
          <InputText v-model="form.name" placeholder="Ví dụ: Bé Nam" class="w-full" :invalid="!!form.errors.name" />
        </FormField>
        <FormField label="Tuổi của bé" :error="form.errors.age" required>
          <InputNumber v-model="form.age" :min="3" :max="18" showButtons class="w-full" />
        </FormField>
      </div>

      <!-- Select Pet Species -->
      <FormField label="Chọn Thú cưng cho bé" :error="form.errors.pet_species" required>
        <div class="grid grid-cols-3 gap-3 mt-2">
          <button v-for="pet in pets" :key="pet.species" type="button" @click="form.pet_species = pet.species"
            :class="['p-4 rounded-2xl border text-center transition-all flex flex-col items-center gap-2',
              form.pet_species === pet.species ? 'border-primary bg-primary-50 ring-2 ring-primary' : 'border-gray-100 hover:border-gray-200 bg-gray-50']">
            <span class="text-4xl">{{ pet.emoji }}</span>
            <span class="font-extrabold text-sm text-gray-800">{{ pet.name }}</span>
          </button>
        </div>
      </FormField>

      <div class="flex gap-3 pt-4 border-t border-gray-100">
        <Link href="/children" class="flex-1">
          <Button type="button" label="Hủy" severity="secondary" class="w-full font-bold" />
        </Link>
        <Button type="submit" label="Tạo hồ sơ" class="flex-1 font-bold" :loading="form.processing" />
      </div>
    </form>
  </div>
</template>
