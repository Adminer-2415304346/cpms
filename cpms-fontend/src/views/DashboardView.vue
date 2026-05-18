<template>
  <div class="dashboard">
    <div class="welcome-banner">
      <div class="banner-text">
        <h2>{{ timeGreeting }}，{{ userStore.realName || userStore.username }}</h2>
        <p>欢迎使用社区物业管理系统，今天是 {{ today }}</p>
      </div>
      <div class="banner-decor">
        <div class="decor-blob"></div>
      </div>
    </div>

    <a-row :gutter="16" style="margin-top: 20px">
      <a-col :span="6" v-for="card in statCards" :key="card.title">
        <div class="stat-card">
          <div class="stat-top">
            <div class="stat-icon-box" :style="{ background: card.color }">
              <component :is="card.icon" />
            </div>
            <span class="stat-trend">较上月 {{ card.trend }}</span>
          </div>
          <div class="stat-value">{{ card.value }}</div>
          <div class="stat-label">{{ card.title }}</div>
        </div>
      </a-col>
    </a-row>

    <a-row :gutter="16" style="margin-top: 20px">
      <a-col :span="12">
        <div class="info-card">
          <div class="info-header">
            <h4>系统概况</h4>
          </div>
          <div class="info-body">
            <div class="info-row" v-for="item in sysInfo" :key="item.label">
              <span class="info-label">{{ item.label }}</span>
              <span class="info-value">{{ item.value }}</span>
            </div>
          </div>
        </div>
      </a-col>
      <a-col :span="12">
        <div class="info-card">
          <div class="info-header">
            <h4>快捷入口</h4>
          </div>
          <div class="quick-links">
            <a v-if="isAdmin||isStaff" @click="$router.push('/bills?unpaid=true')" class="quick-item">
              <span class="quick-dot unpaid"></span>
              <span>查看欠费账单</span>
              <RightOutlined class="quick-arrow" />
            </a>
            <a @click="$router.push('/repairs')" class="quick-item">
              <span class="quick-dot repair"></span>
              <span>查看报修工单</span>
              <RightOutlined class="quick-arrow" />
            </a>
            <a @click="$router.push('/announcements')" class="quick-item">
              <span class="quick-dot notice"></span>
              <span>查看社区公告</span>
              <RightOutlined class="quick-arrow" />
            </a>
            <a v-if="isAdmin" @click="$router.push('/users')" class="quick-item">
              <span class="quick-dot user"></span>
              <span>管理用户账号</span>
              <RightOutlined class="quick-arrow" />
            </a>
          </div>
        </div>
      </a-col>
    </a-row>
  </div>
</template>

<script setup>
import { computed } from 'vue'
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

const statCards = computed(() => [
  { title: '楼栋总数', value: '2', trend: '+0', icon: HomeOutlined, color: 'linear-gradient(135deg, #ddd6fe, #c4b5fd)' },
  { title: '注册业主', value: '3', trend: '+1', icon: TeamOutlined, color: 'linear-gradient(135deg, #fecaca, #fca5a5)' },
  { title: '待处理报修', value: '1', trend: '-2', icon: ToolOutlined, color: 'linear-gradient(135deg, #fef08a, #fde68a)' },
  { title: '社区公告', value: '2', trend: '+2', icon: SoundOutlined, color: 'linear-gradient(135deg, #bbf7d0, #86efac)' },
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
  background: linear-gradient(135deg, #2d1065 0%, #4c1d95 40%, #1e3a8a 100%);
  border-radius: 16px;
  padding: 28px 32px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  position: relative;
  overflow: hidden;
  box-shadow: 0 8px 40px rgba(124,58,237,0.2);
}

.banner-text h2 {
  color: #fff;
  margin: 0;
  font-size: 20px;
  font-weight: 600;
  letter-spacing: 1px;
}

.banner-text p {
  color: rgba(255,255,255,0.6);
  margin: 6px 0 0;
  font-size: 13px;
}

.banner-decor {
  position: absolute;
  right: -60px;
  top: -60px;
}

.decor-blob {
  width: 220px;
  height: 220px;
  border-radius: 50%;
  background: radial-gradient(circle, rgba(167,139,250,0.25), transparent 70%);
  animation: blobPulse 4s ease-in-out infinite;
}

@keyframes blobPulse {
  0%, 100% { transform: scale(1); opacity: 0.6; }
  50% { transform: scale(1.3); opacity: 0.9; }
}

/* ====== 统计卡片 ====== */
.stat-card {
  background: #fff;
  border-radius: 14px;
  padding: 22px 20px;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 2px 12px rgba(0,0,0,0.03);
  border: 1px solid rgba(0,0,0,0.04);
}

.stat-card:hover {
  transform: translateY(-3px);
  box-shadow: 0 8px 30px rgba(124,58,237,0.08);
  border-color: rgba(124,58,237,0.1);
}

.stat-top {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 14px;
}

.stat-icon-box {
  width: 42px;
  height: 42px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 20px;
  color: #4c1d95;
}

.stat-trend {
  font-size: 12px;
  color: #9ca3af;
}

.stat-value {
  font-size: 32px;
  font-weight: 800;
  color: #1f2937;
  line-height: 1;
  margin-bottom: 6px;
}

.stat-label {
  font-size: 13px;
  color: #9ca3af;
}

/* ====== 信息卡片 ====== */
.info-card {
  background: #fff;
  border-radius: 14px;
  overflow: hidden;
  box-shadow: 0 2px 12px rgba(0,0,0,0.03);
  border: 1px solid rgba(0,0,0,0.04);
}

.info-header {
  padding: 18px 22px 14px;
  border-bottom: 1px solid #f3f4f6;
}

.info-header h4 {
  margin: 0;
  font-size: 15px;
  font-weight: 600;
  color: #1f2937;
}

.info-body {
  padding: 10px 22px 18px;
}

.info-row {
  display: flex;
  justify-content: space-between;
  padding: 10px 0;
  border-bottom: 1px solid #f9fafb;
}

.info-row:last-child {
  border-bottom: none;
}

.info-label {
  font-size: 13px;
  color: #9ca3af;
}

.info-value {
  font-size: 13px;
  color: #374151;
  font-weight: 500;
}

/* ====== 快捷入口 ====== */
.quick-links {
  padding: 6px 22px 18px;
}

.quick-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 14px 0;
  border-bottom: 1px solid #f9fafb;
  color: #374151;
  font-size: 14px;
  cursor: pointer;
  transition: all 0.2s;
}

.quick-item:last-child { border-bottom: none; }

.quick-item:hover {
  color: #7c3aed;
  padding-left: 4px;
}

.quick-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
}
.quick-dot.unpaid { background: #ef4444; box-shadow: 0 0 8px rgba(239,68,68,0.4); }
.quick-dot.repair { background: #f59e0b; box-shadow: 0 0 8px rgba(245,158,11,0.4); }
.quick-dot.notice { background: #3b82f6; box-shadow: 0 0 8px rgba(59,130,246,0.4); }
.quick-dot.user { background: #8b5cf6; box-shadow: 0 0 8px rgba(139,92,246,0.4); }

.quick-arrow {
  margin-left: auto;
  font-size: 12px;
  color: #d1d5db;
  transition: all 0.2s;
}
.quick-item:hover .quick-arrow {
  color: #7c3aed;
  transform: translateX(3px);
}
</style>
