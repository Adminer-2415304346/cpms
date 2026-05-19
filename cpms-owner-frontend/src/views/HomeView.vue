<template>
  <div class="home-page">
    <!-- 欢迎区 -->
    <section class="welcome-section">
      <p class="welcome-greeting">
        {{ greetingText }}，{{ store.realName || store.username }}
      </p>
      <p class="welcome-date">{{ todayDate }}</p>
    </section>

    <!-- 统计横条 -->
    <a-row :gutter="20" class="stats-row">
      <a-col :span="8">
        <div class="stat-card">
          <p class="stat-label">待缴账单</p>
          <p class="stat-number num-display" :class="{ 'stat-warn': stats.unpaidAmount > 0 }">
            <span class="stat-unit">¥</span>{{ formatAmount(stats.unpaidAmount) }}
          </p>
        </div>
      </a-col>
      <a-col :span="8">
        <div class="stat-card">
          <p class="stat-label">进行中报修</p>
          <p class="stat-number num-display">{{ stats.activeRepairs }}</p>
          <p class="stat-sub">项</p>
        </div>
      </a-col>
      <a-col :span="8">
        <div class="stat-card">
          <p class="stat-label">最新公告</p>
          <p class="stat-announce">{{ stats.latestAnnounce || '暂无' }}</p>
        </div>
      </a-col>
    </a-row>

    <!-- 双栏 -->
    <a-row :gutter="24" class="home-panels">
      <a-col :span="12">
        <div class="panel-card">
          <div class="panel-head">
            <h3>最近报修</h3>
            <router-link to="/repairs" class="panel-link">查看全部</router-link>
          </div>
          <div class="panel-body">
            <div v-if="recentRepairs.length === 0" class="empty-line">暂无报修记录</div>
            <div v-for="r in recentRepairs" :key="r.repairId" class="panel-row" @click="router.push('/repairs')">
              <div class="panel-row-top">
                <span class="panel-row-title">{{ r.description }}</span>
                <span class="urgency-dot" :class="'urgency-' + r.urgency"></span>
              </div>
              <div class="panel-row-meta">
                <a-tag :color="statusColor(r.status)" size="small">{{ r.status }}</a-tag>
                <span>{{ dayjs(r.createdAt).format('MM-DD HH:mm') }}</span>
              </div>
            </div>
          </div>
        </div>
      </a-col>
      <a-col :span="12">
        <div class="panel-card">
          <div class="panel-head">
            <h3>最新公告</h3>
            <router-link to="/announces" class="panel-link">查看全部</router-link>
          </div>
          <div class="panel-body">
            <div v-if="recentAnnounces.length === 0" class="empty-line">暂无公告</div>
            <div v-for="a in recentAnnounces" :key="a.announcementId" class="panel-row" @click="showAnnounceDetail(a)">
              <div class="panel-row-top">
                <span class="panel-row-title">{{ a.title }}</span>
              </div>
              <div class="panel-row-meta">
                <span>{{ dayjs(a.publishTime).format('MM-DD HH:mm') }}</span>
              </div>
            </div>
          </div>
        </div>
      </a-col>
    </a-row>

    <a-modal v-model:open="announceModal.open" :title="announceModal.title" :footer="null">
      <p style="white-space:pre-wrap;line-height:1.8">{{ announceModal.content }}</p>
      <p style="color:var(--c-muted);font-size:12px;margin-top:16px">
        发布时间：{{ announceModal.time }}
      </p>
    </a-modal>
  </div>
</template>

<script setup>
import { computed, onMounted, reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import dayjs from 'dayjs'
import http from '@/api'
import { useUserStore } from '@/stores/user'

const router = useRouter()
const store = useUserStore()

const stats = reactive({ unpaidAmount: 0, activeRepairs: 0, latestAnnounce: '' })
const recentRepairs = ref([])
const recentAnnounces = ref([])
const announceModal = reactive({ open: false, title: '', content: '', time: '' })

const hour = new Date().getHours()
const greetingText = computed(() => {
  if (hour < 6) return '夜深了'
  if (hour < 9) return '早上好'
  if (hour < 12) return '上午好'
  if (hour < 14) return '中午好'
  if (hour < 18) return '下午好'
  return '晚上好'
})
const todayDate = computed(() => dayjs().format('YYYY年M月D日 dddd'))

function statusColor(s) {
  return { pending:'default', assigned:'blue', in_progress:'orange', completed:'green', confirmed:'purple' }[s] || 'default'
}
function formatAmount(v) { return v ? v.toFixed(2) : '0.00' }
function showAnnounceDetail(a) {
  announceModal.open = true
  announceModal.title = a.title
  announceModal.content = a.content
  announceModal.time = dayjs(a.publishTime).format('YYYY-MM-DD HH:mm')
}

onMounted(async () => {
  const ownerId = store.ownerId
  if (!ownerId) return
  try {
    const rooms = await http.get(`/owner-rooms/by-owner/${ownerId}`) || []
    let unpaidAmount = 0
    for (const or of rooms) {
      const bills = await http.get(`/bills?roomId=${or.room?.roomId}`) || []
      for (const b of bills) {
        if (b.status === 'unpaid' || b.status === 'overdue') unpaidAmount += b.amount
      }
    }
    stats.unpaidAmount = unpaidAmount

    const repairs = await http.get(`/repairs?ownerId=${ownerId}`) || []
    stats.activeRepairs = repairs.filter(r => !['completed','confirmed'].includes(r.status)).length
    recentRepairs.value = repairs.slice(0, 3)

    const announces = await http.get('/announcements') || []
    stats.latestAnnounce = announces.length > 0 ? announces[0].title : ''
    recentAnnounces.value = announces.slice(0, 3)
  } catch { /* silent */ }
})
</script>

<style scoped>
/* Welcome */
.welcome-section {
  margin-bottom: 36px;
}
.welcome-greeting {
  font-family: var(--font-display);
  font-size: 34px;
  font-weight: 600;
  color: var(--c-ink);
  margin: 0;
  letter-spacing: -0.6px;
}
.welcome-date {
  margin: 6px 0 0;
  color: var(--c-muted);
  font-size: 14px;
}

/* Stats */
.stats-row { margin-bottom: 36px; }
.stat-card {
  background: var(--c-surface);
  border: 1px solid var(--c-border);
  border-radius: var(--r-lg);
  padding: 24px 28px;
  box-shadow: var(--shadow-sm);
}
.stat-label {
  margin: 0;
  font-size: 13px;
  color: var(--c-muted);
  font-weight: 500;
}
.stat-number {
  margin: 8px 0 0;
  font-size: 38px;
  font-weight: 700;
  color: var(--c-ink);
  line-height: 1.1;
}
.stat-unit {
  font-size: 18px;
  font-weight: 500;
  color: var(--c-muted);
  margin-right: 2px;
  font-family: var(--font-ui);
}
.stat-warn { color: var(--c-copper); }
.stat-announce {
  margin: 8px 0 0;
  font-size: 15px;
  font-weight: 500;
  color: var(--c-ink-soft);
  line-height: 1.5;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.stat-sub {
  margin: 0;
  font-size: 14px;
  color: var(--c-muted);
  font-family: var(--font-display);
}

/* Panels */
.home-panels { margin-bottom: 24px; }

.panel-card {
  background: var(--c-surface);
  border: 1px solid var(--c-border);
  border-radius: var(--r-lg);
  box-shadow: var(--shadow-sm);
  overflow: hidden;
}
.panel-head {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px 24px 0;
}
.panel-head h3 {
  margin: 0;
  font-family: var(--font-display);
  font-size: 17px;
  font-weight: 600;
  color: var(--c-ink);
}
.panel-link {
  font-size: 13px;
  color: var(--c-copper);
  text-decoration: none;
  font-weight: 500;
}
.panel-link:hover { text-decoration: underline; }

.panel-body { padding: 16px 24px 20px; }

.empty-line {
  text-align: center;
  color: var(--c-muted-light);
  padding: 28px 0;
  font-size: 13px;
}

.panel-row {
  padding: 14px 0;
  border-bottom: 1px solid var(--c-border-light);
  cursor: pointer;
  transition: background var(--transition);
}
.panel-row:last-child { border-bottom: none; }
.panel-row:hover {
  margin: 0 -12px;
  padding-left: 12px;
  padding-right: 12px;
  border-radius: 6px;
  background: rgba(193,120,78,.03);
}
.panel-row-top {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 6px;
}
.panel-row-title {
  font-weight: 500;
  flex: 1;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.panel-row-meta {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 12px;
  color: var(--c-muted);
}

.urgency-dot { width: 7px; height: 7px; border-radius: 50%; flex-shrink: 0; }
.urgency-low { background: var(--c-success); }
.urgency-medium { background: var(--c-warn); }
.urgency-high { background: var(--c-danger); }
</style>
