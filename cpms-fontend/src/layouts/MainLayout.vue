<template>
  <a-layout class="app-layout">
    <!-- 侧边栏 -->
    <a-layout-sider
      v-model:collapsed="collapsed"
      :trigger="null"
      collapsible
      width="230"
      class="layout-sider"
    >
      <div class="logo-area">
        <div class="logo-icon">
          <svg viewBox="0 0 40 40" fill="none">
            <circle cx="20" cy="20" r="18" stroke="rgba(255,255,255,0.5)" stroke-width="1.2"/>
            <circle cx="20" cy="20" r="14" stroke="rgba(255,255,255,0.2)" stroke-width="0.5"/>
            <path d="M20 8c-5 0-9 4-9 9s4 12 9 16c5-4 9-8 9-16s-4-9-9-9z" fill="none" stroke="rgba(255,255,255,0.8)" stroke-width="1"/>
          </svg>
        </div>
        <Transition name="logo-fade">
          <span v-show="!collapsed" class="logo-text">CPMS</span>
        </Transition>
      </div>

      <a-menu
        v-model:selectedKeys="selectedKeys"
        theme="dark"
        mode="inline"
        class="side-menu"
        @click="handleMenuClick"
      >
        <a-menu-item key="dashboard">
          <template #icon><HomeOutlined /></template>
          <span>首页概览</span>
        </a-menu-item>

        <a-menu-item key="users" v-if="isAdmin">
          <template #icon><TeamOutlined /></template>
          <span>用户管理</span>
        </a-menu-item>

        <a-menu-item key="buildings" v-if="isAdmin || isStaff">
          <template #icon><BankOutlined /></template>
          <span>楼栋管理</span>
        </a-menu-item>

        <a-menu-item key="rooms" v-if="isAdmin || isStaff">
          <template #icon><AppstoreOutlined /></template>
          <span>房间管理</span>
        </a-menu-item>

        <a-menu-item key="owners" v-if="isAdmin || isStaff">
          <template #icon><IdcardOutlined /></template>
          <span>业主管理</span>
        </a-menu-item>

        <a-menu-item key="bills">
          <template #icon><DollarOutlined /></template>
          <span>费用管理</span>
        </a-menu-item>

        <a-menu-item key="repairs">
          <template #icon><ToolOutlined /></template>
          <span>报修管理</span>
        </a-menu-item>

        <a-menu-item key="complaints">
          <template #icon><MessageOutlined /></template>
          <span>投诉建议</span>
        </a-menu-item>

        <a-menu-item key="announcements">
          <template #icon><SoundOutlined /></template>
          <span>公告管理</span>
        </a-menu-item>

        <a-menu-item key="parking" v-if="isAdmin || isStaff">
          <template #icon><CarOutlined /></template>
          <span>停车管理</span>
        </a-menu-item>
      </a-menu>
    </a-layout-sider>

    <!-- 主区域 -->
    <a-layout>
      <a-layout-header class="layout-header">
        <div class="header-left">
          <span class="trigger-icon" @click="collapsed = !collapsed">
            <MenuFoldOutlined v-if="!collapsed" />
            <MenuUnfoldOutlined v-else />
          </span>
          <a-breadcrumb class="header-breadcrumb">
            <a-breadcrumb-item>
              <HomeOutlined style="font-size:13px" />
            </a-breadcrumb-item>
            <a-breadcrumb-item>{{ currentTitle }}</a-breadcrumb-item>
          </a-breadcrumb>
        </div>

        <div class="header-right">
          <span class="welcome-text">{{ timeGreeting }}，{{ userStore.realName || userStore.username }}</span>
          <span class="role-badge">{{ roleLabel }}</span>
          <a-dropdown>
            <a-avatar class="user-avatar" :style="{ background: 'linear-gradient(135deg, #7c3aed, #4f46e5)' }">
              {{ (userStore.realName || userStore.username || '?')[0] }}
            </a-avatar>
            <template #overlay>
              <a-menu>
                <a-menu-item key="logout" @click="handleLogout">
                  <LogoutOutlined /> 退出登录
                </a-menu-item>
              </a-menu>
            </template>
          </a-dropdown>
        </div>
      </a-layout-header>

      <a-layout-content class="layout-content">
        <router-view />
      </a-layout-content>

      <a-layout-footer class="layout-footer">
        南京理工大学紫金学院 · 数据库系统课程设计 · CPMS © 2026
      </a-layout-footer>
    </a-layout>
  </a-layout>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import {
  HomeOutlined, TeamOutlined, BankOutlined, AppstoreOutlined,
  IdcardOutlined, DollarOutlined, ToolOutlined, MessageOutlined,
  SoundOutlined, CarOutlined, MenuFoldOutlined, MenuUnfoldOutlined,
  LogoutOutlined
} from '@ant-design/icons-vue'
import { useUserStore } from '@/stores/user'

const router = useRouter()
const route = useRoute()
const userStore = useUserStore()
const collapsed = ref(false)
const selectedKeys = ref(['dashboard'])

const isAdmin = computed(() => userStore.role === 'admin')
const isStaff = computed(() => userStore.role === 'staff')

const roleLabel = computed(() => {
  const map = { admin: '管理员', staff: '物业人员', owner: '业主' }
  return map[userStore.role] || ''
})

const currentTitle = computed(() => route.meta?.title || '')

const timeGreeting = computed(() => {
  const h = new Date().getHours()
  if (h < 6) return '夜深了'
  if (h < 9) return '早上好'
  if (h < 12) return '上午好'
  if (h < 14) return '中午好'
  if (h < 18) return '下午好'
  return '晚上好'
})

watch(() => route.path, (path) => {
  const key = path.split('/').pop()
  if (key) selectedKeys.value = [key]
}, { immediate: true })

const handleMenuClick = ({ key }) => {
  router.push(`/${key}`)
}

const handleLogout = () => {
  userStore.logout()
  router.push('/login')
}
</script>

<style scoped>
.app-layout {
  min-height: 100vh;
  background: #f5f3ff;
}

/* ====== 侧边栏 ====== */
.layout-sider {
  background: linear-gradient(180deg, #1a0533 0%, #1e1040 30%, #1e2350 100%) !important;
  box-shadow: 4px 0 30px rgba(0,0,0,0.3);
}

.logo-area {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 22px 20px 18px;
  border-bottom: 1px solid rgba(255,255,255,0.06);
  margin-bottom: 8px;
}

.logo-icon svg {
  width: 36px;
  height: 36px;
}

.logo-text {
  font-size: 19px;
  font-weight: 800;
  background: linear-gradient(135deg, #c4b5fd, #93c5fd);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  letter-spacing: 2px;
}

.logo-fade-enter-active,
.logo-fade-leave-active {
  transition: all 0.25s ease;
}
.logo-fade-enter-from,
.logo-fade-leave-to {
  opacity: 0;
  transform: translateX(-8px);
}

/* 菜单 */
.side-menu {
  background: transparent !important;
  border-right: none !important;
}

.side-menu :deep(.ant-menu-item) {
  margin: 3px 10px;
  border-radius: 8px;
  height: 42px;
  line-height: 42px;
  color: rgba(255,255,255,0.6);
  font-size: 14px;
  transition: all 0.2s ease;
}

.side-menu :deep(.ant-menu-item:hover) {
  color: #e0e7ff !important;
  background: rgba(255,255,255,0.06) !important;
}

.side-menu :deep(.ant-menu-item-selected) {
  background: linear-gradient(135deg, rgba(124,58,237,0.35), rgba(79,70,229,0.25)) !important;
  color: #fff !important;
  font-weight: 500;
  box-shadow: 0 0 20px rgba(124,58,237,0.15);
}

.side-menu :deep(.ant-menu-item .anticon) {
  font-size: 17px;
}

.side-menu :deep(.ant-menu-item-selected::after) {
  display: none;
}

/* ====== 顶栏 ====== */
.layout-header {
  background: rgba(255,255,255,0.82);
  backdrop-filter: blur(16px);
  padding: 0 24px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  height: 56px;
  line-height: 56px;
  border-bottom: 1px solid rgba(0,0,0,0.04);
  box-shadow: 0 2px 12px rgba(0,0,0,0.03);
}

.header-left {
  display: flex;
  align-items: center;
  gap: 16px;
}

.trigger-icon {
  font-size: 17px;
  color: #6b7280;
  cursor: pointer;
  padding: 4px;
  border-radius: 6px;
  transition: all 0.2s;
  display: flex;
}

.trigger-icon:hover {
  color: #7c3aed;
  background: rgba(124,58,237,0.08);
}

.header-breadcrumb :deep(.ant-breadcrumb-link) {
  font-size: 13px;
  color: #6b7280;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 14px;
}

.welcome-text {
  font-size: 13px;
  color: #9ca3af;
}

.role-badge {
  font-size: 11px;
  padding: 3px 10px;
  border-radius: 20px;
  background: linear-gradient(135deg, rgba(124,58,237,0.1), rgba(79,70,229,0.08));
  color: #7c3aed;
  font-weight: 500;
  letter-spacing: 1px;
}

.user-avatar {
  cursor: pointer;
  transition: all 0.2s;
}
.user-avatar:hover {
  box-shadow: 0 0 12px rgba(124,58,237,0.3);
  transform: scale(1.05);
}

/* ====== 内容区 ====== */
.layout-content {
  margin: 20px;
  min-height: calc(100vh - 56px - 52px - 40px);
}

/* ====== 页脚 ====== */
.layout-footer {
  text-align: center;
  font-size: 12px;
  color: #c4b5fd;
  background: transparent;
  padding: 16px;
}
</style>
