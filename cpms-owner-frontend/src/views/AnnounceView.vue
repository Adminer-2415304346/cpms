<template>
  <div class="announce-page">
    <div class="page-header">
      <h2>社区公告</h2>
      <p>了解社区最新动态</p>
    </div>

    <div v-for="(a, i) in announces" :key="a.announcementId" class="announce-card" @click="showDetail(a)">
      <div class="announce-index num-display">{{ String(i + 1).padStart(2, '0') }}</div>
      <div class="announce-main">
        <h4 class="announce-title">{{ a.title }}</h4>
        <p class="announce-excerpt">{{ truncate(a.content, 80) }}</p>
        <span class="announce-time">{{ dayjs(a.publishTime).format('YYYY年M月D日 HH:mm') }}</span>
      </div>
    </div>

    <a-empty v-if="announces.length === 0" description="暂无公告" />

    <a-modal v-model:open="detail.open" :title="detail.title" :footer="null" width="560px">
      <p style="white-space:pre-wrap;line-height:1.8">{{ detail.content }}</p>
      <p style="color:var(--c-muted);font-size:12px;margin-top:16px">
        发布时间：{{ detail.time }}
        <span v-if="detail.publisher"> · {{ detail.publisher }}</span>
      </p>
    </a-modal>
  </div>
</template>

<script setup>
import { onMounted, reactive, ref } from 'vue'
import dayjs from 'dayjs'
import http from '@/api'

const announces = ref([])
const detail = reactive({ open: false, title: '', content: '', time: '', publisher: '' })

function truncate(s, max) {
  if (!s) return ''
  return s.length > max ? s.slice(0, max) + '...' : s
}

function showDetail(a) {
  detail.title = a.title
  detail.content = a.content
  detail.time = dayjs(a.publishTime).format('YYYY-MM-DD HH:mm')
  detail.publisher = a.publisher?.realName || ''
  detail.open = true
}

onMounted(async () => {
  announces.value = await http.get('/announcements') || []
})
</script>

<style scoped>
.announce-card {
  display: flex;
  align-items: flex-start;
  gap: 24px;
  background: var(--c-surface);
  border: 1px solid var(--c-border);
  border-radius: var(--r-lg);
  padding: 24px 28px;
  margin-bottom: 10px;
  cursor: pointer;
  box-shadow: var(--shadow-sm);
  transition: all var(--transition);
}
.announce-card:hover {
  box-shadow: var(--shadow-md);
  border-color: var(--c-muted-light);
}

.announce-index {
  font-size: 22px;
  font-weight: 700;
  color: var(--c-muted-light);
  flex-shrink: 0;
  width: 36px;
}

.announce-main { flex: 1; }
.announce-title {
  margin: 0;
  font-size: 16px;
  font-weight: 600;
  color: var(--c-ink);
}
.announce-excerpt {
  margin: 6px 0;
  color: var(--c-ink-soft);
  font-size: 13px;
  line-height: 1.5;
}
.announce-time {
  font-size: 12px;
  color: var(--c-muted-light);
}
</style>
