<template>
  <div class="announce-page">
    <div class="page-header">
      <h2>社区公告</h2>
      <p>了解社区最新动态</p>
    </div>

    <a-card v-for="a in announces" :key="a.announcementId" style="margin-bottom:12px" size="small" hoverable @click="showDetail(a)">
      <div style="cursor:pointer">
        <div style="display:flex; justify-content:space-between; align-items:center">
          <h4 style="margin:0; font-size:15px; font-weight:600">{{ a.title }}</h4>
          <span style="font-size:12px; color:#787580">{{ dayjs(a.publishTime).format('YYYY-MM-DD HH:mm') }}</span>
        </div>
        <p style="margin:8px 0 0; color:#6b6778; font-size:13px">{{ truncate(a.content, 100) }}</p>
      </div>
    </a-card>

    <a-empty v-if="announces.length === 0" description="暂无公告" />

    <a-modal v-model:open="detail.open" :title="detail.title" :footer="null" width="600px">
      <p style="white-space:pre-wrap">{{ detail.content }}</p>
      <p style="color:#787580; font-size:12px; margin-top:16px">
        发布时间：{{ detail.time }}
        <span v-if="detail.publisher"> · 发布者：{{ detail.publisher }}</span>
      </p>
    </a-modal>
  </div>
</template>

<script setup>
import { onMounted, reactive, ref } from 'vue'
import dayjs from 'dayjs'
import http from '@/api'
import { useUserStore } from '@/stores/user'

const store = useUserStore()
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
