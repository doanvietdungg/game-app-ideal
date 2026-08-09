<script setup>
import { ref } from 'vue'
import Button from 'primevue/button'

const show = ref(false)
const resolveRef = ref(null)

const open = () => new Promise(r => {
  resolveRef.value = r
  show.value = true
})

const confirm = () => {
  if (resolveRef.value) resolveRef.value(true)
  show.value = false
}

const cancel = () => {
  if (resolveRef.value) resolveRef.value(false)
  show.value = false
}

defineExpose({ open })

defineProps({
  title: { type: String, default: 'Xác nhận xóa' },
  message: { type: String, default: 'Bạn có chắc chắn muốn xóa không? Hành động này không thể hoàn tác.' },
})
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
