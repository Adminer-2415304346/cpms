<template>
  <div class="profile-page">
    <div class="page-header">
      <h2>个人中心</h2>
      <p>查看个人信息与修改密码</p>
    </div>

    <a-card title="基本信息" style="margin-bottom:24px" size="small">
      <div class="info-grid">
        <div class="info-row">
          <span class="info-label">姓名</span>
          <span class="info-value">{{ profile.name || '-' }}</span>
        </div>
        <div class="info-row">
          <span class="info-label">手机号</span>
          <span class="info-value">{{ profile.phone || '-' }}</span>
        </div>
        <div class="info-row">
          <span class="info-label">身份证号</span>
          <span class="info-value">{{ profile.idCard || '-' }}</span>
        </div>
        <div class="info-row">
          <span class="info-label">入住时间</span>
          <span class="info-value">{{ profile.moveInDate || '-' }}</span>
        </div>
      </div>
    </a-card>

    <a-card title="安全设置" size="small">
      <a-button @click="openPwd">修改密码</a-button>
    </a-card>

    <!-- 修改密码 Modal -->
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
import { onMounted, reactive, ref } from 'vue'
import { message } from 'ant-design-vue'
import http from '@/api'
import { useUserStore } from '@/stores/user'

const store = useUserStore()
const profile = reactive({ name: '', phone: '', idCard: '', moveInDate: '' })

const pwdModal = reactive({
  open: false, oldPwd: '', newPwd: '', confirmPwd: '', loading: false
})

onMounted(async () => {
  const ownerId = store.ownerId
  if (!ownerId) return
  try {
    const data = await http.get(`/owners/${ownerId}`)
    if (data) {
      profile.name = data.name
      profile.phone = data.phone
      profile.idCard = data.idCard
      profile.moveInDate = data.moveInDate
    }
  } catch {
    // silent
  }
})

function openPwd() {
  pwdModal.oldPwd = ''
  pwdModal.newPwd = ''
  pwdModal.confirmPwd = ''
  pwdModal.open = true
}

async function doChangePwd() {
  if (!pwdModal.oldPwd || !pwdModal.newPwd) {
    message.warning('请填写密码')
    return
  }
  if (pwdModal.newPwd !== pwdModal.confirmPwd) {
    message.warning('两次输入的新密码不一致')
    return
  }
  pwdModal.loading = true
  try {
    await http.put(`/users/${store.userId}`, {
      password: pwdModal.newPwd
    })
    message.success('密码修改成功')
    pwdModal.open = false
  } catch {
    // error handled by interceptor
  } finally {
    pwdModal.loading = false
  }
}
</script>

<style scoped>
.info-grid {
  max-width: 480px;
}
.info-row {
  display: flex;
  padding: 10px 0;
  border-bottom: 1px solid #f0ede8;
}
.info-row:last-child { border-bottom: none; }
.info-label {
  width: 100px;
  color: #787580;
  font-size: 14px;
  flex-shrink: 0;
}
.info-value {
  font-size: 14px;
  font-weight: 500;
  color: #1e1b2e;
}
</style>
