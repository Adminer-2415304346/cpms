<template>
  <a-layout class="owner-layout">
    <!-- 顶栏 -->
    <a-layout-header class="owner-header">
      <div class="header-inner">
        <div class="header-left" @click="router.push('/home')">
          <div class="brand-logo">
            <svg width="28" height="28" viewBox="0 0 32 32" fill="none">
              <rect width="32" height="32" rx="8" fill="#7c3aed"/>
              <path d="M8 22V12l6 8 4-4 6 6" stroke="#fff" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" fill="none"/>
            </svg>
          </div>
          <span class="brand-name">CPMS</span>
          <span class="brand-sub">业主服务</span>
        </div>
        <nav class="header-nav">
          <router-link to="/home" class="nav-item" :class="{ active: $route.path === '/home' }">首页</router-link>
          <router-link to="/bills" class="nav-item" :class="{ active: $route.path === '/bills' }">我的账单</router-link>
          <router-link to="/repairs" class="nav-item" :class="{ active: $route.path === '/repairs' }">报修维修</router-link>
          <router-link to="/complaints" class="nav-item" :class="{ active: $route.path === '/complaints' }">投诉建议</router-link>
          <router-link to="/announces" class="nav-item" :class="{ active: $route.path === '/announces' }">社区公告</router-link>
          <router-link to="/parking" class="nav-item" :class="{ active: $route.path === '/parking' }">停车管理</router-link>
        </nav>
        <div class="header-right">
          <a-dropdown>
            <a class="user-avatar-link">
              <a-avatar :size="32" :style="{ backgroundColor: '#7c3aed' }">
                {{ displayName }}
              </a-avatar>
              <span class="user-name">{{ store.realName || store.username }}</span>
            </a>
            <template #overlay>
              <a-menu>
                <a-menu-item key="profile" @click="router.push('/profile')">
                  <UserOutlined /> 个人中心
                </a-menu-item>
                <a-menu-divider />
                <a-menu-item key="logout" @click="handleLogout">
                  <LogoutOutlined /> 退出登录
                </a-menu-item>
              </a-menu>
            </template>
          </a-dropdown>
        </div>
      </div>
    </a-layout-header>

    <!-- 内容区 -->
    <a-layout-content class="owner-content">
      <div class="content-inner">
        <router-view />
      </div>
    </a-layout-content>
  </a-layout>
</template>

<script setup>
import { computed } from 'vue'
import { useRouter } from 'vue-router'
import { UserOutlined, LogoutOutlined } from '@ant-design/icons-vue'
import { useUserStore } from '@/stores/user'

const router = useRouter()
const store = useUserStore()

const displayName = computed(() => {
  const name = store.realName || store.username
  return name ? name.charAt(0) : 'U'
})

function handleLogout() {
  store.logout()
  router.push('/login')
}
</script>

<style scoped>
.owner-layout {
  min-height: 100vh;
  background: #faf9f7;
}

/* 顶栏 */
.owner-header {
  position: sticky;
  top: 0;
  z-index: 100;
  background: #fff;
  border-bottom: 1px solid #e8e5e0;
  padding: 0 32px;
  height: 56px;
  line-height: 56px;
  box-shadow: 0 1px 2px rgba(0,0,0,.03);
}

.header-inner {
  display: flex;
  align-items: center;
  max-width: 1200px;
  margin: 0 auto;
  height: 56px;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  flex-shrink: 0;
}

.brand-name {
  font-size: 18px;
  font-weight: 700;
  color: #1e1b2e;
  letter-spacing: -0.5px;
}

.brand-sub {
  font-size: 12px;
  color: #8e8a9e;
  margin-left: 4px;
  padding-left: 8px;
  border-left: 1px solid #e8e5e0;
}

.header-nav {
  display: flex;
  align-items: center;
  gap: 4px;
  margin-left: 48px;
}

.nav-item {
  padding: 0 16px;
  height: 56px;
  line-height: 56px;
  text-decoration: none;
  color: #6b6778;
  font-size: 14px;
  font-weight: 500;
  border-bottom: 2px solid transparent;
  transition: all 0.15s ease;
}

.nav-item:hover {
  color: #7c3aed;
}

.nav-item.active {
  color: #7c3aed;
  border-bottom-color: #7c3aed;
}

.header-right {
  margin-left: auto;
  display: flex;
  align-items: center;
}

.user-avatar-link {
  display: flex;
  align-items: center;
  gap: 8px;
  color: #1e1b2e;
}

.user-name {
  font-size: 14px;
  font-weight: 500;
}

/* 内容区 */
.owner-content {
  padding: 24px 32px;
}

.content-inner {
  max-width: 1200px;
  margin: 0 auto;
}
</style>
