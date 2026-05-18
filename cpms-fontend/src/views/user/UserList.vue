<template>
  <div>
    <a-card>
      <div class="toolbar">
        <a-space>
          <a-button type="primary" @click="openAdd">
            <PlusOutlined /> 新增用户
          </a-button>
        </a-space>
      </div>

      <a-table
        :columns="columns"
        :dataSource="data"
        :loading="loading"
        rowKey="userId"
        size="middle"
      >
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'role'">
            <a-tag :color="roleColor(record.role)">{{ roleLabel(record.role) }}</a-tag>
          </template>
          <template v-if="column.key === 'status'">
            <a-badge :status="record.status === 'active' ? 'success' : 'default'" />
            {{ record.status === 'active' ? '启用' : '禁用' }}
          </template>
          <template v-if="column.key === 'action'">
            <a-space>
              <a @click="openEdit(record)">编辑</a>
              <a-popconfirm title="确定删除？" @confirm="handleDelete(record.userId)">
                <a class="danger-link">删除</a>
              </a-popconfirm>
            </a-space>
          </template>
        </template>
      </a-table>
    </a-card>

    <a-modal
      v-model:open="modalOpen"
      :title="editingId ? '编辑用户' : '新增用户'"
      @ok="handleSave"
      :confirmLoading="saving"
    >
      <a-form :model="form" layout="vertical">
        <a-form-item label="用户名" required>
          <a-input v-model:value="form.username" :disabled="!!editingId" />
        </a-form-item>
        <a-form-item label="密码" :required="!editingId">
          <a-input-password v-model:value="form.password" placeholder="留空则不修改" />
        </a-form-item>
        <a-form-item label="角色" required>
          <a-select v-model:value="form.role">
            <a-select-option value="admin">管理员</a-select-option>
            <a-select-option value="staff">物业人员</a-select-option>
            <a-select-option value="owner">业主</a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item label="姓名">
          <a-input v-model:value="form.realName" />
        </a-form-item>
        <a-form-item label="手机">
          <a-input v-model:value="form.phone" />
        </a-form-item>
        <a-form-item label="邮箱">
          <a-input v-model:value="form.email" />
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { message } from 'ant-design-vue'
import { PlusOutlined } from '@ant-design/icons-vue'
import http from '@/api'

const data = ref([])
const loading = ref(false)
const modalOpen = ref(false)
const saving = ref(false)
const editingId = ref(null)

const form = reactive({ username: '', password: '', role: 'owner', realName: '', phone: '', email: '' })

const columns = [
  { title: 'ID', dataIndex: 'userId', width: 70 },
  { title: '用户名', dataIndex: 'username' },
  { title: '姓名', dataIndex: 'realName' },
  { title: '角色', key: 'role' },
  { title: '手机', dataIndex: 'phone' },
  { title: '状态', key: 'status' },
  { title: '操作', key: 'action', width: 120 }
]

const roleColor = (r) => ({ admin: 'red', staff: 'blue', owner: 'green' }[r])
const roleLabel = (r) => ({ admin: '管理员', staff: '物业人员', owner: '业主' }[r])

const fetchData = async () => {
  loading.value = true
  try { data.value = await http.get('/users') } catch {}
  loading.value = false
}

const openAdd = () => {
  editingId.value = null
  Object.assign(form, { username: '', password: '', role: 'owner', realName: '', phone: '', email: '' })
  modalOpen.value = true
}

const openEdit = (r) => {
  editingId.value = r.userId
  Object.assign(form, { username: r.username, password: '', role: r.role, realName: r.realName || '', phone: r.phone || '', email: r.email || '' })
  modalOpen.value = true
}

const handleSave = async () => {
  saving.value = true
  try {
    if (editingId.value) {
      await http.put(`/users/${editingId.value}`, { ...form })
    } else {
      await http.post('/users', { ...form })
    }
    message.success(editingId.value ? '修改成功' : '新增成功')
    modalOpen.value = false
    fetchData()
  } catch {}
  saving.value = false
}

const handleDelete = async (id) => {
  await http.delete(`/users/${id}`)
  message.success('删除成功')
  fetchData()
}

onMounted(fetchData)
</script>

<style scoped>
.toolbar { margin-bottom: 16px; }
.danger-link { color: #ff4d4f; }
</style>
