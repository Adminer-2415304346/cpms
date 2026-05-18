<template>
  <a-card>
    <div class="toolbar">
      <a-button type="primary" @click="openAdd" v-if="isAdmin||isStaff"><PlusOutlined /> 发布公告</a-button>
    </div>
    <a-list :dataSource="data" :loading="loading" itemLayout="vertical">
      <template #renderItem="{ item }">
        <a-list-item>
          <a-list-item-meta>
            <template #title>
              <span style="font-size:15px;font-weight:500">{{ item.title }}</span>
            </template>
            <template #description>
              {{ item.publisher?.realName || item.publisher?.username }} · {{ item.publishTime }}
            </template>
          </a-list-item-meta>
          <div style="color:#555;line-height:1.7">{{ item.content }}</div>
          <template #actions>
            <a v-if="isAdmin||isStaff" @click="handleDel(item.announcementId)">删除</a>
          </template>
        </a-list-item>
      </template>
    </a-list>

    <a-modal v-model:open="open" title="发布公告" @ok="onSave" :confirmLoading="saving">
      <a-form layout="vertical">
        <a-form-item label="标题" required><a-input v-model:value="f.title" /></a-form-item>
        <a-form-item label="内容" required><a-textarea v-model:value="f.content" :rows="5" /></a-form-item>
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
const data = ref([]), loading = ref(false), open = ref(false), saving = ref(false)
const f = reactive({ title: '', content: '' })

const fetch = async () => { loading.value = true; try { data.value = await http.get('/announcements') } catch {}; loading.value = false }
const openAdd = () => { f.title = ''; f.content = ''; open.value = true }
const onSave = async () => {
  saving.value = true
  try {
    await http.post('/announcements', { title: f.title, content: f.content, publisher: { userId: store.userId } })
    message.success('发布成功'); open.value = false; fetch()
  } catch {}; saving.value = false
}
const handleDel = async (id) => { await http.delete(`/announcements/${id}`); message.success('删除成功'); fetch() }
onMounted(fetch)
</script>

<style scoped>
.toolbar { margin-bottom: 16px; }
</style>
