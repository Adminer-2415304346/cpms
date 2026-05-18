<template>
  <a-card>
    <div class="toolbar">
      <a-button type="primary" @click="openAdd"><PlusOutlined /> 新增业主</a-button>
    </div>
    <a-table :columns="cols" :dataSource="data" :loading="loading" rowKey="ownerId" size="middle">
      <template #bodyCell="{ column, record }">
        <template v-if="column.key === 'user'">{{ record.user?.username }}</template>
        <template v-if="column.key === 'action'">
          <a-space>
            <a @click="openEdit(record)">编辑</a>
            <a-popconfirm title="确定删除？" @confirm="handleDel(record.ownerId)"><a class="danger-link">删除</a></a-popconfirm>
          </a-space>
        </template>
      </template>
    </a-table>

    <a-modal v-model:open="open" :title="eid?'编辑业主':'新增业主'" @ok="onSave" :confirmLoading="saving">
      <a-form layout="vertical">
        <a-form-item label="关联用户" required>
          <a-select v-model:value="f.userId" :disabled="!!eid" show-search>
            <a-select-option v-for="u in users" :key="u.userId" :value="u.userId">{{ u.username }} ({{ u.realName }})</a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item label="姓名" required><a-input v-model:value="f.name" /></a-form-item>
        <a-form-item label="身份证号" required><a-input v-model:value="f.idCard" /></a-form-item>
        <a-form-item label="手机"><a-input v-model:value="f.phone" /></a-form-item>
        <a-form-item label="入住日期"><a-date-picker v-model:value="f.moveInDate" style="width:100%" /></a-form-item>
      </a-form>
    </a-modal>
  </a-card>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { message } from 'ant-design-vue'
import { PlusOutlined } from '@ant-design/icons-vue'
import http from '@/api'

const data = ref([]), users = ref([]), loading = ref(false), open = ref(false), saving = ref(false), eid = ref(null)
const f = reactive({ userId: null, name: '', idCard: '', phone: '', moveInDate: null })
const cols = [
  { title: 'ID', dataIndex: 'ownerId', width: 70 },
  { title: '关联用户', key: 'user' },
  { title: '姓名', dataIndex: 'name' },
  { title: '身份证号', dataIndex: 'idCard' },
  { title: '电话', dataIndex: 'phone' },
  { title: '入住日期', dataIndex: 'moveInDate' },
  { title: '操作', key: 'action', width: 120 }
]

const fetch = async () => { loading.value = true; try { data.value = await http.get('/owners') } catch {}; loading.value = false }
const openAdd = async () => {
  eid.value = null
  try { users.value = await http.get('/users?role=owner') } catch {}
  Object.assign(f, { userId: users.value[0]?.userId, name: '', idCard: '', phone: '', moveInDate: null })
  open.value = true
}
const openEdit = async (r) => {
  eid.value = r.ownerId; users.value = r.user ? [{ userId: r.user.userId, username: r.user.username, realName: r.user.realName }] : []
  Object.assign(f, { userId: r.user?.userId, name: r.name, idCard: r.idCard, phone: r.phone || '', moveInDate: r.moveInDate })
  open.value = true
}
const onSave = async () => {
  saving.value = true
  try {
    const body = { user: { userId: f.userId }, name: f.name, idCard: f.idCard, phone: f.phone, moveInDate: f.moveInDate }
    if (eid.value) await http.put(`/owners/${eid.value}`, body)
    else await http.post('/owners', body)
    message.success('成功'); open.value = false; fetch()
  } catch {}; saving.value = false
}
const handleDel = async (id) => { await http.delete(`/owners/${id}`); message.success('删除成功'); fetch() }
onMounted(fetch)
</script>

<style scoped>
.toolbar { margin-bottom: 16px; }
.danger-link { color: #ff4d4f; }
</style>
