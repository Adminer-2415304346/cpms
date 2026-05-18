<template>
  <a-card>
    <div class="toolbar">
      <a-space>
        <a-button type="primary" @click="openAdd"><PlusOutlined /> 新增房间</a-button>
        <a-select v-model:value="bFilter" placeholder="按楼栋筛选" allowClear style="width:160px" @change="fetch">
          <a-select-option v-for="b in buildings" :key="b.buildingId" :value="b.buildingId">{{ b.buildingName }}</a-select-option>
        </a-select>
      </a-space>
    </div>
    <a-table :columns="cols" :dataSource="data" :loading="loading" rowKey="roomId" size="middle">
      <template #bodyCell="{ column, record }">
        <template v-if="column.key === 'building'">{{ record.building?.buildingName }}</template>
        <template v-if="column.key === 'status'">
          <a-tag :color="record.status==='occupied'?'blue':record.status==='vacant'?'green':'orange'">
            {{ {vacant:'空闲',occupied:'已入住',maintenance:'维护中'}[record.status] }}
          </a-tag>
        </template>
        <template v-if="column.key === 'action'">
          <a-space>
            <a @click="openEdit(record)">编辑</a>
            <a-popconfirm title="确定删除？" @confirm="handleDel(record.roomId)"><a class="danger-link">删除</a></a-popconfirm>
          </a-space>
        </template>
      </template>
    </a-table>

    <a-modal v-model:open="open" :title="eid?'编辑房间':'新增房间'" @ok="onSave" :confirmLoading="saving">
      <a-form layout="vertical">
        <a-form-item label="所属楼栋" required>
          <a-select v-model:value="f.buildingId">
            <a-select-option v-for="b in buildings" :key="b.buildingId" :value="b.buildingId">{{ b.buildingName }}</a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item label="单元"><a-input v-model:value="f.unitName" /></a-form-item>
        <a-form-item label="房间号" required><a-input v-model:value="f.roomNumber" /></a-form-item>
        <a-form-item label="面积(㎡)"><a-input-number v-model:value="f.area" :min="0" style="width:100%" /></a-form-item>
        <a-form-item label="户型"><a-input v-model:value="f.roomType" /></a-form-item>
        <a-form-item label="状态">
          <a-select v-model:value="f.status">
            <a-select-option value="vacant">空闲</a-select-option>
            <a-select-option value="occupied">已入住</a-select-option>
            <a-select-option value="maintenance">维护中</a-select-option>
          </a-select>
        </a-form-item>
      </a-form>
    </a-modal>
  </a-card>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { message } from 'ant-design-vue'
import { PlusOutlined } from '@ant-design/icons-vue'
import http from '@/api'

const data = ref([]), buildings = ref([]), loading = ref(false), open = ref(false), saving = ref(false), eid = ref(null), bFilter = ref(null)
const f = reactive({ buildingId: null, unitName: '', roomNumber: '', area: null, roomType: '', status: 'vacant' })
const cols = [
  { title: 'ID', dataIndex: 'roomId', width: 70 },
  { title: '楼栋', key: 'building' },
  { title: '单元', dataIndex: 'unitName' },
  { title: '房间号', dataIndex: 'roomNumber' },
  { title: '面积(㎡)', dataIndex: 'area' },
  { title: '户型', dataIndex: 'roomType' },
  { title: '状态', key: 'status' },
  { title: '操作', key: 'action', width: 120 }
]

const fetch = async () => {
  loading.value = true
  try {
    const [rooms, blds] = await Promise.all([http.get(bFilter.value ? `/rooms?buildingId=${bFilter.value}` : '/rooms'), http.get('/buildings')])
    data.value = rooms; buildings.value = blds
  } catch {}; loading.value = false
}
const openAdd = () => { eid.value = null; Object.assign(f, { buildingId: buildings.value[0]?.buildingId, unitName: '', roomNumber: '', area: null, roomType: '', status: 'vacant' }); open.value = true }
const openEdit = (r) => { eid.value = r.roomId; Object.assign(f, { buildingId: r.building?.buildingId, unitName: r.unitName, roomNumber: r.roomNumber, area: r.area, roomType: r.roomType, status: r.status }); open.value = true }
const onSave = async () => {
  saving.value = true
  try {
    const body = { building: { buildingId: f.buildingId }, unitName: f.unitName, roomNumber: f.roomNumber, area: f.area, roomType: f.roomType, status: f.status }
    if (eid.value) await http.put(`/rooms/${eid.value}`, body)
    else await http.post('/rooms', body)
    message.success('成功'); open.value = false; fetch()
  } catch {}; saving.value = false
}
const handleDel = async (id) => { await http.delete(`/rooms/${id}`); message.success('删除成功'); fetch() }
onMounted(fetch)
</script>

<style scoped>
.toolbar { margin-bottom: 16px; }
.danger-link { color: #ff4d4f; }
</style>
