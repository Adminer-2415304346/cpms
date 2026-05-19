<template>
  <div class="parking-page">
    <div class="page-header">
      <h2>停车管理</h2>
      <p>查看我的车位与车辆信息</p>
    </div>

    <a-row :gutter="24">
      <a-col :span="12">
        <a-card title="我的车位" size="small">
          <div v-if="mySpots.length === 0" style="text-align:center; color:#c4c0d0; padding:24px">暂无绑定车位</div>
          <div v-for="s in mySpots" :key="s.spotId" class="info-row">
            <div class="info-label">车位编号</div>
            <div class="info-value">{{ s.spotCode }}</div>
            <div class="info-label">位置</div>
            <div class="info-value">{{ s.location }}</div>
            <div class="info-label">类型</div>
            <div class="info-value">{{ s.type }}</div>
            <div class="info-label">状态</div>
            <div class="info-value">
              <a-tag :color="s.status === 'occupied' ? 'green' : s.status === 'available' ? 'blue' : 'orange'">
                {{ spotStatusLabel(s.status) }}
              </a-tag>
            </div>
          </div>
        </a-card>
      </a-col>
      <a-col :span="12">
        <a-card title="我的车辆" size="small">
          <template #extra>
            <a-button type="primary" size="small" @click="openAddVehicle">登记车辆</a-button>
          </template>
          <div v-if="vehicles.length === 0" style="text-align:center; color:#c4c0d0; padding:24px">暂无车辆</div>
          <div v-for="v in vehicles" :key="v.vehicleId" class="info-row">
            <div class="info-label">车牌号</div>
            <div class="info-value" style="font-weight:600; font-size:15px">{{ v.plateNumber }}</div>
            <div class="info-label">类型 / 颜色</div>
            <div class="info-value">{{ v.vehicleType }} / {{ v.color }}</div>
            <div class="info-label">绑定车位</div>
            <div class="info-value">{{ v.spot?.spotCode || '未绑定' }}</div>
          </div>
        </a-card>
      </a-col>
    </a-row>

    <!-- 登记车辆 Modal -->
    <a-modal v-model:open="vehicleModal.open" title="登记车辆" @ok="doAddVehicle" :confirmLoading="vehicleModal.loading">
      <a-form layout="vertical">
        <a-form-item label="车牌号" required>
          <a-input v-model:value="vehicleModal.plateNumber" placeholder="例如：豫A12345" />
        </a-form-item>
        <a-form-item label="车辆类型">
          <a-input v-model:value="vehicleModal.vehicleType" placeholder="例如：轿车" />
        </a-form-item>
        <a-form-item label="颜色">
          <a-input v-model:value="vehicleModal.color" placeholder="例如：白色" />
        </a-form-item>
        <a-form-item label="绑定车位">
          <a-select v-model:value="vehicleModal.spotId" placeholder="选择车位（可选）" allowClear style="width:100%">
            <a-select-option v-for="s in availableSpots" :key="s.spotId" :value="s.spotId">
              {{ s.spotCode }} ({{ s.location }})
            </a-select-option>
          </a-select>
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script setup>
import { onMounted, reactive, ref } from 'vue'
import { message } from 'ant-design-vue'
import http from '@/api'
import { useUserStore } from '@/stores/user'

const store = useUserStore()
const vehicles = ref([])
const mySpots = ref([])
const availableSpots = ref([])

const vehicleModal = reactive({
  open: false, plateNumber: '', vehicleType: '', color: '', spotId: undefined, loading: false
})

function spotStatusLabel(s) {
  return { available: '可用', occupied: '使用中', maintenance: '维护中' }[s] || s
}

async function fetchData() {
  const ownerId = store.ownerId
  if (!ownerId) return
  vehicles.value = await http.get(`/parking/vehicles?ownerId=${ownerId}`) || []

  const spots = vehicles.value
    .filter(v => v.spot)
    .map(v => v.spot)
    .filter((s, i, arr) => arr.findIndex(x => x.spotId === s.spotId) === i)
  mySpots.value = spots

  availableSpots.value = await http.get('/parking/spots?available=true') || []
}

function openAddVehicle() {
  vehicleModal.plateNumber = ''
  vehicleModal.vehicleType = ''
  vehicleModal.color = ''
  vehicleModal.spotId = undefined
  vehicleModal.open = true
}

async function doAddVehicle() {
  if (!vehicleModal.plateNumber) {
    message.warning('请输入车牌号')
    return
  }
  vehicleModal.loading = true
  try {
    const body = {
      owner: { ownerId: store.ownerId },
      plateNumber: vehicleModal.plateNumber,
      vehicleType: vehicleModal.vehicleType,
      color: vehicleModal.color
    }
    if (vehicleModal.spotId) {
      body.spot = { spotId: vehicleModal.spotId }
    }
    await http.post('/parking/vehicles', body)
    message.success('车辆登记成功')
    vehicleModal.open = false
    await fetchData()
  } catch {
    // error handled by interceptor
  } finally {
    vehicleModal.loading = false
  }
}

onMounted(fetchData)
</script>

<style scoped>
.info-row {
  display: grid;
  grid-template-columns: 80px 1fr;
  gap: 4px 12px;
  padding: 8px 0;
  border-bottom: 1px solid #f0ede8;
  align-items: center;
}
.info-row:last-child { border-bottom: none; }
.info-label {
  font-size: 12px;
  color: #787580;
}
.info-value {
  font-size: 14px;
}
</style>
