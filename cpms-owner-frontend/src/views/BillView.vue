<template>
  <div class="bill-page">
    <div class="page-header">
      <h2>我的账单</h2>
      <p>查看并缴纳物业费用</p>
    </div>

    <div v-for="group in billGroups" :key="group.roomId" class="bill-group">
      <div class="group-label">
        {{ group.buildingName }}
        <span v-if="group.unitName">{{ group.unitName }}</span>
        {{ group.roomNumber }}
      </div>
      <a-table :dataSource="group.bills" :pagination="false" rowKey="billId" size="small">
        <a-table-column title="费用类型" dataIndex="feeType" width="120">
          <template #default="{ text }"><a-tag>{{ text }}</a-tag></template>
        </a-table-column>
        <a-table-column title="金额" width="150">
          <template #default="{ record }">
            <span class="num-display bill-amount">¥{{ record.amount?.toFixed(2) }}</span>
          </template>
        </a-table-column>
        <a-table-column title="账期" dataIndex="period" width="120" />
        <a-table-column title="截止日期" dataIndex="dueDate" width="120" />
        <a-table-column title="状态" width="100">
          <template #default="{ text }">
            <a-tag v-if="text==='paid'" color="green">已缴</a-tag>
            <a-tag v-else-if="text==='overdue'" color="red">逾期</a-tag>
            <a-tag v-else color="orange">待缴</a-tag>
          </template>
        </a-table-column>
        <a-table-column title="操作" width="110">
          <template #default="{ record }">
            <a-button v-if="record.status !== 'paid'" type="primary" size="small" @click="openPayModal(record)">立即缴费</a-button>
          </template>
        </a-table-column>
      </a-table>
    </div>

    <a-empty v-if="billGroups.length === 0" description="暂无账单" />

    <a-modal v-model:open="payModal.open" title="确认缴费" @ok="doPay" :confirmLoading="payModal.loading">
      <a-form layout="vertical">
        <a-form-item label="账单信息">
          <p style="margin:0">费用类型：{{ payModal.bill?.feeType }}</p>
          <p style="margin:4px 0 0">
            金额：<strong class="num-display" style="font-size:22px;color:var(--c-copper)">¥{{ payModal.bill?.amount?.toFixed(2) }}</strong>
          </p>
        </a-form-item>
        <a-form-item label="支付方式" required>
          <a-select v-model:value="payModal.payMethod" style="width:100%">
            <a-select-option value="微信支付">微信支付</a-select-option>
            <a-select-option value="支付宝">支付宝</a-select-option>
            <a-select-option value="银行卡">银行卡</a-select-option>
            <a-select-option value="现金">现金</a-select-option>
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
const billGroups = ref([])
const payModal = reactive({ open: false, bill: null, payMethod: '微信支付', loading: false })

function openPayModal(bill) { payModal.bill = bill; payModal.payMethod = '微信支付'; payModal.open = true }

async function doPay() {
  if (!payModal.payMethod) { message.warning('请选择支付方式'); return }
  payModal.loading = true
  try {
    await http.post(`/bills/${payModal.bill.billId}/pay`, { amount: payModal.bill.amount, payMethod: payModal.payMethod })
    message.success('缴费成功')
    payModal.open = false
    await fetchBills()
  } catch { /* handler by interceptor */ }
  finally { payModal.loading = false }
}

async function fetchBills() {
  const ownerId = store.ownerId
  if (!ownerId) return
  const rooms = await http.get(`/owner-rooms/by-owner/${ownerId}`) || []
  const groups = []
  for (const or of rooms) {
    const bills = await http.get(`/bills?roomId=${or.room?.roomId}`) || []
    if (bills.length > 0) {
      groups.push({
        roomId: or.room?.roomId,
        buildingName: or.room?.building?.buildingName || '',
        unitName: or.room?.unitName || '',
        roomNumber: or.room?.roomNumber || '',
        bills
      })
    }
  }
  billGroups.value = groups
}

onMounted(fetchBills)
</script>

<style scoped>
.bill-group { margin-bottom: 24px; }
.group-label {
  font-family: var(--font-display);
  font-size: 16px;
  font-weight: 600;
  color: var(--c-ink-soft);
  margin-bottom: 12px;
  padding-left: 4px;
}
.bill-amount {
  font-size: 16px;
  font-weight: 700;
}
</style>
