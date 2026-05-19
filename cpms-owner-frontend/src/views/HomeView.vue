<template>
  <div class="home-page">
    <!-- 欢迎横幅 -->
    <div class="welcome-banner">
      <div>
        <p class="welcome-greeting">
          <span class="welcome-emoji">{{ greetingEmoji }}</span>
          {{ greetingText }}，{{ store.realName || store.username }}
        </p>
        <p class="welcome-date">{{ todayDate }}</p>
      </div>
      <div style="text-align:right">
        <a-tag v-if="store.role === 'owner'" color="#7c3aed" style="font-size:13px">业主</a-tag>
      </div>
    </div>

    <!-- 统计卡片 -->
    <a-row :gutter="24" style="margin-bottom:24px">
      <a-col :span="8">
        <a-card class="stat-card-card">
          <div class="stat-card">
            <div class="stat-label">待缴账单</div>
            <div class="stat-value" :class="{ 'stat-highlight': stats.unpaidAmount > 0 }">
              <span class="stat-currency">¥</span>{{ formatAmount(stats.unpaidAmount) }}
            </div>
          </div>
        </a-card>
      </a-col>
      <a-col :span="8">
        <a-card class="stat-card-card">
          <div class="stat-card">
            <div class="stat-label">进行中报修</div>
            <div class="stat-value">{{ stats.activeRepairs }}</div>
          </div>
        </a-card>
      </a-col>
      <a-col :span="8">
        <a-card class="stat-card-card">
          <div class="stat-card">
            <div class="stat-label">社区公告</div>
            <div class="stat-value" style="font-size:18px;font-weight:500">
              {{ stats.latestAnnounce || '暂无' }}
            </div>
          </div>
        </a-card>
      </a-col>
    </a-row>

    <!-- 最近报修 + 最近公告 -->
    <a-row :gutter="24">
      <a-col :span="12">
        <a-card title="最近报修" size="small">
          <template #extra>
            <router-link to="/repairs">查看全部</router-link>
          </template>
          <div v-if="recentRepairs.length === 0" class="empty-hint-card">暂无报修记录</div>
          <div v-for="r in recentRepairs" :key="r.repairId" class="list-item" @click="router.push('/repairs')">
            <div class="list-item-main">
              <span class="list-item-title">{{ r.description }}</span>
              <a-tag :color="urgencyColor(r.urgency)" size="small">{{ urgencyLabel(r.urgency) }}</a-tag>
            </div>
            <div class="list-item-meta">
              <a-tag :color="statusColor(r.status)">{{ r.status }}</a-tag>
              <span>{{ dayjs(r.createdAt).format('MM-DD HH:mm') }}</span>
            </div>
          </div>
        </a-card>
      </a-col>
      <a-col :span="12">
        <a-card title="最新公告" size="small">
          <template #extra>
            <router-link to="/announces">查看全部</router-link>
          </template>
          <div v-if="recentAnnounces.length === 0" class="empty-hint-card">暂无公告</div>
          <div v-for="a in recentAnnounces" :key="a.announcementId" class="list-item" @click="showAnnounceDetail(a)">
            <div class="list-item-main">
              <span class="list-item-title">{{ a.title }}</span>
            </div>
            <div class="list-item-meta">
              <span>{{ dayjs(a.publishTime).format('MM-DD HH:mm') }}</span>
            </div>
          </div>
        </a-card>
      </a-col>
    </a-row>

    <!-- 公告详情 Modal -->
    <a-modal v-model:open="announceModal.open" :title="announceModal.title" :footer="null">
      <p>{{ announceModal.content }}</p>
      <p style="color:#787580;font-size:12px">
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

const stats = reactive({
  unpaidAmount: 0,
  activeRepairs: 0,
  latestAnnounce: ''
})

const recentRepairs = ref([])
const recentAnnounces = ref([])

const announceModal = reactive({ open: false, title: '', content: '', time: '' })

// 问候语
const hour = new Date().getHours()
const greetingEmoji = computed(() => {
  if (hour < 6) return ''
  if (hour < 9) return ''
  if (hour < 12) return ''
  if (hour < 14) return ''
  if (hour < 18) return ''
  return ''
})
const greetingText = computed(() => {
  if (hour < 6) return '夜深了'
  if (hour < 9) return '早上好'
  if (hour < 12) return '上午好'
  if (hour < 14) return '中午好'
  if (hour < 18) return '下午好'
  return '晚上好'
})

const todayDate = computed(() => dayjs().format('YYYY年M月D日 星期dd'))

const urgencyMap = { low: { label: '低', color: 'green' }, medium: { label: '中', color: 'orange' }, high: { label: '高', color: 'red' } }
function urgencyLabel(u) { return urgencyMap[u]?.label || u }
function urgencyColor(u) { return urgencyMap[u]?.color || 'default' }

function statusColor(status) {
  const m = { pending: 'default', assigned: 'blue', in_progress: 'orange', completed: 'green', confirmed: 'purple' }
  return m[status] || 'default'
}

function formatAmount(v) {
  return v ? v.toFixed(2) : '0.00'
}

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
    // 获取业主房间
    const rooms = await http.get(`/owner-rooms/by-owner/${ownerId}`) || []

    // 聚合未缴账单
    let unpaidAmount = 0
    for (const or of rooms) {
      const bills = await http.get(`/bills?roomId=${or.room?.roomId}`) || []
      for (const b of bills) {
        if (b.status === 'unpaid' || b.status === 'overdue') {
          unpaidAmount += b.amount
        }
      }
    }
    stats.unpaidAmount = unpaidAmount

    // 报修
    const repairs = await http.get(`/repairs?ownerId=${ownerId}`) || []
    stats.activeRepairs = repairs.filter(r => !['completed', 'confirmed'].includes(r.status)).length
    recentRepairs.value = repairs.slice(0, 3)

    // 公告
    const announces = await http.get('/announcements') || []
    stats.latestAnnounce = announces.length > 0 ? announces[0].title : ''
    recentAnnounces.value = announces.slice(0, 3)
  } catch {
    // silent
  }
})
</script>

<style scoped>
.stat-card-card {
  border-radius: 12px;
}
.empty-hint-card {
  text-align: center;
  color: #c4c0d0;
  padding: 24px 0;
  font-size: 13px;
}
.list-item {
  padding: 12px 0;
  border-bottom: 1px solid #f0ede8;
  cursor: pointer;
  transition: background 0.15s;
}
.list-item:last-child { border-bottom: none; }
.list-item:hover { background: #faf9f7; margin: 0 -16px; padding-left: 16px; padding-right: 16px; border-radius: 6px; }
.list-item-main {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 4px;
}
.list-item-title {
  font-weight: 500;
  flex: 1;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.list-item-meta {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 12px;
  color: #787580;
}
</style>
