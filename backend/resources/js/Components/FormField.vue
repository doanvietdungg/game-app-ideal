<script setup>
defineProps({
  label: String,
  error: String,
  required: Boolean,
})
</script>

<template>
  <div class="space-y-1.5">
    <label v-if="label" class="block text-sm font-semibold text-gray-700">
      {{ label }} <span v-if="required" class="text-red-500">*</span>
    </label>
    <slot />
    <p v-if="error" class="text-xs text-red-500 flex items-center gap-1 mt-1">
      <i class="pi pi-exclamation-circle text-xs"></i> {{ error }}
    </p>
  </div>
</template>
