<template>
  <div class="complaint-page">
    <div class="page-header" style="display:flex;justify-content:space-between;align-items:flex-start">
      <div>
        <h2>投诉建议</h2>
        <p>提交投诉或建议，物业将尽快处理</p>
      </div>
      <a-button type="primary" @click="openSubmit">提交投诉/建议</a-button>
    </div>

    <div v-for="c in complaints" :key="c.complaintId" class="complaint-card">
      <div class="complaint-header">
        <a-tag :color="c.type === 'complaint' ? 'red' : 'blue'" size="small">
          {{ c.type === 'complaint' ? '投诉' : '建议' }}
        </a-tag>
        <a-tag v-if="c.isAnonymous" size="small" style="color:var(--c-muted)">匿名</a-tag>
        <a-tag :color="stsColor(c.status)" size="small">{{ stsLabel(c.status) }}</a-tag>
        <span class="complaint-time">{{ dayjs(c.createdAt).format('YYYY-MM-DD HH:mm') }}</span>
      </div>
      <p class="complaint-body">{{ c.content }}</p>
      <div v-if="c.reply" class="complaint-reply">
        <span class="reply-label">物业回复</span>
        <p class="reply-text">{{ c.reply }}</p>
        <span class="reply-time" v-if="c.repliedAt">{{ dayjs(c.repliedAt).format('YYYY-MM-DD HH:mm') }}</span>
      </div>
    </div>

    <a-empty v-if="complaints.length === 0" description="暂无投诉记录" />

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
const submitModal = reactive({ open: false, type: 'complaint', content: '', isAnonymous: false, loading: false })

const stsLabel = (s) => ({ pending:'待处理', processing:'处理中', resolved:'已解决' }[s] || s)
const stsColor = (s) => ({ pending:'default', processing:'orange', resolved:'green' }[s] || 'default')

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
  if (!submitModal.content) { message.warning('请输入内容'); return }
  submitModal.loading = true
  try {
    await http.post('/complaints', {
      owner: { ownerId: store.ownerId },
      type: submitModal.type,
      content: submitModal.content,
      isAnonymous: submitModal.isAnonymous
    })
    message.success('提交成功')
    submitModal.open = false
    await fetchComplaints()
  } catch { /* interceptor */ }
  finally { submitModal.loading = false }
}

onMounted(fetchComplaints)
</script>

<style scoped>
.complaint-card {
  background: var(--c-surface);
  border: 1px solid var(--c-border);
  border-radius: var(--r-lg);
  padding: 24px;
  margin-bottom: 14px;
  box-shadow: var(--shadow-sm);
  transition: box-shadow var(--transition);
}
.complaint-card:hover { box-shadow: var(--shadow-md); }

.complaint-header {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 10px;
}
.complaint-time { font-size: 12px; color: var(--c-muted); margin-left: auto; }

.complaint-body {
  margin: 0 0 0;
  color: var(--c-ink-soft);
  line-height: 1.7;
  white-space: pre-wrap;
}

.complaint-reply {
  margin-top: 14px;
  background: var(--c-ivory-deep);
  border-left: 3px solid var(--c-copper);
  padding: 14px 16px;
  border-radius: 0 6px 6px 0;
}
.reply-label {
  font-size: 12px;
  font-weight: 600;
  color: var(--c-copper);
  text-transform: uppercase;
  letter-spacing: 0.5px;
}
.reply-text {
  margin: 6px 0 4px;
  color: var(--c-ink-soft);
  font-size: 14px;
  line-height: 1.6;
}
.reply-time { font-size: 11px; color: var(--c-muted-light); }
</style>
