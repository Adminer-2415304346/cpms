<template>
  <a-card>
    <div class="toolbar">
      <a-space>
        <a-button type="primary" @click="openAdd" v-if="isOwner"><PlusOutlined /> 提交报修</a-button>
        <a-select v-model:value="sFilter" placeholder="状态筛选" allowClear style="width:140px" @change="fetch">
          <a-select-option value="pending">待处理</a-select-option>
          <a-select-option value="assigned">已派工</a-select-option>
          <a-select-option value="in_progress">处理中</a-select-option>
          <a-select-option value="completed">已完成</a-select-option>
          <a-select-option value="confirmed">已确认</a-select-option>
        </a-select>
      </a-space>
    </div>
    <a-table :columns="cols" :dataSource="data" :loading="loading" rowKey="repairId" size="middle">
      <template #bodyCell="{ column, record }">
        <template v-if="column.key === 'room'">{{ record.room?.building?.buildingName }} {{ record.room?.roomNumber }}</template>
        <template v-if="column.key === 'owner'">{{ record.owner?.name }}</template>
        <template v-if="column.key === 'status'">
          <a-tag :color="statusColor(record.status)">{{ statusLabel(record.status) }}</a-tag>
        </template>
        <template v-if="column.key === 'urgency'">
          <a-tag :color="record.urgency==='high'?'red':record.urgency==='medium'?'orange':'blue'">
            {{ {high:'紧急',medium:'一般',low:'不急'}[record.urgency] }}
          </a-tag>
        </template>
        <template v-if="column.key === 'action'">
          <a-space>
            <a v-if="isAdmin||isStaff" @click="showDetail(record)">详情</a>
            <a v-if="(isAdmin||isStaff) && record.status==='pending'" @click="doAssign(record)">派工</a>
            <a v-if="(isAdmin||isStaff) && record.status==='assigned'" @click="doStart(record)">开始处理</a>
            <a v-if="(isAdmin||isStaff) && record.status==='in_progress'" @click="doComplete(record)">完成</a>
            <a v-if="isOwner && record.status==='completed'" @click="doConfirm(record)">确认</a>
          </a-space>
        </template>
      </template>
    </a-table>

    <a-modal v-model:open="open" title="提交报修" @ok="onSave" :confirmLoading="saving">
      <a-form layout="vertical">
        <a-form-item label="报修房间" required>
          <a-select v-model:value="f.roomId">
            <a-select-option v-for="r in myRooms" :key="r.roomId" :value="r.roomId">{{ r.buildingName }} {{ r.roomNumber }}</a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item label="紧急程度"><a-select v-model:value="f.urgency">
          <a-select-option value="low">不急</a-select-option>
          <a-select-option value="medium">一般</a-select-option>
          <a-select-option value="high">紧急</a-select-option>
        </a-select></a-form-item>
        <a-form-item label="问题描述" required><a-textarea v-model:value="f.description" :rows="3" /></a-form-item>
      </a-form>
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

const data = ref([]), myRooms = ref([]), loading = ref(false), open = ref(false), saving = ref(false), sFilter = ref(null)
const f = reactive({ roomId: null, urgency: 'low', description: '' })

const cols = [
  { title: 'ID', dataIndex: 'repairId', width: 70 },
  { title: '业主', key: 'owner' },
  { title: '房间', key: 'room' },
  { title: '问题描述', dataIndex: 'description', ellipsis: true },
  { title: '紧急', key: 'urgency', width: 80 },
  { title: '状态', key: 'status', width: 100 },
  { title: '操作', key: 'action', width: 180 }
]

const statusColor = (s) => ({ pending:'orange', assigned:'blue', in_progress:'cyan', completed:'green', confirmed:'purple' }[s])
const statusLabel = (s) => ({ pending:'待处理', assigned:'已派工', in_progress:'处理中', completed:'已完成', confirmed:'已确认' }[s])

const fetch = async () => {
  loading.value = true
  try {
    let url = '/repairs'
    if (sFilter.value) {
      url += `?status=${sFilter.value}`
    } else if (isOwner.value) {
      const owner = await http.get(`/owners/by-user/${store.userId}`)
      if (owner) url += `?ownerId=${owner.ownerId}`
    }
    data.value = await http.get(url)
  } catch {}; loading.value = false
}

const openAdd = async () => {
  try {
    if (isOwner.value) {
      const owner = await http.get(`/owners/by-user/${store.userId}`)
      const rooms = await http.get(`/owner-rooms/by-owner/${owner.ownerId}`)
      myRooms.value = rooms.map(r => ({ roomId: r.room.roomId, buildingName: r.room.building?.buildingName, roomNumber: r.room.roomNumber }))
    }
  } catch {}
  Object.assign(f, { roomId: myRooms.value[0]?.roomId, urgency: 'low', description: '' })
  open.value = true
}

const onSave = async () => {
  saving.value = true
  try {
    const owner = await http.get(`/owners/by-user/${store.userId}`)
    await http.post('/repairs', {
      owner: { ownerId: owner.ownerId },
      room: { roomId: f.roomId },
      description: f.description,
      urgency: f.urgency
    })
    message.success('报修已提交'); open.value = false; fetch()
  } catch {}; saving.value = false
}

const showDetail = (r) => {
  const s = statusLabel(r.status)
  message.info(`${r.description}\n状态: ${s}\n时间: ${r.createdAt}`)
}
const doAssign = async (r) => { await http.put(`/repairs/${r.repairId}/assign`, { staffId: store.userId }); message.success('派工成功'); fetch() }
const doStart = async (r) => { await http.put(`/repairs/${r.repairId}/start`); message.success('开始处理'); fetch() }
const doComplete = async (r) => { await http.put(`/repairs/${r.repairId}/complete`); message.success('标记完成'); fetch() }
const doConfirm = async (r) => { await http.put(`/repairs/${r.repairId}/confirm`); message.success('已确认完工'); fetch() }
onMounted(fetch)
</script>

<style scoped>
.toolbar { margin-bottom: 16px; }
</style>
