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
          <div v-show="!collapsed" class="logo-text-group">
            <span class="logo-text">CPMS</span>
            <span class="logo-sub">社区物业管理系统</span>
          </div>
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
            <a-breadcrumb-item>
              <span class="breadcrumb-current">{{ currentTitle }}</span>
            </a-breadcrumb-item>
          </a-breadcrumb>
        </div>

        <div class="header-right">
          <span class="welcome-text">{{ timeGreeting }}，{{ userStore.realName || userStore.username }}</span>
          <span class="role-badge">
            <span class="role-dot"></span>
            {{ roleLabel }}
          </span>
          <a-dropdown>
            <div class="avatar-wrapper">
              <a-avatar class="user-avatar" :style="{ background: 'linear-gradient(135deg, #7c3aed, #4f46e5)' }">
                {{ (userStore.realName || userStore.username || '?')[0] }}
              </a-avatar>
              <span class="avatar-ring"></span>
            </div>
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
        <div class="content-wrapper">
          <router-view />
        </div>
      </a-layout-content>

      <a-layout-footer class="layout-footer">
        励学笃行 · 南京理工大学紫金学院 · CPMS © 2026
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
  background: linear-gradient(195deg, #100524 0%, #1a0a3a 25%, #1e1048 50%, #162040 100%) !important;
  box-shadow: 6px 0 40px rgba(0,0,0,0.35);
  position: relative;
  overflow: hidden;
}

/* 侧边栏微光 */
.layout-sider::before {
  content: '';
  position: absolute;
  top: -30%;
  right: -40%;
  width: 300px;
  height: 600px;
  background: radial-gradient(ellipse, rgba(124,58,237,0.08) 0%, transparent 70%);
  pointer-events: none;
  animation: sidebar-glow 8s ease-in-out infinite;
}

@keyframes sidebar-glow {
  0%, 100% { opacity: 0.5; transform: scale(1); }
  50% { opacity: 0.8; transform: scale(1.2); }
}

.logo-area {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 18px 16px 16px;
  border-bottom: 1px solid rgba(255,255,255,0.06);
  margin-bottom: 8px;
  position: relative;
  z-index: 1;
}

.logo-icon {
  flex-shrink: 0;
}

.logo-icon svg {
  width: 38px;
  height: 38px;
  animation: logo-spin 20s linear infinite;
}

@keyframes logo-spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

.logo-text-group {
  display: flex;
  flex-direction: column;
  line-height: 1.2;
}

.logo-text {
  font-size: 18px;
  font-weight: 800;
  background: linear-gradient(135deg, #c4b5fd, #a5b4fc, #93c5fd);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  letter-spacing: 2px;
}

.logo-sub {
  font-size: 10px;
  color: rgba(255,255,255,0.3);
  letter-spacing: 1px;
  white-space: nowrap;
}

.logo-fade-enter-active,
.logo-fade-leave-active {
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}
.logo-fade-enter-from,
.logo-fade-leave-to {
  opacity: 0;
  transform: translateX(-10px);
}

/* 菜单 */
.side-menu {
  background: transparent !important;
  border-right: none !important;
  position: relative;
  z-index: 1;
}

.side-menu :deep(.ant-menu-item) {
  margin: 3px 10px;
  border-radius: 10px;
  height: 44px;
  line-height: 44px;
  color: rgba(255,255,255,0.55);
  font-size: 14px;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  overflow: hidden;
}

.side-menu :deep(.ant-menu-item::before) {
  content: '';
  position: absolute;
  left: 0;
  top: 50%;
  transform: translateY(-50%) scaleY(0);
  width: 3px;
  height: 20px;
  background: linear-gradient(180deg, #a78bfa, #7c3aed);
  border-radius: 0 3px 3px 0;
  transition: transform 0.3s cubic-bezier(0.22, 1, 0.36, 1);
}

.side-menu :deep(.ant-menu-item-selected::before) {
  transform: translateY(-50%) scaleY(1);
}

.side-menu :deep(.ant-menu-item:hover) {
  color: #e0e7ff !important;
  background: rgba(255,255,255,0.05) !important;
}

.side-menu :deep(.ant-menu-item-selected) {
  background: linear-gradient(135deg, rgba(124,58,237,0.3), rgba(79,70,229,0.18)) !important;
  color: #fff !important;
  font-weight: 500;
  box-shadow: 0 4px 20px rgba(124,58,237,0.12), inset 0 1px 0 rgba(255,255,255,0.05);
}

.side-menu :deep(.ant-menu-item .anticon) {
  font-size: 18px;
  transition: transform 0.3s ease;
}

.side-menu :deep(.ant-menu-item-selected .anticon) {
  transform: scale(1.1);
}

.side-menu :deep(.ant-menu-item-selected::after) {
  display: none;
}

/* 菜单项交错入场 */
.side-menu :deep(.ant-menu-item) {
  animation: menu-item-in 0.35s cubic-bezier(0.22, 1, 0.36, 1) both;
}
.side-menu :deep(.ant-menu-item:nth-child(1)) { animation-delay: 0.02s; }
.side-menu :deep(.ant-menu-item:nth-child(2)) { animation-delay: 0.06s; }
.side-menu :deep(.ant-menu-item:nth-child(3)) { animation-delay: 0.10s; }
.side-menu :deep(.ant-menu-item:nth-child(4)) { animation-delay: 0.14s; }
.side-menu :deep(.ant-menu-item:nth-child(5)) { animation-delay: 0.18s; }
.side-menu :deep(.ant-menu-item:nth-child(6)) { animation-delay: 0.22s; }
.side-menu :deep(.ant-menu-item:nth-child(7)) { animation-delay: 0.26s; }
.side-menu :deep(.ant-menu-item:nth-child(8)) { animation-delay: 0.30s; }
.side-menu :deep(.ant-menu-item:nth-child(9)) { animation-delay: 0.34s; }
.side-menu :deep(.ant-menu-item:nth-child(10)) { animation-delay: 0.38s; }

@keyframes menu-item-in {
  from { opacity: 0; transform: translateX(-16px); }
  to { opacity: 1; transform: translateX(0); }
}

/* ====== 顶栏 ====== */
.layout-header {
  background: rgba(255,255,255,0.8);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  padding: 0 28px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  height: 58px;
  border-bottom: 1px solid rgba(124,58,237,0.06);
  box-shadow: 0 1px 20px rgba(0,0,0,0.04);
  position: relative;
  z-index: 10;
  overflow: hidden;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 18px;
}

.trigger-icon {
  font-size: 18px;
  color: #6b7280;
  cursor: pointer;
  padding: 6px;
  border-radius: 8px;
  transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
  display: flex;
}

.trigger-icon:hover {
  color: #7c3aed;
  background: rgba(124,58,237,0.07);
  transform: rotate(90deg);
}

.header-breadcrumb :deep(.ant-breadcrumb-link) {
  font-size: 13px;
  color: #9ca3af;
}

.breadcrumb-current {
  color: #4b5563;
  font-weight: 500;
  animation: breadcrumb-in 0.3s cubic-bezier(0.22, 1, 0.36, 1);
}

@keyframes breadcrumb-in {
  from { opacity: 0; transform: translateY(4px); }
  to { opacity: 1; transform: translateY(0); }
}

.header-right {
  display: flex;
  align-items: center;
  gap: 16px;
}

.welcome-text {
  font-size: 13px;
  color: #9ca3af;
}

.role-badge {
  display: flex;
  align-items: center;
  gap: 5px;
  font-size: 11px;
  padding: 4px 12px;
  border-radius: 20px;
  background: linear-gradient(135deg, rgba(124,58,237,0.08), rgba(79,70,229,0.05));
  color: #7c3aed;
  font-weight: 500;
  letter-spacing: 1px;
  border: 1px solid rgba(124,58,237,0.1);
}

.role-dot {
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: #7c3aed;
  box-shadow: 0 0 6px rgba(124,58,237,0.5);
  animation: role-dot-pulse 2.5s ease-in-out infinite;
}

@keyframes role-dot-pulse {
  0%, 100% { box-shadow: 0 0 4px rgba(124,58,237,0.5); }
  50% { box-shadow: 0 0 10px rgba(124,58,237,0.8); }
}

/* 头像脉冲环 */
.avatar-wrapper {
  position: relative;
  cursor: pointer;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.user-avatar {
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  z-index: 1;
  display: block;
}

.avatar-ring {
  position: absolute;
  top: -4px;
  left: -4px;
  right: -4px;
  bottom: -4px;
  border-radius: 50%;
  border: 2px solid rgba(124,58,237,0.3);
  animation: avatar-ring 3s ease-in-out infinite;
  opacity: 0;
  pointer-events: none;
}

.avatar-wrapper:hover .avatar-ring {
  opacity: 1;
}

.avatar-wrapper:hover .user-avatar {
  transform: scale(1.08);
  box-shadow: 0 0 16px rgba(124,58,237,0.35);
}

@keyframes avatar-ring {
  0%, 100% { transform: scale(1); opacity: 0.3; }
  50% { transform: scale(1.12); opacity: 0.7; }
}

/* ====== 内容区 ====== */
.layout-content {
  margin: 20px;
  min-height: calc(100vh - 58px - 52px - 40px);
}

.content-wrapper {
  animation: content-in 0.4s cubic-bezier(0.22, 1, 0.36, 1) both;
}

@keyframes content-in {
  from { opacity: 0; transform: translateY(12px); }
  to { opacity: 1; transform: translateY(0); }
}

/* ====== 页脚 ====== */
.layout-footer {
  text-align: center;
  font-size: 12px;
  background: transparent;
  padding: 16px;
  letter-spacing: 2px;
  background: linear-gradient(90deg, transparent, rgba(124,58,237,0.3), transparent);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}
</style>
