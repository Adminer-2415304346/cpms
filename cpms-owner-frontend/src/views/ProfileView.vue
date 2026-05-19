<template>
  <div class="profile-page">
    <div class="page-header">
      <h2>个人中心</h2>
      <p>查看个人信息与安全设置</p>
    </div>

    <div class="profile-card">
      <div class="profile-avatar">
        <a-avatar :size="72" :style="{ backgroundColor: '#c1784e', fontFamily: 'var(--font-display)', fontSize: '30px' }">
          {{ initial }}
        </a-avatar>
        <div>
          <p class="profile-name">{{ store.realName || store.username }}</p>
          <a-tag color="#c1784e" size="small">业主</a-tag>
        </div>
      </div>

      <a-divider />

      <div class="profile-details">
        <div class="detail-row">
          <span class="detail-label">手机号</span>
          <span class="detail-value">{{ profile.phone || '-' }}</span>
        </div>
        <div class="detail-row">
          <span class="detail-label">身份证号</span>
          <span class="detail-value">{{ profile.idCard || '-' }}</span>
        </div>
        <div class="detail-row">
          <span class="detail-label">入住时间</span>
          <span class="detail-value">{{ profile.moveInDate || '-' }}</span>
        </div>
      </div>

      <a-divider />

      <a-button @click="openPwd">修改密码</a-button>
    </div>

    <a-modal v-model:open="pwdModal.open" title="修改密码" @ok="doChangePwd" :confirmLoading="pwdModal.loading">
      <a-form layout="vertical">
        <a-form-item label="当前密码" required>
          <a-input-password v-model:value="pwdModal.oldPwd" placeholder="请输入当前密码" />
        </a-form-item>
        <a-form-item label="新密码" required>
          <a-input-password v-model:value="pwdModal.newPwd" placeholder="请输入新密码" />
        </a-form-item>
        <a-form-item label="确认新密码" required>
          <a-input-password v-model:value="pwdModal.confirmPwd" placeholder="请再次输入新密码" />
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script setup>
import { computed, onMounted, reactive, ref } from 'vue'
import { message } from 'ant-design-vue'
import http from '@/api'
import { useUserStore } from '@/stores/user'

const store = useUserStore()
const profile = reactive({ phone: '', idCard: '', moveInDate: '' })
const pwdModal = reactive({ open: false, oldPwd: '', newPwd: '', confirmPwd: '', loading: false })

const initial = computed(() => {
  const n = store.realName || store.username
  return n ? n.charAt(0) : 'U'
})

onMounted(async () => {
  const ownerId = store.ownerId
  if (!ownerId) return
  try {
    const data = await http.get(`/owners/${ownerId}`)
    if (data) {
      profile.phone = data.phone || ''
      profile.idCard = data.idCard || ''
      profile.moveInDate = data.moveInDate || ''
    }
  } catch { /* silent */ }
})

function openPwd() {
  pwdModal.oldPwd = ''
  pwdModal.newPwd = ''
  pwdModal.confirmPwd = ''
  pwdModal.open = true
}

async function doChangePwd() {
  if (!pwdModal.oldPwd || !pwdModal.newPwd) { message.warning('请填写密码'); return }
  if (pwdModal.newPwd !== pwdModal.confirmPwd) { message.warning('两次输入的新密码不一致'); return }
  pwdModal.loading = true
  try {
    await http.put(`/users/${store.userId}`, { password: pwdModal.newPwd })
    message.success('密码修改成功')
    pwdModal.open = false
  } catch { /* interceptor */ }
  finally { pwdModal.loading = false }
}
</script>

<style scoped>
.profile-card {
  background: var(--c-surface);
  border: 1px solid var(--c-border);
  border-radius: var(--r-lg);
  padding: 32px;
  box-shadow: var(--shadow-sm);
  max-width: 600px;
}

.profile-avatar {
  display: flex;
  align-items: center;
  gap: 20px;
  margin-bottom: 4px;
}
.profile-name {
  margin: 0;
  font-family: var(--font-display);
  font-size: 24px;
  font-weight: 600;
  color: var(--c-ink);
}

.profile-details { margin: 0; }
.detail-row {
  display: flex;
  padding: 12px 0;
  border-bottom: 1px solid var(--c-border-light);
}
.detail-row:last-child { border-bottom: none; }
.detail-label {
  width: 100px;
  flex-shrink: 0;
  font-size: 13px;
  color: var(--c-muted);
}
.detail-value {
  font-size: 14px;
  font-weight: 500;
  color: var(--c-ink-soft);
}
</style>
