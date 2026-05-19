<template>
  <div class="login-page">
    <!-- 动态光斑背景 -->
    <div class="fluid-bg">
      <div class="orb orb-1"></div>
      <div class="orb orb-2"></div>
      <div class="orb orb-3"></div>
      <div class="orb orb-4"></div>
      <div class="orb orb-5"></div>
    </div>

    <!-- 粒子线 -->
    <canvas ref="canvasRef" class="particle-canvas"></canvas>

    <div class="login-card">
      <div class="card-left">
        <div class="brand-glow"></div>
        <div class="school-brand">
          <div class="dragon-icon">
            <svg viewBox="0 0 64 64" fill="none">
              <circle cx="32" cy="32" r="30" stroke="rgba(255,255,255,0.3)" stroke-width="1.2"/>
              <circle cx="32" cy="32" r="26" stroke="rgba(255,255,255,0.15)" stroke-width="0.5"/>
              <path d="M32 12c-8 0-14 6-14 14s6 18 14 24c8-6 14-14 14-24s-6-14-14-14z" fill="none" stroke="rgba(255,255,255,0.8)" stroke-width="1.2"/>
              <path d="M18 28c0 6 6 20 14 26M46 28c0 6-6 20-14 26" stroke="rgba(255,255,255,0.3)" stroke-width="0.8"/>
              <path d="M32 22c-3 0-5 2-5 5s3 8 5 11c2-3 5-5 5-11s-2-5-5-5z" fill="none" stroke="rgba(255,255,255,0.6)" stroke-width="1"/>
            </svg>
          </div>
          <h2 class="school-name">南京理工大学紫金学院</h2>
          <p class="school-sub">Zijin College · NJUST</p>
        </div>
      </div>

      <div class="card-right">
        <div class="login-header">
          <h1 class="login-title">社区物业管理系统</h1>
          <p class="login-subtitle">Community Property Management System</p>
        </div>

        <a-form
          :model="form"
          :rules="rules"
          ref="formRef"
          class="login-form"
          @finish="handleLogin"
        >
          <a-form-item name="username">
            <a-input
              v-model:value="form.username"
              size="large"
              placeholder="用户名"
              autocomplete="username"
              class="custom-input"
            >
              <template #prefix>
                <UserOutlined />
              </template>
            </a-input>
          </a-form-item>

          <a-form-item name="password">
            <a-input-password
              v-model:value="form.password"
              size="large"
              placeholder="密码"
              autocomplete="current-password"
              class="custom-input"
            >
              <template #prefix>
                <LockOutlined />
              </template>
            </a-input-password>
          </a-form-item>

          <a-form-item>
            <a-button
              type="primary"
              size="large"
              html-type="submit"
              :loading="loading"
              class="login-btn"
            >
              <span class="btn-text">登 录</span>
              <span class="btn-shimmer"></span>
            </a-button>
          </a-form-item>
        </a-form>
      </div>
    </div>

    <div class="footer-text">励学笃行 · 诚信 勤奋 求是 创新</div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'
import { UserOutlined, LockOutlined } from '@ant-design/icons-vue'
import { message } from 'ant-design-vue'
import http from '@/api'
import { useUserStore } from '@/stores/user'

const router = useRouter()
const userStore = useUserStore()
const formRef = ref()
const loading = ref(false)
const canvasRef = ref(null)

const form = reactive({ username: '', password: '' })

const rules = {
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }]
}

const handleLogin = async () => {
  try {
    loading.value = true
    const data = await http.post('/auth/login', {
      username: form.username,
      password: form.password
    })
    userStore.setUser(data)
    message.success('登录成功')
    router.push('/dashboard')
  } catch {
  } finally {
    loading.value = false
  }
}

// 粒子动画
let animId = null
onMounted(() => {
  const canvas = canvasRef.value
  if (!canvas) return
  const ctx = canvas.getContext('2d')

  const resize = () => {
    canvas.width = window.innerWidth
    canvas.height = window.innerHeight
  }
  resize()
  window.addEventListener('resize', resize)

  const particles = Array.from({ length: 40 }, () => ({
    x: Math.random() * canvas.width,
    y: Math.random() * canvas.height,
    vx: (Math.random() - 0.5) * 0.4,
    vy: (Math.random() - 0.5) * 0.4,
    r: Math.random() * 1.5 + 0.5,
    alpha: Math.random() * 0.4 + 0.1,
    alphaDir: Math.random() > 0.5 ? 0.003 : -0.003
  }))

  const draw = () => {
    ctx.clearRect(0, 0, canvas.width, canvas.height)

    for (let i = 0; i < particles.length; i++) {
      const p = particles[i]
      p.x += p.vx
      p.y += p.vy
      p.alpha += p.alphaDir
      if (p.alpha <= 0.05 || p.alpha >= 0.5) p.alphaDir *= -1

      if (p.x < 0) p.x = canvas.width
      if (p.x > canvas.width) p.x = 0
      if (p.y < 0) p.y = canvas.height
      if (p.y > canvas.height) p.y = 0

      // 画连线
      for (let j = i + 1; j < particles.length; j++) {
        const q = particles[j]
        const dx = p.x - q.x
        const dy = p.y - q.y
        const dist = Math.sqrt(dx * dx + dy * dy)
        if (dist < 140) {
          ctx.beginPath()
          ctx.moveTo(p.x, p.y)
          ctx.lineTo(q.x, q.y)
          ctx.strokeStyle = `rgba(167,139,250,${0.06 * (1 - dist / 140)})`
          ctx.lineWidth = 0.5
          ctx.stroke()
        }
      }

      ctx.beginPath()
      ctx.arc(p.x, p.y, p.r, 0, Math.PI * 2)
      ctx.fillStyle = `rgba(255,255,255,${p.alpha})`
      ctx.fill()
    }
    animId = requestAnimationFrame(draw)
  }
  draw()
})

onUnmounted(() => {
  if (animId) cancelAnimationFrame(animId)
})
</script>

<style scoped>
.login-page {
  position: relative;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  background: #0f0a1a;
  overflow: hidden;
}

/* ====== 动态光斑 ====== */
.fluid-bg {
  position: absolute;
  inset: 0;
  filter: blur(80px);
  opacity: 0.7;
}

.orb {
  position: absolute;
  border-radius: 50%;
}

.orb-1 {
  width: 600px;
  height: 600px;
  background: radial-gradient(circle, rgba(124,58,237,0.6) 0%, transparent 70%);
  top: -200px;
  left: -100px;
  animation: float1 18s ease-in-out infinite;
}

.orb-2 {
  width: 500px;
  height: 500px;
  background: radial-gradient(circle, rgba(59,130,246,0.5) 0%, transparent 70%);
  bottom: -250px;
  right: -150px;
  animation: float2 22s ease-in-out infinite;
}

.orb-3 {
  width: 350px;
  height: 350px;
  background: radial-gradient(circle, rgba(139,92,246,0.45) 0%, transparent 70%);
  top: 40%;
  left: 50%;
  transform: translate(-50%, -50%);
  animation: float3 15s ease-in-out infinite;
}

.orb-4 {
  width: 280px;
  height: 280px;
  background: radial-gradient(circle, rgba(99,102,241,0.4) 0%, transparent 70%);
  top: 10%;
  right: 20%;
  animation: float4 20s ease-in-out infinite;
}

.orb-5 {
  width: 400px;
  height: 400px;
  background: radial-gradient(circle, rgba(167,139,250,0.35) 0%, transparent 70%);
  bottom: 10%;
  left: 10%;
  animation: float5 25s ease-in-out infinite;
}

@keyframes float1 {
  0%, 100% { transform: translate(0, 0) scale(1); }
  25% { transform: translate(80px, 60px) scale(1.15); }
  50% { transform: translate(40px, -40px) scale(0.9); }
  75% { transform: translate(-60px, 30px) scale(1.1); }
}

@keyframes float2 {
  0%, 100% { transform: translate(0, 0) scale(1); }
  33% { transform: translate(-70px, -50px) scale(1.2); }
  66% { transform: translate(50px, 70px) scale(0.85); }
}

@keyframes float3 {
  0%, 100% { transform: translate(-50%, -50%) scale(1); }
  25% { transform: translate(-40%, -60%) scale(1.1); }
  50% { transform: translate(-60%, -40%) scale(0.95); }
  75% { transform: translate(-40%, -30%) scale(1.05); }
}

@keyframes float4 {
  0%, 100% { transform: translate(0, 0) scale(1); }
  50% { transform: translate(60px, -80px) scale(1.2); }
}

@keyframes float5 {
  0%, 100% { transform: translate(0, 0) scale(1); }
  50% { transform: translate(-50px, 60px) scale(1.15); }
}

/* ====== 粒子画布 ====== */
.particle-canvas {
  position: absolute;
  inset: 0;
  z-index: 0;
  pointer-events: none;
}

/* ====== 登录卡片 ====== */
.login-card {
  position: relative;
  z-index: 1;
  display: flex;
  width: 860px;
  min-height: 460px;
  border-radius: 20px;
  overflow: hidden;
  background: rgba(255,255,255,0.93);
  backdrop-filter: blur(24px);
  box-shadow:
    0 0 0 1px rgba(255,255,255,0.1),
    0 30px 80px rgba(0,0,0,0.5),
    0 0 120px rgba(124,58,237,0.15);
  animation: cardIn 0.8s cubic-bezier(0.16, 1, 0.3, 1);
}

@keyframes cardIn {
  from { opacity: 0; transform: translateY(30px) scale(0.97); }
  to { opacity: 1; transform: translateY(0) scale(1); }
}

.card-left {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(160deg, #1a0533 0%, #2d1065 30%, #1e3a8a 70%, #1e40af 100%);
  padding: 48px 36px;
  position: relative;
}

.brand-glow {
  position: absolute;
  width: 200px;
  height: 200px;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  background: radial-gradient(circle, rgba(167,139,250,0.25) 0%, transparent 60%);
  animation: glowPulse 3s ease-in-out infinite;
}

@keyframes glowPulse {
  0%, 100% { opacity: 0.6; transform: translate(-50%, -50%) scale(1); }
  50% { opacity: 1; transform: translate(-50%, -50%) scale(1.3); }
}

.school-brand {
  position: relative;
  z-index: 1;
  text-align: center;
}

.dragon-icon {
  margin-bottom: 24px;
  animation: iconFloat 3s ease-in-out infinite;
}

@keyframes iconFloat {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-6px); }
}

.school-name {
  color: #fff;
  font-size: 21px;
  font-weight: 600;
  letter-spacing: 5px;
  margin: 0 0 8px;
}

.school-sub {
  color: rgba(255,255,255,0.45);
  font-size: 10px;
  letter-spacing: 2px;
  text-transform: uppercase;
  margin: 0;
}

/* ====== 右侧表单区 ====== */
.card-right {
  flex: 1;
  padding: 48px 44px;
  display: flex;
  flex-direction: column;
  justify-content: center;
  background: rgba(255,255,255,0.98);
}

.login-header {
  margin-bottom: 36px;
}

.login-title {
  font-size: 23px;
  font-weight: 700;
  color: #1a1a2e;
  margin: 0 0 6px;
  letter-spacing: 2px;
}

.login-subtitle {
  font-size: 12px;
  color: #999;
  margin: 0;
  letter-spacing: 1px;
}

/* ====== 输入框 ====== */
.custom-input :deep(.ant-input-affix-wrapper) {
  border-radius: 10px;
  border: 1.5px solid #e5e7eb;
  transition: all 0.3s ease;
  background: #fafafa;
}

.custom-input :deep(.ant-input-affix-wrapper:hover) {
  border-color: #a78bfa;
}

.custom-input :deep(.ant-input-affix-wrapper:focus),
.custom-input :deep(.ant-input-affix-wrapper-focused) {
  border-color: #7c3aed;
  box-shadow: 0 0 0 3px rgba(124,58,237,0.1);
  background: #fff;
}

/* ====== 登录按钮 ====== */
.login-btn {
  width: 100%;
  height: 46px;
  font-size: 15px;
  letter-spacing: 5px;
  border-radius: 10px;
  border: none;
  background: linear-gradient(135deg, #7c3aed 0%, #4f46e5 50%, #3b82f6 100%);
  position: relative;
  overflow: hidden;
  transition: all 0.4s ease;
  font-weight: 500;
}

.login-btn:hover {
  background: linear-gradient(135deg, #8b5cf6 0%, #6366f1 50%, #60a5fa 100%);
  transform: translateY(-1px);
  box-shadow: 0 8px 30px rgba(124,58,237,0.4);
}

.login-btn:active {
  transform: translateY(0);
}

.btn-shimmer {
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255,255,255,0.2), transparent);
  animation: shimmer 3s infinite;
}

@keyframes shimmer {
  0% { left: -100%; }
  50%, 100% { left: 100%; }
}

/* ====== 页脚 ====== */
.footer-text {
  position: absolute;
  bottom: 28px;
  color: rgba(255,255,255,0.3);
  font-size: 12px;
  letter-spacing: 3px;
  z-index: 1;
}

/* ====== 响应式 ====== */
@media (max-width: 900px) {
  .login-card {
    width: 92vw;
    flex-direction: column;
    min-height: auto;
  }
  .card-left { padding: 32px 28px; }
  .card-right { padding: 36px 28px; }
  .school-name { font-size: 17px; }
  .login-title { font-size: 19px; }
}
</style>
