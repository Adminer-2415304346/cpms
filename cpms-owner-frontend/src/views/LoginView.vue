<template>
  <div class="login-root">
    <!-- 装饰侧 -->
    <aside class="login-hero">
      <div class="hero-ambient">
        <div class="orb orb-1"></div>
        <div class="orb orb-2"></div>
        <div class="orb orb-3"></div>
      </div>
      <div class="hero-content">
        <p class="hero-eyebrow">COMMUNITY PROPERTY MANAGEMENT</p>
        <h1 class="hero-title">CPMS</h1>
        <p class="hero-sub">业主服务</p>
        <p class="hero-desc">
          您的社区生活管家<br />
          账单查询 · 报修提交 · 社区动态
        </p>
      </div>
    </aside>

    <!-- 表单侧 -->
    <main class="login-main">
      <div class="login-form-wrap">
        <div class="form-header">
          <h2>欢迎回来</h2>
          <p>请登录您的业主账户</p>
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
        <p class="form-footer">励学笃行 · 南京理工大学紫金学院 · CPMS © 2026</p>
      </div>
    </main>
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
.login-root {
  display: flex;
  min-height: 100vh;
}

/* ---- 装饰侧 ---- */
.login-hero {
  flex: 0 0 52%;
  position: relative;
  background: linear-gradient(160deg, #f5efe5 0%, #ede3d3 30%, #e5d9c5 60%, #faf6f0 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
}

.hero-ambient {
  position: absolute;
  inset: 0;
}

.orb {
  position: absolute;
  border-radius: 50%;
  filter: blur(60px);
  opacity: 0.5;
  animation: orbDrift 20s ease-in-out infinite;
}
.orb-1 {
  width: 380px;
  height: 380px;
  background: rgba(193,120,78,.18);
  top: -8%;
  left: -12%;
  animation-delay: 0s;
}
.orb-2 {
  width: 280px;
  height: 280px;
  background: rgba(180,150,120,.14);
  bottom: -10%;
  right: -5%;
  animation-delay: -7s;
}
.orb-3 {
  width: 200px;
  height: 200px;
  background: rgba(160,140,100,.12);
  top: 50%;
  left: 40%;
  animation-delay: -13s;
}

@keyframes orbDrift {
  0%, 100% { transform: translate(0,0) scale(1); }
  25% { transform: translate(30px,-20px) scale(1.06); }
  50% { transform: translate(-15px,25px) scale(.95); }
  75% { transform: translate(-25px,-10px) scale(1.04); }
}

.hero-content {
  position: relative;
  z-index: 1;
  text-align: center;
  padding: 48px;
}

.hero-eyebrow {
  font-family: var(--font-ui);
  font-size: 11px;
  font-weight: 500;
  letter-spacing: 3px;
  text-transform: uppercase;
  color: var(--c-muted);
  margin: 0 0 20px;
}

.hero-title {
  font-family: var(--font-display);
  font-size: 80px;
  font-weight: 700;
  letter-spacing: -2px;
  color: var(--c-ink);
  margin: 0;
  line-height: 1;
}

.hero-sub {
  font-family: var(--font-display);
  font-size: 24px;
  font-weight: 500;
  color: var(--c-copper);
  margin: 8px 0 24px;
  letter-spacing: 4px;
}

.hero-desc {
  font-size: 14px;
  color: var(--c-muted);
  line-height: 1.8;
  margin: 0;
}

/* ---- 表单侧 ---- */
.login-main {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--c-surface);
  padding: 48px;
}

.login-form-wrap {
  width: 100%;
  max-width: 380px;
}

.form-header {
  margin-bottom: 36px;
}
.form-header h2 {
  font-family: var(--font-display);
  font-size: 30px;
  font-weight: 600;
  color: var(--c-ink);
  margin: 0 0 6px;
  letter-spacing: -0.4px;
}
.form-header p {
  font-size: 14px;
  color: var(--c-muted);
  margin: 0;
}

.login-form :deep(.ant-form-item) {
  margin-bottom: 20px;
}

.form-footer {
  margin-top: 32px;
  font-size: 12px;
  color: var(--c-muted-light);
  text-align: center;
}

/* ---- 响应式 ---- */
@media (max-width: 768px) {
  .login-root { flex-direction: column; }
  .login-hero {
    flex: 0 0 auto;
    padding: 40px 24px;
    min-height: 200px;
  }
  .hero-title { font-size: 48px; }
  .hero-sub { font-size: 18px; letter-spacing: 2px; }
  .login-main { padding: 32px 24px; }
}
</style>
