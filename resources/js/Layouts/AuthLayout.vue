<script setup>
defineProps({
  maxWidth: {
    type: String,
    default: 'md',
  },
})
</script>

<template>
  <div class="min-h-screen bg-gradient-to-br from-primary-50 via-white to-sky-50 flex items-center justify-center p-4">
    <div :class="['w-full', maxWidth === 'lg' ? 'max-w-lg' : maxWidth === 'xl' ? 'max-w-xl' : 'max-w-md']">
      <div class="text-center mb-8">
        <div class="w-16 h-16 rounded-2xl bg-primary mx-auto flex items-center justify-center text-white font-extrabold text-3xl shadow-lg shadow-primary/25 mb-4">K</div>
        <h1 class="text-2xl font-extrabold text-gray-800">KidTime</h1>
        <p class="text-gray-500 text-sm mt-1">Quản lý thời gian màn hình & thói quen cho trẻ</p>
      </div>
      <div class="bg-white rounded-2xl shadow-xl shadow-gray-100/50 p-8 border border-gray-100">
        <slot />
      </div>
    </div>
  </div>
</template>

