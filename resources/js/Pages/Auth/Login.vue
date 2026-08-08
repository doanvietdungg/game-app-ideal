<script setup>
import { useForm, Link } from '@inertiajs/vue3'
import AuthLayout from '@/Layouts/AuthLayout.vue'
import FormField from '@/Components/FormField.vue'
import InputText from 'primevue/inputtext'
import Password from 'primevue/password'
import Button from 'primevue/button'

defineOptions({ layout: AuthLayout })

const form = useForm({
  email: '',
  password: '',
  remember: false,
})

const submit = () => {
  form.post('/login', {
    onError: () => form.reset('password'),
  })
}
</script>

<template>
  <div>
    <h2 class="text-xl font-extrabold text-gray-800 mb-6">Đăng nhập Bố mẹ</h2>
    <form @submit.prevent="submit" class="space-y-5">
      <FormField label="Email" :error="form.errors.email" required>
        <InputText v-model="form.email" type="email" placeholder="email@example.com" class="w-full" :invalid="!!form.errors.email" autocomplete="email" />
      </FormField>

      <FormField label="Mật khẩu" :error="form.errors.password" required>
        <Password v-model="form.password" placeholder="••••••••" class="w-full" :invalid="!!form.errors.password" :feedback="false" toggleMask />
      </FormField>

      <Button type="submit" label="Đăng nhập" class="w-full" :loading="form.processing" />
    </form>

    <p class="text-center text-sm text-gray-500 mt-6">
      Chưa có tài khoản gia đình?
      <Link href="/register" class="text-primary font-bold hover:underline">Đăng ký ngay</Link>
    </p>
  </div>
</template>
