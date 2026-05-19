<template>
  <div class="login-page">
    <div class="login-card">
      <div class="login-brand">
        <svg width="40" height="40" viewBox="0 0 32 32" fill="none">
          <rect width="32" height="32" rx="8" fill="#7c3aed"/>
          <path d="M8 22V12l6 8 4-4 6 6" stroke="#fff" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" fill="none"/>
        </svg>
        <h1>CPMS 业主服务</h1>
        <p>欢迎回来，请登录您的账户</p>
      </div>
      <a-form
        :model="form"
        layout="vertical"
        @finish="handleLogin"
        class="login-form"
      >
        <a-form-item name="username" :rules="[{ required: true, message: '请输入用户名' }]">
          <a-input
            v-model:value="form.username"
            placeholder="用户名"
            size="large"
            autocomplete="username"
          />
        </a-form-item>
        <a-form-item name="password" :rules="[{ required: true, message: '请输入密码' }]">
          <a-input-password
            v-model:value="form.password"
            placeholder="密码"
            size="large"
            autocomplete="current-password"
          />
        </a-form-item>
        <a-form-item>
          <a-button
            type="primary"
            html-type="submit"
            size="large"
            :loading="loading"
            block
          >
            登录
          </a-button>
        </a-form-item>
      </a-form>
    </div>
    <p class="login-footer">励学笃行 · 南京理工大学紫金学院 · CPMS © 2026</p>
  </div>
</template>

<script setup>
import { reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { message } from 'ant-design-vue'
import http from '@/api'
import { useUserStore } from '@/stores/user'

const router = useRouter()
const store = useUserStore()
const loading = ref(false)

const form = reactive({
  username: '',
  password: ''
})

async function handleLogin() {
  loading.value = true
  try {
    const data = await http.post('/auth/login', {
      username: form.username,
      password: form.password
    })
    store.setUser(data)
    await store.fetchOwnerId()
    message.success('登录成功')
    router.push('/home')
  } catch {
    // error handled by axios interceptor
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.login-page {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  background: #faf9f7;
}

.login-card {
  width: 400px;
  background: #fff;
  border-radius: 12px;
  padding: 40px;
  box-shadow: 0 1px 3px rgba(0,0,0,.06);
  border: 1px solid #e8e5e0;
}

.login-brand {
  text-align: center;
  margin-bottom: 32px;
}

.login-brand h1 {
  margin: 12px 0 4px;
  font-size: 20px;
  font-weight: 700;
  color: #1e1b2e;
}

.login-brand p {
  margin: 0;
  font-size: 14px;
  color: #787580;
}

.login-form {
  margin-top: 8px;
}

.login-footer {
  margin-top: 24px;
  font-size: 12px;
  color: #c4c0d0;
}
</style>
