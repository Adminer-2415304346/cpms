<template>
  <div class="dashboard">
    <div class="welcome-bar">
      <div>
        <h2>{{ timeGreeting }}，{{ userStore.realName || userStore.username }}</h2>
        <p>今天是 {{ today }}</p>
      </div>
      <span class="date-badge">{{ dayjs().format('M.DD ddd') }}</span>
    </div>

    <div class="stat-row">
      <div class="stat-item" v-for="(card, i) in statCards" :key="card.title">
        <span class="stat-num">{{ animatedValues[i] }}</span>
        <span class="stat-unit">{{ card.title }}</span>
      </div>
    </div>

    <a-row :gutter="[16, 16]" style="margin-top: 20px">
      <a-col :xs="24" :lg="12">
        <div class="info-card">
          <h4>系统概况</h4>
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
          <h4>快捷入口</h4>
          <div class="quick-links">
            <a v-if="isAdmin||isStaff" @click="$router.push('/bills?unpaid=true')" class="quick-item">
              <DollarOutlined />
              <span>查看欠费账单</span>
              <RightOutlined class="arrow" />
            </a>
            <a @click="$router.push('/repairs')" class="quick-item">
              <ToolOutlined />
              <span>查看报修工单</span>
              <RightOutlined class="arrow" />
            </a>
            <a @click="$router.push('/announcements')" class="quick-item">
              <SoundOutlined />
              <span>查看社区公告</span>
              <RightOutlined class="arrow" />
            </a>
            <a v-if="isAdmin" @click="$router.push('/users')" class="quick-item">
              <TeamOutlined />
              <span>管理用户账号</span>
              <RightOutlined class="arrow" />
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
import http from '@/api'
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

const targets = ref([0, 0, 0, 0])
const animatedValues = ref([0, 0, 0, 0])

const animateCount = (index, target, duration = 600) => {
  const start = performance.now()
  const tick = (now) => {
    const elapsed = now - start
    const progress = Math.min(elapsed / duration, 1)
    const eased = 1 - Math.pow(1 - progress, 3)
    animatedValues.value[index] = Math.round(eased * target)
    if (progress < 1) requestAnimationFrame(tick)
  }
  requestAnimationFrame(tick)
}

onMounted(async () => {
  try {
    const { buildings, owners, pendingRepairs, announcements } = await http.get('/dashboard/stats')
    targets.value = [buildings, owners, pendingRepairs, announcements]
  } catch {
    // fallback: keep zero
  }
  targets.value.forEach((target, i) => {
    setTimeout(() => animateCount(i, target), 100 + i * 60)
  })
})

const statCards = computed(() => [
  { title: '楼栋', icon: HomeOutlined },
  { title: '业主', icon: TeamOutlined },
  { title: '待处理报修', icon: ToolOutlined },
  { title: '公告', icon: SoundOutlined },
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
/* ====== 欢迎栏 ====== */
.welcome-bar {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 24px;
}

.welcome-bar h2 {
  margin: 0 0 4px;
  font-size: 20px;
  font-weight: 600;
  color: #1e1b2e;
}

.welcome-bar p {
  margin: 0;
  font-size: 13px;
  color: #8e8a9e;
}

.date-badge {
  font-size: 13px;
  color: #8e8a9e;
  padding: 4px 12px;
  border-radius: 6px;
  border: 1px solid #e8e5f0;
  font-variant-numeric: tabular-nums;
}

/* ====== 统计行 ====== */
.stat-row {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 4px;
}

.stat-item {
  text-align: center;
  padding: 24px 16px 20px;
  background: #fefeff;
  border-radius: 10px;
  border: 1px solid #e8e5f0;
  transition: border-color 0.15s ease;
}

.stat-item:hover {
  border-color: #c4b5fd;
}

.stat-num {
  display: block;
  font-size: 32px;
  font-weight: 700;
  color: #1e1b2e;
  line-height: 1;
  margin-bottom: 6px;
  font-variant-numeric: tabular-nums;
}

.stat-unit {
  font-size: 12px;
  color: #8e8a9e;
  font-weight: 500;
}

@media (max-width: 768px) {
  .stat-row {
    grid-template-columns: repeat(2, 1fr);
  }
}

/* ====== 信息卡片 ====== */
.info-card {
  background: #fefeff;
  border-radius: 12px;
  border: 1px solid #e8e5f0;
  padding: 20px 24px;
  transition: border-color 0.15s ease;
}

.info-card:hover {
  border-color: #c4b5fd;
}

.info-card h4 {
  margin: 0 0 16px;
  font-size: 14px;
  font-weight: 600;
  color: #1e1b2e;
}

.info-body {
  display: flex;
  flex-direction: column;
}

.info-row {
  display: flex;
  justify-content: space-between;
  padding: 9px 0;
  border-bottom: 1px solid #f3f2f7;
}

.info-row:last-child {
  border-bottom: none;
}

.info-label {
  font-size: 13px;
  color: #8e8a9e;
}

.info-value {
  font-size: 13px;
  color: #3d3850;
  font-weight: 500;
}

/* ====== 快捷入口 ====== */
.quick-links {
  display: flex;
  flex-direction: column;
}

.quick-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 0;
  border-bottom: 1px solid #f3f2f7;
  color: #3d3850;
  font-size: 14px;
  cursor: pointer;
  transition: color 0.15s ease;
}

.quick-item:last-child {
  border-bottom: none;
}

.quick-item:hover {
  color: #6d28d9;
}

.quick-item .arrow {
  margin-left: auto;
  font-size: 12px;
  color: #c4c0d0;
  transition: color 0.15s ease;
}

.quick-item:hover .arrow {
  color: #6d28d9;
}
</style>
