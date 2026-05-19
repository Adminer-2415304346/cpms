<template>
  <div class="repair-page">
    <div class="page-header" style="display:flex; justify-content:space-between; align-items:flex-start">
      <div>
        <h2>报修维修</h2>
        <p>提交报修申请，追踪维修进度</p>
      </div>
      <a-button type="primary" @click="openSubmit">提交报修</a-button>
    </div>

    <a-card v-for="r in repairs" :key="r.repairId" style="margin-bottom:12px" size="small">
      <div style="display:flex; justify-content:space-between; align-items:flex-start">
        <div style="flex:1">
          <div style="display:flex; align-items:center; gap:8px; margin-bottom:8px">
            <span style="font-weight:600">{{ r.description }}</span>
            <a-tag :color="urgencyConf(r.urgency).color" size="small">{{ urgencyConf(r.urgency).label }}</a-tag>
            <a-tag :color="statusConf(r.status).color">{{ statusConf(r.status).label }}</a-tag>
          </div>
          <div style="font-size:12px; color:#787580">
            {{ r.room?.building?.buildingName }}
            {{ r.room?.unitName }}
            {{ r.room?.roomNumber }}
            &nbsp;·&nbsp;
            {{ dayjs(r.createdAt).format('YYYY-MM-DD HH:mm') }}
          </div>
          <!-- 进度条 -->
          <div style="margin-top:12px">
            <a-steps :current="stepIndex(r.status)" size="small" style="max-width:500px">
              <a-step title="待处理" />
              <a-step title="已派工" />
              <a-step title="处理中" />
              <a-step title="已完成" />
              <a-step title="已确认" />
            </a-steps>
          </div>
        </div>
        <div>
          <a-button
            v-if="r.status === 'completed'"
            type="primary"
            size="small"
            @click="doConfirm(r)"
          >
            确认完工
          </a-button>
        </div>
      </div>
    </a-card>

    <a-empty v-if="repairs.length === 0" description="暂无报修记录" />

    <!-- 提交报修 Modal -->
    <a-modal v-model:open="submitModal.open" title="提交报修" @ok="doSubmit" :confirmLoading="submitModal.loading">
      <a-form layout="vertical">
        <a-form-item label="报修房产" required>
          <a-select v-model:value="submitModal.roomId" placeholder="选择房产">
            <a-select-option
              v-for="or in myRooms"
              :key="or.room?.roomId"
              :value="or.room?.roomId"
            >
              {{ or.room?.building?.buildingName }} {{ or.room?.unitName }} {{ or.room?.roomNumber }}
            </a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item label="紧急程度" required>
          <a-select v-model:value="submitModal.urgency" style="width:100%">
            <a-select-option value="low">低</a-select-option>
            <a-select-option value="medium">中</a-select-option>
            <a-select-option value="high">高</a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item label="问题描述" required>
          <a-textarea v-model:value="submitModal.description" :rows="4" placeholder="请详细描述问题..." />
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
const repairs = ref([])
const myRooms = ref([])

const submitModal = reactive({ open: false, roomId: undefined, urgency: 'low', description: '', loading: false })

const urgencyConf = (u) => ({
  low: { label: '低', color: 'green' },
  medium: { label: '中', color: 'orange' },
  high: { label: '高', color: 'red' }
}[u] || { label: u, color: 'default' })

const statusConf = (s) => ({
  pending: { label: '待处理', color: 'default' },
  assigned: { label: '已派工', color: 'blue' },
  in_progress: { label: '处理中', color: 'orange' },
  completed: { label: '已完成', color: 'green' },
  confirmed: { label: '已确认', color: 'purple' }
}[s] || { label: s, color: 'default' })

const stepIndex = (s) => ['pending','assigned','in_progress','completed','confirmed'].indexOf(s)

async function fetchMyRooms() {
  const ownerId = store.ownerId
  if (!ownerId) return
  myRooms.value = await http.get(`/owner-rooms/by-owner/${ownerId}`) || []
}

async function fetchRepairs() {
  const ownerId = store.ownerId
  if (!ownerId) return
  repairs.value = await http.get(`/repairs?ownerId=${ownerId}`) || []
}

function openSubmit() {
  if (myRooms.value.length === 0) {
    message.warning('您还没有关联的房产')
    return
  }
  submitModal.roomId = myRooms.value[0]?.room?.roomId
  submitModal.urgency = 'low'
  submitModal.description = ''
  submitModal.open = true
}

async function doSubmit() {
  if (!submitModal.roomId || !submitModal.description) {
    message.warning('请完整填写信息')
    return
  }
  submitModal.loading = true
  try {
    const ownerId = store.ownerId
    await http.post('/repairs', {
      owner: { ownerId },
      room: { roomId: submitModal.roomId },
      urgency: submitModal.urgency,
      description: submitModal.description
    })
    message.success('报修已提交')
    submitModal.open = false
    await fetchRepairs()
  } catch {
    // error handled by interceptor
  } finally {
    submitModal.loading = false
  }
}

async function doConfirm(repair) {
  try {
    await http.put(`/repairs/${repair.repairId}/confirm`)
    message.success('已确认完工')
    await fetchRepairs()
  } catch {
    // error handled by interceptor
  }
}

onMounted(async () => {
  await fetchMyRooms()
  await fetchRepairs()
})
</script>
