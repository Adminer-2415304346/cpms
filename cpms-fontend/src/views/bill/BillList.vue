<template>
  <a-card>
    <div class="toolbar">
      <a-space>
        <a-button type="primary" @click="openAdd"><PlusOutlined /> 生成账单</a-button>
        <a-button v-if="isAdmin||isStaff" @click="toggleUnpaid" :type="unpaidOnly ? 'primary' : 'default'">欠费账单</a-button>
      </a-space>
    </div>
    <a-table :columns="cols" :dataSource="data" :loading="loading" rowKey="billId" size="middle">
      <template #bodyCell="{ column, record }">
        <template v-if="column.key === 'room'">{{ record.room?.building?.buildingName }} - {{ record.room?.unitName }} {{ record.room?.roomNumber }}</template>
        <template v-if="column.key === 'status'">
          <a-tag :color="record.status==='paid'?'green':record.status==='overdue'?'red':'orange'">
            {{ {paid:'已缴',unpaid:'未缴',overdue:'逾期'}[record.status] }}
          </a-tag>
        </template>
        <template v-if="column.key === 'action'">
          <a-space>
            <a v-if="record.status !== 'paid' && (isAdmin||isStaff)" @click="openPay(record)">缴费</a>
            <a-popconfirm v-if="isAdmin||isStaff" title="确定删除？" @confirm="handleDel(record.billId)"><a class="danger-link">删除</a></a-popconfirm>
          </a-space>
        </template>
      </template>
    </a-table>

    <a-modal v-model:open="open" title="生成账单" @ok="onSave" :confirmLoading="saving">
      <a-form layout="vertical">
        <a-form-item label="房间" required>
          <a-select v-model:value="f.roomId" show-search option-filter-prop="label">
            <a-select-option v-for="r in rooms" :key="r.roomId" :value="r.roomId" :label="`${r.building?.buildingName} ${r.unitName}${r.roomNumber}`">
              {{ r.building?.buildingName }} - {{ r.unitName }}{{ r.roomNumber }}
            </a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item label="费用类型" required><a-input v-model:value="f.feeType" placeholder="物业费/水费/电费" /></a-form-item>
        <a-form-item label="金额" required><a-input-number v-model:value="f.amount" :min="0" :precision="2" style="width:100%" /></a-form-item>
        <a-form-item label="计费周期"><a-input v-model:value="f.period" placeholder="2026-Q2" /></a-form-item>
        <a-form-item label="截止日期"><a-date-picker v-model:value="f.dueDate" style="width:100%" /></a-form-item>
      </a-form>
    </a-modal>

    <a-modal v-model:open="payOpen" title="确认缴费" @ok="doPay" :confirmLoading="paying">
      <a-descriptions :column="1" size="small">
        <a-descriptions-item label="费用类型">{{ payBill.feeType }}</a-descriptions-item>
        <a-descriptions-item label="金额">¥{{ payBill.amount }}</a-descriptions-item>
        <a-descriptions-item label="房间">{{ payBill.room?.building?.buildingName }} {{ payBill.room?.roomNumber }}</a-descriptions-item>
      </a-descriptions>
      <a-form-item label="支付方式" style="margin-top:12px">
        <a-select v-model:value="payMethod">
          <a-select-option value="微信支付">微信支付</a-select-option>
          <a-select-option value="支付宝">支付宝</a-select-option>
          <a-select-option value="现金">现金</a-select-option>
          <a-select-option value="银行转账">银行转账</a-select-option>
        </a-select>
      </a-form-item>
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
const data = ref([]), rooms = ref([]), loading = ref(false), open = ref(false), saving = ref(false), unpaidOnly = ref(false)
const payOpen = ref(false), paying = ref(false), payMethod = ref('微信支付'), payBill = ref({})

const f = reactive({ roomId: null, feeType: '', amount: null, period: '', dueDate: null })

const cols = [
  { title: 'ID', dataIndex: 'billId', width: 70 },
  { title: '房间', key: 'room' },
  { title: '费用类型', dataIndex: 'feeType' },
  { title: '金额', dataIndex: 'amount' },
  { title: '周期', dataIndex: 'period' },
  { title: '截止日期', dataIndex: 'dueDate' },
  { title: '状态', key: 'status' },
  { title: '操作', key: 'action', width: 120 }
]

const fetch = async () => {
  loading.value = true
  try {
    const url = unpaidOnly.value ? '/bills?unpaid=true' : '/bills'
    const [bills, r] = await Promise.all([http.get(url), http.get('/rooms')])
    data.value = bills; rooms.value = r
  } catch {}; loading.value = false
}

const toggleUnpaid = () => { unpaidOnly.value = !unpaidOnly.value; fetch() }
const openAdd = async () => {
  try { rooms.value = await http.get('/rooms') } catch {}
  Object.assign(f, { roomId: rooms.value[0]?.roomId, feeType: '', amount: null, period: '', dueDate: null })
  open.value = true
}
const onSave = async () => {
  saving.value = true
  try {
    await http.post('/bills', { room: { roomId: f.roomId }, feeType: f.feeType, amount: f.amount, period: f.period, dueDate: f.dueDate })
    message.success('账单已生成'); open.value = false; fetch()
  } catch {}; saving.value = false
}
const openPay = (r) => { payBill.value = r; payMethod.value = '微信支付'; payOpen.value = true }
const doPay = async () => {
  paying.value = true
  try {
    await http.post(`/bills/${payBill.value.billId}/pay`, { payMethod: payMethod.value, staffId: store.userId })
    message.success('缴费成功'); payOpen.value = false; fetch()
  } catch {}; paying.value = false
}
const handleDel = async (id) => { await http.delete(`/bills/${id}`); message.success('删除成功'); fetch() }
onMounted(fetch)
</script>

<style scoped>
.toolbar { margin-bottom: 16px; }
.danger-link { color: #ff4d4f; }
</style>
