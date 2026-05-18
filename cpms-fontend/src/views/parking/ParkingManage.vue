<template>
  <a-row :gutter="16">
    <a-col :span="12">
      <a-card title="停车位管理">
        <template #extra><a-button type="link" @click="openAddSpot"><PlusOutlined /></a-button></template>
        <a-table :columns="spotCols" :dataSource="spots" :loading="sLoading" rowKey="spotId" size="small" :pagination="false">
          <template #bodyCell="{ column, record }">
            <template v-if="column.key === 'status'">
              <a-tag :color="record.status==='available'?'green':'red'">{{ record.status==='available'?'空闲':'已占用' }}</a-tag>
            </template>
            <template v-if="column.key === 'action'">
              <a-space>
                <a @click="openEditSpot(record)">编辑</a>
                <a-popconfirm title="确定删除?" @confirm="delSpot(record.spotId)"><a class="danger-link">删除</a></a-popconfirm>
              </a-space>
            </template>
          </template>
        </a-table>
      </a-card>
    </a-col>
    <a-col :span="12">
      <a-card title="车辆管理">
        <template #extra><a-button type="link" @click="openAddVehicle"><PlusOutlined /></a-button></template>
        <a-table :columns="vCols" :dataSource="vehicles" :loading="vLoading" rowKey="vehicleId" size="small" :pagination="false">
          <template #bodyCell="{ column, record }">
            <template v-if="column.key === 'owner'">{{ record.owner?.name }}</template>
            <template v-if="column.key === 'spot'">{{ record.spot?.spotCode || '未分配' }}</template>
            <template v-if="column.key === 'action'">
              <a-space>
                <a @click="openEditVehicle(record)">编辑</a>
                <a-popconfirm title="确定删除?" @confirm="delVehicle(record.vehicleId)"><a class="danger-link">删除</a></a-popconfirm>
              </a-space>
            </template>
          </template>
        </a-table>
      </a-card>
    </a-col>
  </a-row>

  <a-modal v-model:open="spotOpen" :title="spotEid?'编辑':'新增'" @ok="saveSpot" :confirmLoading="saving">
    <a-form layout="vertical">
      <a-form-item label="编号" required><a-input v-model:value="sf.spotCode" /></a-form-item>
      <a-form-item label="位置"><a-input v-model:value="sf.location" /></a-form-item>
      <a-form-item label="类型"><a-input v-model:value="sf.type" /></a-form-item>
    </a-form>
  </a-modal>

  <a-modal v-model:open="vOpen" :title="vEid?'编辑':'登记车辆'" @ok="saveVehicle" :confirmLoading="saving">
    <a-form layout="vertical">
      <a-form-item label="车主" required><a-select v-model:value="vf.ownerId"><a-select-option v-for="o in owners" :key="o.ownerId" :value="o.ownerId">{{ o.name }}</a-select-option></a-select></a-form-item>
      <a-form-item label="车牌号" required><a-input v-model:value="vf.plateNumber" /></a-form-item>
      <a-form-item label="车型"><a-input v-model:value="vf.vehicleType" /></a-form-item>
      <a-form-item label="颜色"><a-input v-model:value="vf.color" /></a-form-item>
      <a-form-item label="绑定车位"><a-select v-model:value="vf.spotId" allowClear><a-select-option v-for="s in availSpots" :key="s.spotId" :value="s.spotId">{{ s.spotCode }}</a-select-option></a-select></a-form-item>
    </a-form>
  </a-modal>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { message } from 'ant-design-vue'
import { PlusOutlined } from '@ant-design/icons-vue'
import http from '@/api'

const spots = ref([]), vehicles = ref([]), owners = ref([]), availSpots = ref([])
const sLoading = ref(false), vLoading = ref(false), spotOpen = ref(false), vOpen = ref(false), saving = ref(false)
const spotEid = ref(null), vEid = ref(null)

const sf = reactive({ spotCode: '', location: '', type: '' })
const vf = reactive({ ownerId: null, plateNumber: '', vehicleType: '', color: '', spotId: null })

const spotCols = [
  { title: '编号', dataIndex: 'spotCode' }, { title: '位置', dataIndex: 'location' }, { title: '类型', dataIndex: 'type' },
  { title: '状态', key: 'status' }, { title: '操作', key: 'action', width: 100 }
]
const vCols = [
  { title: '车主', key: 'owner' }, { title: '车牌号', dataIndex: 'plateNumber' }, { title: '车位', key: 'spot' },
  { title: '操作', key: 'action', width: 100 }
]

const fetch = async () => {
  sLoading.value = vLoading.value = true
  try {
    const [s, v] = await Promise.all([http.get('/parking/spots'), http.get('/parking/vehicles')])
    spots.value = s; vehicles.value = v
  } catch {}; sLoading.value = vLoading.value = false
}

const openAddSpot = () => { spotEid.value = null; Object.assign(sf, { spotCode: '', location: '', type: '' }); spotOpen.value = true }
const openEditSpot = (r) => { spotEid.value = r.spotId; Object.assign(sf, r); spotOpen.value = true }
const saveSpot = async () => {
  saving.value = true
  try {
    if (spotEid.value) await http.put(`/parking/spots/${spotEid.value}`, { ...sf })
    else await http.post('/parking/spots', { ...sf })
    message.success('成功'); spotOpen.value = false; fetch()
  } catch {}; saving.value = false
}
const delSpot = async (id) => { await http.delete(`/parking/spots/${id}`); message.success('删除成功'); fetch() }

const openAddVehicle = async () => {
  vEid.value = null
  try { [owners.value, availSpots.value] = await Promise.all([http.get('/owners'), http.get('/parking/spots?available=true')]) } catch {}
  Object.assign(vf, { ownerId: owners.value[0]?.ownerId, plateNumber: '', vehicleType: '', color: '', spotId: null })
  vOpen.value = true
}
const openEditVehicle = async (r) => {
  vEid.value = r.vehicleId
  try { [owners.value, availSpots.value] = await Promise.all([http.get('/owners'), http.get('/parking/spots?available=true')]) } catch {}
  Object.assign(vf, { ownerId: r.owner?.ownerId, plateNumber: r.plateNumber, vehicleType: r.vehicleType, color: r.color, spotId: r.spot?.spotId })
  vOpen.value = true
}
const saveVehicle = async () => {
  saving.value = true
  try {
    const body = { owner: { ownerId: vf.ownerId }, plateNumber: vf.plateNumber, vehicleType: vf.vehicleType, color: vf.color, spot: vf.spotId ? { spotId: vf.spotId } : null }
    if (vEid.value) await http.put(`/parking/vehicles/${vEid.value}`, body)
    else await http.post('/parking/vehicles', body)
    message.success('成功'); vOpen.value = false; fetch()
  } catch {}; saving.value = false
}
const delVehicle = async (id) => { await http.delete(`/parking/vehicles/${id}`); message.success('删除成功'); fetch() }
onMounted(fetch)
</script>

<style scoped>
.danger-link { color: #ff4d4f; }
</style>
