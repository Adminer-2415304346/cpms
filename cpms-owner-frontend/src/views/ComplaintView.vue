<template>
  <div class="complaint-page">
    <div class="page-header" style="display:flex; justify-content:space-between; align-items:flex-start">
      <div>
        <h2>投诉建议</h2>
        <p>提交投诉或建议，物业将尽快处理</p>
      </div>
      <a-button type="primary" @click="openSubmit">提交投诉/建议</a-button>
    </div>

    <a-card v-for="c in complaints" :key="c.complaintId" style="margin-bottom:12px" size="small">
      <div style="display:flex; justify-content:space-between; align-items:flex-start">
        <div style="flex:1">
          <div style="display:flex; align-items:center; gap:8px; margin-bottom:8px">
            <a-tag :color="c.type === 'complaint' ? 'red' : 'blue'">
              {{ c.type === 'complaint' ? '投诉' : '建议' }}
            </a-tag>
            <a-tag v-if="c.isAnonymous" size="small">匿名</a-tag>
            <a-tag :color="statusTagColor(c.status)" size="small">
              {{ statusLabel(c.status) }}
            </a-tag>
            <span style="font-weight:600">{{ truncate(c.content, 40) }}</span>
          </div>
          <div class="complaint-content" v-if="c.content">{{ c.content }}</div>
          <div class="complaint-reply" v-if="c.reply">
            <span class="reply-label">物业回复：</span>{{ c.reply }}
          </div>
          <div style="font-size:12px; color:#787580; margin-top:8px">
            {{ dayjs(c.createdAt).format('YYYY-MM-DD HH:mm') }}
            <span v-if="c.repliedAt"> · 回复于 {{ dayjs(c.repliedAt).format('YYYY-MM-DD HH:mm') }}</span>
          </div>
        </div>
      </div>
    </a-card>

    <a-empty v-if="complaints.length === 0" description="暂无投诉记录" />

    <!-- 提交 Modal -->
    <a-modal v-model:open="submitModal.open" title="提交投诉/建议" @ok="doSubmit" :confirmLoading="submitModal.loading">
      <a-form layout="vertical">
        <a-form-item label="类型" required>
          <a-radio-group v-model:value="submitModal.type">
            <a-radio value="complaint">投诉</a-radio>
            <a-radio value="suggestion">建议</a-radio>
          </a-radio-group>
        </a-form-item>
        <a-form-item label="内容" required>
          <a-textarea v-model:value="submitModal.content" :rows="5" placeholder="请详细描述..." />
        </a-form-item>
        <a-form-item>
          <a-checkbox v-model:checked="submitModal.isAnonymous">匿名提交</a-checkbox>
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script setup>
import { onMounted, reactive, ref } from 'vue'
import { message } from 'ant-design-vue'
import dayjs from 'dayjs'
import http from '@/api'
import { useUserStore } from '@/stores/user'

const store = useUserStore()
const complaints = ref([])

const submitModal = reactive({
  open: false, type: 'complaint', content: '', isAnonymous: false, loading: false
})

function truncate(s, max) {
  if (!s) return ''
  return s.length > max ? s.slice(0, max) + '...' : s
}

function statusLabel(s) {
  return { pending: '待处理', processing: '处理中', resolved: '已解决' }[s] || s
}
function statusTagColor(s) {
  return { pending: 'default', processing: 'orange', resolved: 'green' }[s] || 'default'
}

async function fetchComplaints() {
  const ownerId = store.ownerId
  if (!ownerId) return
  complaints.value = await http.get(`/complaints?ownerId=${ownerId}`) || []
}

function openSubmit() {
  submitModal.type = 'complaint'
  submitModal.content = ''
  submitModal.isAnonymous = false
  submitModal.open = true
}

async function doSubmit() {
  if (!submitModal.content) {
    message.warning('请输入内容')
    return
  }
  submitModal.loading = true
  try {
    const ownerId = store.ownerId
    await http.post('/complaints', {
      owner: { ownerId },
      type: submitModal.type,
      content: submitModal.content,
      isAnonymous: submitModal.isAnonymous
    })
    message.success('提交成功')
    submitModal.open = false
    await fetchComplaints()
  } catch {
    // error handled by interceptor
  } finally {
    submitModal.loading = false
  }
}

onMounted(fetchComplaints)
</script>

<style scoped>
.complaint-content {
  color: #4b5563;
  margin: 8px 0;
  white-space: pre-wrap;
}
.complaint-reply {
  background: #f5f0ff;
  border-left: 3px solid #7c3aed;
  padding: 10px 14px;
  margin: 8px 0;
  border-radius: 0 4px 4px 0;
  font-size: 13px;
  color: #4b5563;
}
.reply-label {
  font-weight: 600;
  color: #7c3aed;
}
</style>
