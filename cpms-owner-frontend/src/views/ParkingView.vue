<template>
  <div class="parking-page">
    <div class="page-header">
      <h2>停车管理</h2>
      <p>查看我的车位与车辆信息</p>
    </div>

    <a-row :gutter="24">
      <a-col :span="12">
        <div class="info-card">
          <div class="info-card-head">
            <h3>我的车位</h3>
          </div>
          <div class="info-card-body">
            <div v-if="mySpots.length === 0" class="info-empty">暂无绑定车位</div>
            <div v-for="s in mySpots" :key="s.spotId" class="info-grid">
              <div class="info-item">
                <span class="info-key">编号</span>
                <span class="info-val">{{ s.spotCode }}</span>
              </div>
              <div class="info-item">
                <span class="info-key">位置</span>
                <span class="info-val">{{ s.location }}</span>
              </div>
              <div class="info-item">
                <span class="info-key">类型</span>
                <span class="info-val">{{ s.type }}</span>
              </div>
              <div class="info-item">
                <span class="info-key">状态</span>
                <a-tag :color="s.status === 'occupied' ? 'green' : s.status === 'available' ? 'blue' : 'orange'" size="small">
                  {{ spotLabel(s.status) }}
                </a-tag>
              </div>
            </div>
          </div>
        </div>
      </a-col>
      <a-col :span="12">
        <div class="info-card">
          <div class="info-card-head">
            <h3>我的车辆</h3>
            <a-button type="primary" size="small" @click="openAddVehicle">登记车辆</a-button>
          </div>
          <div class="info-card-body">
            <div v-if="vehicles.length === 0" class="info-empty">暂无车辆</div>
            <div v-for="v in vehicles" :key="v.vehicleId" class="vehicle-row">
              <div class="vehicle-plate num-display">{{ v.plateNumber }}</div>
              <div class="vehicle-meta">{{ v.vehicleType || '-' }} / {{ v.color || '-' }}</div>
              <div class="vehicle-spot">车位：{{ v.spot?.spotCode || '未绑定' }}</div>
            </div>
          </div>
        </div>
      </a-col>
    </a-row>

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
const vehicleModal = reactive({ open: false, plateNumber: '', vehicleType: '', color: '', spotId: undefined, loading: false })

const spotLabel = (s) => ({ available:'可用', occupied:'使用中', maintenance:'维护中' }[s] || s)

async function fetchData() {
  const ownerId = store.ownerId
  if (!ownerId) return
  vehicles.value = await http.get(`/parking/vehicles?ownerId=${ownerId}`) || []
  const spots = vehicles.value.filter(v => v.spot).map(v => v.spot)
  mySpots.value = spots.filter((s, i, arr) => arr.findIndex(x => x.spotId === s.spotId) === i)
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
  if (!vehicleModal.plateNumber) { message.warning('请输入车牌号'); return }
  vehicleModal.loading = true
  try {
    const body = { owner: { ownerId: store.ownerId }, plateNumber: vehicleModal.plateNumber, vehicleType: vehicleModal.vehicleType, color: vehicleModal.color }
    if (vehicleModal.spotId) body.spot = { spotId: vehicleModal.spotId }
    await http.post('/parking/vehicles', body)
    message.success('车辆登记成功')
    vehicleModal.open = false
    await fetchData()
  } catch { /* interceptor */ }
  finally { vehicleModal.loading = false }
}

onMounted(fetchData)
</script>

<style scoped>
.info-card {
  background: var(--c-surface);
  border: 1px solid var(--c-border);
  border-radius: var(--r-lg);
  box-shadow: var(--shadow-sm);
  overflow: hidden;
}
.info-card-head {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 18px 24px;
  border-bottom: 1px solid var(--c-border-light);
}
.info-card-head h3 {
  margin: 0;
  font-family: var(--font-display);
  font-size: 17px;
  font-weight: 600;
}
.info-card-body { padding: 20px 24px; }
.info-empty {
  text-align: center;
  color: var(--c-muted-light);
  padding: 28px 0;
  font-size: 13px;
}

.info-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
}
.info-item { }
.info-key { display: block; font-size: 11px; color: var(--c-muted); text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 2px; }
.info-val { font-size: 15px; font-weight: 500; }

.vehicle-row {
  padding: 14px 0;
  border-bottom: 1px solid var(--c-border-light);
}
.vehicle-row:last-child { border-bottom: none; }
.vehicle-plate {
  font-size: 20px;
  font-weight: 700;
  color: var(--c-ink);
}
.vehicle-meta { font-size: 13px; color: var(--c-muted); margin-top: 2px; }
.vehicle-spot { font-size: 12px; color: var(--c-muted-light); margin-top: 2px; }
</style>
