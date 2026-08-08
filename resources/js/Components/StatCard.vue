<script setup>
defineProps({
  label: String,
  value: [String, Number],
  icon: String,
  color: { type: String, default: 'primary' },
})

const colors = {
  primary: 'bg-primary-50 text-primary',
  sky: 'bg-sky-50 text-sky-500',
  green: 'bg-green-50 text-green-600',
  amber: 'bg-amber-50 text-amber-600',
}
</script>

<template>
  <div class="bg-white rounded-2xl p-6 shadow-sm border border-gray-100 flex items-center gap-5">
    <div :class="['w-12 h-12 rounded-xl flex items-center justify-center text-xl', colors[color] || colors.primary]">
      <i :class="`pi ${icon}`"></i>
    </div>
    <div>
      <p class="text-2xl font-extrabold text-gray-800">{{ value }}</p>
      <p class="text-sm text-gray-500 font-medium mt-0.5">{{ label }}</p>
    </div>
  </div>
</template>
