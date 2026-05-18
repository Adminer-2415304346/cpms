<template>
  <div class="dashboard">
    <!-- 欢迎横幅 -->
    <div class="welcome-banner">
      <div class="banner-bg-shapes">
        <div class="shape shape-1"></div>
        <div class="shape shape-2"></div>
        <div class="shape shape-3"></div>
      </div>
      <div class="banner-text">
        <h2>
          <span class="greeting-wave">{{ timeEmoji }}</span>
          {{ timeGreeting }}，{{ userStore.realName || userStore.username }}
        </h2>
        <p>欢迎使用社区物业管理系统 · 今天是 {{ today }}</p>
      </div>
      <div class="banner-decor">
        <div class="decor-circle decor-1"></div>
        <div class="decor-circle decor-2"></div>
        <div class="decor-circle decor-3"></div>
      </div>
    </div>

    <!-- 统计卡片 -->
    <a-row :gutter="[16, 16]" style="margin-top: 20px">
      <a-col :xs="12" :lg="6" v-for="(card, i) in statCards" :key="card.title">
        <div class="stat-card" :style="{ animationDelay: `${0.08 + i * 0.06}s` }">
          <div class="stat-top">
            <div class="stat-icon-box" :style="{ background: card.color }">
              <component :is="card.icon" />
            </div>
            <span class="stat-trend" :class="card.trendUp ? 'trend-up' : 'trend-down'">
              {{ card.trend }}
            </span>
          </div>
          <div class="stat-value">
            <span ref="countRefs">{{ animatedValues[i] }}</span>
          </div>
          <div class="stat-label">{{ card.title }}</div>
          <div class="stat-glow" :style="{ background: card.color }"></div>
        </div>
      </a-col>
    </a-row>

    <!-- 系统概况 + 快捷入口 -->
    <a-row :gutter="[16, 16]" style="margin-top: 20px">
      <a-col :xs="24" :lg="12">
        <div class="info-card">
          <div class="info-header">
            <h4>
              <span class="header-dot sys-dot"></span>
              系统概况
            </h4>
          </div>
          <div class="info-body">
            <div class="info-row" v-for="item in sysInfo" :key="item.label">
              <span class="info-label">{{ item.label }}</span>
              <span class="info-value">{{ item.value }}</span>
            </div>
          </div>
        </div>
      </a-col>
      <a-col :xs="24" :lg="12">
        <div class="info-card">
          <div class="info-header">
            <h4>
              <span class="header-dot quick-dot"></span>
              快捷入口
            </h4>
          </div>
          <div class="quick-links">
            <a v-if="isAdmin||isStaff" @click="$router.push('/bills?unpaid=true')" class="quick-item">
              <span class="quick-icon unpaid"><DollarOutlined /></span>
              <span class="quick-label">查看欠费账单</span>
              <RightOutlined class="quick-arrow" />
            </a>
            <a @click="$router.push('/repairs')" class="quick-item">
              <span class="quick-icon repair"><ToolOutlined /></span>
              <span class="quick-label">查看报修工单</span>
              <RightOutlined class="quick-arrow" />
            </a>
            <a @click="$router.push('/announcements')" class="quick-item">
              <span class="quick-icon notice"><SoundOutlined /></span>
              <span class="quick-label">查看社区公告</span>
              <RightOutlined class="quick-arrow" />
            </a>
            <a v-if="isAdmin" @click="$router.push('/users')" class="quick-item">
              <span class="quick-icon user"><TeamOutlined /></span>
              <span class="quick-label">管理用户账号</span>
              <RightOutlined class="quick-arrow" />
            </a>
          </div>
        </div>
      </a-col>
    </a-row>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { HomeOutlined, TeamOutlined, DollarOutlined, ToolOutlined, SoundOutlined, RightOutlined } from '@ant-design/icons-vue'
import { useUserStore } from '@/stores/user'
import dayjs from 'dayjs'

const userStore = useUserStore()
const isAdmin = computed(() => userStore.role === 'admin')
const isStaff = computed(() => userStore.role === 'staff')

const today = computed(() => dayjs().format('YYYY年M月D日 dddd'))

const timeGreeting = computed(() => {
  const h = new Date().getHours()
  if (h < 6) return '夜深了'
  if (h < 9) return '早上好'
  if (h < 12) return '上午好'
  if (h < 14) return '中午好'
  if (h < 18) return '下午好'
  return '晚上好'
})

const timeEmoji = computed(() => {
  const h = new Date().getHours()
  if (h < 6) return '🌙'
  if (h < 9) return '☀️'
  if (h < 12) return '🌤️'
  if (h < 14) return '🌞'
  if (h < 18) return '🌅'
  return '🌙'
})

// 统计卡片数据（目标值）
const targets = [2, 3, 1, 2]
const animatedValues = ref([0, 0, 0, 0])

// 数字递增动画
const animateCount = (index, target, duration = 800) => {
  const start = performance.now()
  const tick = (now) => {
    const elapsed = now - start
    const progress = Math.min(elapsed / duration, 1)
    // easeOutCubic
    const eased = 1 - Math.pow(1 - progress, 3)
    animatedValues.value[index] = Math.round(eased * target)
    if (progress < 1) {
      requestAnimationFrame(tick)
    }
  }
  requestAnimationFrame(tick)
}

onMounted(() => {
  targets.forEach((target, i) => {
    setTimeout(() => animateCount(i, target), 200 + i * 80)
  })
})

const statCards = computed(() => [
  { title: '楼栋总数', value: targets[0], trend: '+0', trendUp: false, icon: HomeOutlined, color: 'linear-gradient(135deg, #ddd6fe, #c4b5fd)' },
  { title: '注册业主', value: targets[1], trend: '+1', trendUp: true, icon: TeamOutlined, color: 'linear-gradient(135deg, #fecaca, #fca5a5)' },
  { title: '待处理报修', value: targets[2], trend: '-2', trendUp: false, icon: ToolOutlined, color: 'linear-gradient(135deg, #fef08a, #fde68a)' },
  { title: '社区公告', value: targets[3], trend: '+2', trendUp: true, icon: SoundOutlined, color: 'linear-gradient(135deg, #bbf7d0, #86efac)' },
])

const sysInfo = [
  { label: '系统名称', value: '社区物业管理系统 (CPMS)' },
  { label: '当前角色', value: { admin:'系统管理员', staff:'物业人员', owner:'业主' }[userStore.role] },
  { label: '数据库', value: 'MySQL 8.0' },
  { label: '后端框架', value: 'Spring Boot 3.5 + JPA' },
  { label: '前端技术', value: 'Vue 3 + Ant Design Vue 4' },
]
</script>

<style scoped>
/* ====== 欢迎横幅 ====== */
.welcome-banner {
  background: linear-gradient(135deg, #1a0533 0%, #2d1065 30%, #1e3a8a 70%, #1e40af 100%);
  border-radius: 18px;
  padding: 32px 36px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  position: relative;
  overflow: hidden;
  box-shadow: 0 12px 50px rgba(124,58,237,0.2);
  animation: banner-in 0.5s cubic-bezier(0.22, 1, 0.36, 1) both;
}

@keyframes banner-in {
  from { opacity: 0; transform: translateY(-20px); }
  to { opacity: 1; transform: translateY(0); }
}

.banner-bg-shapes {
  position: absolute;
  inset: 0;
  pointer-events: none;
}
.shape {
  position: absolute;
  border-radius: 50%;
  opacity: 0.06;
}
.shape-1 {
  width: 300px; height: 300px;
  background: #a78bfa;
  top: -80px; left: -60px;
  animation: shape-drift 12s ease-in-out infinite;
}
.shape-2 {
  width: 200px; height: 200px;
  background: #60a5fa;
  bottom: -50px; right: 10%;
  animation: shape-drift 15s ease-in-out infinite reverse;
}
.shape-3 {
  width: 150px; height: 150px;
  background: #f59e0b;
  top: 30%; right: 25%;
  animation: shape-drift 10s ease-in-out infinite;
}
@keyframes shape-drift {
  0%, 100% { transform: translate(0, 0) scale(1); }
  33% { transform: translate(30px, -20px) scale(1.15); }
  66% { transform: translate(-20px, 20px) scale(0.9); }
}

.banner-text {
  position: relative;
  z-index: 1;
}
.banner-text h2 {
  color: #fff;
  margin: 0;
  font-size: 22px;
  font-weight: 600;
  letter-spacing: 1px;
}
.greeting-wave {
  display: inline-block;
  animation: wave 1.5s ease-in-out infinite;
  transform-origin: 70% 70%;
}
@keyframes wave {
  0%, 100% { transform: rotate(0deg); }
  25% { transform: rotate(12deg); }
  50% { transform: rotate(0deg); }
  75% { transform: rotate(-8deg); }
}
.banner-text p {
  color: rgba(255,255,255,0.55);
  margin: 8px 0 0;
  font-size: 13px;
  letter-spacing: 0.5px;
}

.banner-decor {
  position: absolute;
  right: 40px;
  top: 50%;
  transform: translateY(-50%);
}
.decor-circle {
  position: absolute;
  border-radius: 50%;
  border: 1.5px solid rgba(255,255,255,0.1);
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
}
.decor-1 { width: 160px; height: 160px; animation: decor-pulse 4s ease-in-out infinite; }
.decor-2 { width: 200px; height: 200px; animation: decor-pulse 4s ease-in-out 0.5s infinite; }
.decor-3 { width: 240px; height: 240px; animation: decor-pulse 4s ease-in-out 1s infinite; }
@keyframes decor-pulse {
  0%, 100% { opacity: 0.3; transform: translate(-50%, -50%) scale(1); }
  50% { opacity: 0.7; transform: translate(-50%, -50%) scale(1.08); }
}

/* ====== 统计卡片 ====== */
.stat-card {
  background: #fff;
  border-radius: 16px;
  padding: 22px 20px;
  cursor: pointer;
  transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
  box-shadow: 0 2px 16px rgba(0,0,0,0.04);
  border: 1px solid rgba(0,0,0,0.05);
  position: relative;
  overflow: hidden;
  animation: card-in 0.5s cubic-bezier(0.22, 1, 0.36, 1) both;
}

@keyframes card-in {
  from { opacity: 0; transform: translateY(24px); }
  to { opacity: 1; transform: translateY(0); }
}

.stat-glow {
  position: absolute;
  top: -50%;
  right: -50%;
  width: 150px;
  height: 150px;
  border-radius: 50%;
  opacity: 0;
  transition: opacity 0.5s ease;
  filter: blur(40px);
  pointer-events: none;
}
.stat-card:hover .stat-glow {
  opacity: 0.35;
}

.stat-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 14px 40px rgba(124,58,237,0.1);
  border-color: rgba(124,58,237,0.12);
}

.stat-top {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
  position: relative;
  z-index: 1;
}

.stat-icon-box {
  width: 44px;
  height: 44px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 21px;
  color: #4c1d95;
  transition: transform 0.3s ease;
}
.stat-card:hover .stat-icon-box {
  transform: scale(1.1) rotate(-5deg);
}

.stat-trend {
  font-size: 12px;
  font-weight: 500;
}
.trend-up { color: #16a34a; }
.trend-down { color: #9ca3af; }

.stat-value {
  font-size: 36px;
  font-weight: 800;
  color: #1f2937;
  line-height: 1;
  margin-bottom: 8px;
  position: relative;
  z-index: 1;
  font-variant-numeric: tabular-nums;
}

.stat-label {
  font-size: 13px;
  color: #9ca3af;
  position: relative;
  z-index: 1;
}

/* ====== 信息卡片 ====== */
.info-card {
  background: #fff;
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 2px 16px rgba(0,0,0,0.04);
  border: 1px solid rgba(0,0,0,0.05);
  transition: all 0.35s ease;
}
.info-card:hover {
  box-shadow: 0 8px 30px rgba(124,58,237,0.06);
}

.info-header {
  padding: 18px 24px 14px;
  border-bottom: 1px solid #f3f4f6;
}
.info-header h4 {
  margin: 0;
  font-size: 15px;
  font-weight: 600;
  color: #1f2937;
  display: flex;
  align-items: center;
  gap: 8px;
}
.header-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
}
.sys-dot { background: #7c3aed; box-shadow: 0 0 8px rgba(124,58,237,0.4); }
.quick-dot { background: #f59e0b; box-shadow: 0 0 8px rgba(245,158,11,0.4); }

.info-body {
  padding: 10px 24px 20px;
}
.info-row {
  display: flex;
  justify-content: space-between;
  padding: 11px 0;
  border-bottom: 1px solid #f9fafb;
}
.info-row:last-child { border-bottom: none; }
.info-label { font-size: 13px; color: #9ca3af; }
.info-value { font-size: 13px; color: #374151; font-weight: 500; }

/* ====== 快捷入口 ====== */
.quick-links { padding: 6px 24px 20px; }
.quick-item {
  display: flex;
  align-items: center;
  gap: 14px;
  padding: 15px 0;
  border-bottom: 1px solid #f9fafb;
  color: #374151;
  font-size: 14px;
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  border-radius: 8px;
  margin: 2px -8px;
  padding-left: 8px;
  padding-right: 8px;
}
.quick-item:last-child { border-bottom: none; }
.quick-item:hover {
  color: #7c3aed;
  background: rgba(124,58,237,0.04);
  transform: translateX(4px);
}
.quick-icon {
  width: 34px;
  height: 34px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 16px;
  transition: all 0.3s ease;
}
.quick-item:hover .quick-icon { transform: scale(1.1) rotate(-5deg); }
.quick-icon.unpaid { background: rgba(239,68,68,0.1); color: #ef4444; }
.quick-icon.repair { background: rgba(245,158,11,0.1); color: #f59e0b; }
.quick-icon.notice { background: rgba(59,130,246,0.1); color: #3b82f6; }
.quick-icon.user { background: rgba(139,92,246,0.1); color: #8b5cf6; }
.quick-label { flex: 1; }
.quick-arrow {
  font-size: 12px;
  color: #d1d5db;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}
.quick-item:hover .quick-arrow { color: #7c3aed; transform: translateX(4px); }
</style>
