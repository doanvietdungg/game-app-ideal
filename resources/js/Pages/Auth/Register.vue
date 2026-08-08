<script setup>
import { useForm, Link } from '@inertiajs/vue3'
import AuthLayout from '@/Layouts/AuthLayout.vue'
import FormField from '@/Components/FormField.vue'
import InputText from 'primevue/inputtext'
import Password from 'primevue/password'
import Button from 'primevue/button'

defineOptions({ layout: AuthLayout })

const form = useForm({
  name: '',
  email: '',
  password: '',
  password_confirmation: '',
  family_name: '',
  family_pin: '',
})

const submit = () => {
  form.post('/register')
}
</script>

<template>
  <div>
    <h2 class="text-xl font-extrabold text-gray-800 mb-6">Đăng ký Tài khoản Gia đình</h2>
    <form @submit.prevent="submit" class="space-y-4">
      <div class="grid grid-cols-2 gap-4">
        <FormField label="Họ và tên" :error="form.errors.name" required>
          <InputText v-model="form.name" placeholder="Nguyễn Văn A" class="w-full" :invalid="!!form.errors.name" />
        </FormField>
        <FormField label="Email" :error="form.errors.email" required>
          <InputText v-model="form.email" type="email" placeholder="email@example.com" class="w-full" :invalid="!!form.errors.email" />
        </FormField>
      </div>

      <div class="grid grid-cols-2 gap-4">
        <FormField label="Mật khẩu" :error="form.errors.password" required>
          <Password v-model="form.password" class="w-full" :invalid="!!form.errors.password" toggleMask />
        </FormField>
        <FormField label="Xác nhận mật khẩu" :error="form.errors.password_confirmation">
          <Password v-model="form.password_confirmation" class="w-full" :feedback="false" toggleMask />
        </FormField>
      </div>

      <div class="border-t border-gray-100 pt-4 mt-2">
        <p class="text-xs font-bold text-gray-400 uppercase tracking-wider mb-3">Thông tin Gia đình</p>
        <div class="grid grid-cols-2 gap-4">
          <FormField label="Tên gia đình" :error="form.errors.family_name" required>
            <InputText v-model="form.family_name" placeholder="Gia đình Nguyễn" class="w-full" :invalid="!!form.errors.family_name" />
          </FormField>
          <FormField label="PIN trẻ nhập (4 số)" :error="form.errors.family_pin" required>
            <InputText v-model="form.family_pin" placeholder="1234" maxlength="4" class="w-full" :invalid="!!form.errors.family_pin" />
          </FormField>
        </div>
      </div>

      <Button type="submit" label="Tạo tài khoản" class="w-full mt-2" :loading="form.processing" />
    </form>

    <p class="text-center text-sm text-gray-500 mt-6">
      Đã có tài khoản?
      <Link href="/login" class="text-primary font-bold hover:underline">Đăng nhập</Link>
    </p>
  </div>
</template>
