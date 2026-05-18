<template>
  <a-card>
    <div class="toolbar">
      <a-button type="primary" @click="openAdd"><PlusOutlined /> 新增楼栋</a-button>
    </div>
    <a-table :columns="cols" :dataSource="data" :loading="loading" rowKey="buildingId" size="middle">
      <template #bodyCell="{ column, record }">
        <template v-if="column.key === 'action'">
          <a-space>
            <a @click="openEdit(record)">编辑</a>
            <a-popconfirm title="删除楼栋将同时删除其下所有房间" @confirm="handleDel(record.buildingId)">
              <a class="danger-link">删除</a>
            </a-popconfirm>
          </a-space>
        </template>
      </template>
    </a-table>

    <a-modal v-model:open="open" :title="eid ? '编辑楼栋' : '新增楼栋'" @ok="onSave" :confirmLoading="saving">
      <a-form layout="vertical">
        <a-form-item label="楼栋名称" required><a-input v-model:value="f.buildingName" /></a-form-item>
        <a-form-item label="楼层数"><a-input-number v-model:value="f.floors" :min="1" style="width:100%" /></a-form-item>
        <a-form-item label="描述"><a-textarea v-model:value="f.description" :rows="3" /></a-form-item>
      </a-form>
    </a-modal>
  </a-card>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { message } from 'ant-design-vue'
import { PlusOutlined } from '@ant-design/icons-vue'
import http from '@/api'

const data = ref([]), loading = ref(false), open = ref(false), saving = ref(false), eid = ref(null)
const f = reactive({ buildingName: '', floors: null, description: '' })
const cols = [
  { title: 'ID', dataIndex: 'buildingId', width: 70 },
  { title: '楼栋名称', dataIndex: 'buildingName' },
  { title: '楼层数', dataIndex: 'floors' },
  { title: '描述', dataIndex: 'description', ellipsis: true },
  { title: '操作', key: 'action', width: 120 }
]

const fetch = async () => { loading.value = true; try { data.value = await http.get('/buildings') } catch {}; loading.value = false }
const openAdd = () => { eid.value = null; Object.assign(f, { buildingName: '', floors: null, description: '' }); open.value = true }
const openEdit = (r) => { eid.value = r.buildingId; Object.assign(f, r); open.value = true }
const onSave = async () => {
  saving.value = true
  try {
    if (eid.value) await http.put(`/buildings/${eid.value}`, { ...f })
    else await http.post('/buildings', { ...f })
    message.success('成功'); open.value = false; fetch()
  } catch {}; saving.value = false
}
const handleDel = async (id) => { await http.delete(`/buildings/${id}`); message.success('删除成功'); fetch() }
onMounted(fetch)
</script>

<style scoped>
.toolbar { margin-bottom: 16px; }
.danger-link { color: #ff4d4f; }
</style>
