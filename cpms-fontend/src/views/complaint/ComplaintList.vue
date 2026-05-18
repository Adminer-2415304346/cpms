<template>
  <a-card>
    <div class="toolbar">
      <a-space>
        <a-button type="primary" @click="openAdd" v-if="isOwner"><PlusOutlined /> 提交投诉/建议</a-button>
        <a-select v-model:value="sFilter" placeholder="状态筛选" allowClear style="width:140px" @change="fetch">
          <a-select-option value="pending">待处理</a-select-option>
          <a-select-option value="processing">处理中</a-select-option>
          <a-select-option value="resolved">已解决</a-select-option>
        </a-select>
      </a-space>
    </div>
    <a-table :columns="cols" :dataSource="data" :loading="loading" rowKey="complaintId" size="middle">
      <template #bodyCell="{ column, record }">
        <template v-if="column.key === 'type'"><a-tag :color="record.type==='complaint'?'red':'blue'">{{ record.type==='complaint'?'投诉':'建议' }}</a-tag></template>
        <template v-if="column.key === 'status'">
          <a-tag :color="record.status==='resolved'?'green':record.status==='processing'?'blue':'orange'">{{ {pending:'待处理',processing:'处理中',resolved:'已解决'}[record.status] }}</a-tag>
        </template>
        <template v-if="column.key === 'action'">
          <a-space>
            <a v-if="(isAdmin||isStaff) && record.status!=='resolved'" @click="openReply(record)">回复</a>
            <a @click="showDetail(record)">详情</a>
            <a-popconfirm v-if="isAdmin||isStaff" title="确定删除？" @confirm="handleDel(record.complaintId)"><a class="danger-link">删除</a></a-popconfirm>
          </a-space>
        </template>
      </template>
    </a-table>

    <a-modal v-model:open="open" title="提交投诉/建议" @ok="onSave" :confirmLoading="saving">
      <a-form layout="vertical">
        <a-form-item label="类型"><a-radio-group v-model:value="f.type"><a-radio value="complaint">投诉</a-radio><a-radio value="suggestion">建议</a-radio></a-radio-group></a-form-item>
        <a-form-item label="内容" required><a-textarea v-model:value="f.content" :rows="4" /></a-form-item>
        <a-form-item label="匿名提交"><a-switch v-model:checked="f.isAnonymous" /></a-form-item>
      </a-form>
    </a-modal>

    <a-modal v-model:open="replyOpen" title="回复投诉/建议" @ok="doReply" :confirmLoading="replying">
      <a-descriptions :column="1" size="small">
        <a-descriptions-item label="类型">{{ replyItem.type === 'complaint' ? '投诉' : '建议' }}</a-descriptions-item>
        <a-descriptions-item label="内容">{{ replyItem.content }}</a-descriptions-item>
      </a-descriptions>
      <a-form-item label="回复内容" style="margin-top:12px"><a-textarea v-model:value="replyText" :rows="3" /></a-form-item>
    </a-modal>
  </a-card>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { message } from 'ant-design-vue'
import { PlusOutlined } from '@ant-design/icons-vue'
import http from '@/api'
import { useUserStore } from '@/stores/user'

const store = useUserStore()
const isAdmin = computed(() => store.role === 'admin')
const isStaff = computed(() => store.role === 'staff')
const isOwner = computed(() => store.role === 'owner')

const data = ref([]), loading = ref(false), open = ref(false), saving = ref(false), sFilter = ref(null)
const replyOpen = ref(false), replying = ref(false), replyText = ref(''), replyItem = ref({})
const f = reactive({ type: 'complaint', content: '', isAnonymous: false })

const cols = [
  { title: 'ID', dataIndex: 'complaintId', width: 70 },
  { title: '类型', key: 'type', width: 80 },
  { title: '内容', dataIndex: 'content', ellipsis: true },
  { title: '匿名', dataIndex: 'isAnonymous', width: 60 },
  { title: '状态', key: 'status', width: 90 },
  { title: '回复', dataIndex: 'reply', ellipsis: true },
  { title: '操作', key: 'action', width: 160 }
]

const fetch = async () => {
  loading.value = true
  try {
    let url = '/complaints'; if (sFilter.value) url += `?status=${sFilter.value}`
    data.value = await http.get(url)
  } catch {}; loading.value = false
}
const openAdd = () => { Object.assign(f, { type: 'complaint', content: '', isAnonymous: false }); open.value = true }
const onSave = async () => {
  saving.value = true
  try {
    const owner = await http.get(`/owners/by-user/${store.userId}`)
    await http.post('/complaints', { owner: { ownerId: owner.ownerId }, type: f.type, content: f.content, isAnonymous: f.isAnonymous })
    message.success('提交成功'); open.value = false; fetch()
  } catch {}; saving.value = false
}
const openReply = (r) => { replyItem.value = r; replyText.value = ''; replyOpen.value = true }
const doReply = async () => {
  replying.value = true
  try { await http.put(`/complaints/${replyItem.value.complaintId}/reply`, { reply: replyText.value }); message.success('回复成功'); replyOpen.value = false; fetch() } catch {}
  replying.value = false
}
const showDetail = (r) => message.info(`${r.type==='complaint'?'投诉':'建议'}: ${r.content}${r.reply ? '\n回复: '+r.reply : ''}`)
const handleDel = async (id) => { await http.delete(`/complaints/${id}`); message.success('删除成功'); fetch() }
onMounted(fetch)
</script>

<style scoped>
.toolbar { margin-bottom: 16px; }
.danger-link { color: #ff4d4f; }
</style>
