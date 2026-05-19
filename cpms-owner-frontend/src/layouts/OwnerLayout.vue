<template>
  <a-layout class="owner-layout">
    <a-layout-header class="owner-header">
      <div class="header-inner">
        <div class="header-brand" @click="router.push('/home')">
          <span class="brand-mark">CPMS</span>
          <span class="brand-divider"></span>
          <span class="brand-label">业主服务</span>
        </div>

        <nav class="header-nav">
          <router-link v-for="item in navItems" :key="item.path" :to="item.path" class="nav-link" :class="{ active: $route.path === item.path }">
            {{ item.label }}
          </router-link>
        </nav>

        <div class="header-user">
          <a-dropdown placement="bottomRight">
            <div class="user-trigger">
              <a-avatar :size="34" :style="{ backgroundColor: '#c1784e', fontFamily: 'var(--font-ui)' }">
                {{ displayName }}
              </a-avatar>
              <span class="user-name">{{ store.realName || store.username }}</span>
              <DownOutlined style="font-size:10px;color:var(--c-muted)" />
            </div>
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
import { UserOutlined, LogoutOutlined, DownOutlined } from '@ant-design/icons-vue'
import { useUserStore } from '@/stores/user'

const router = useRouter()
const store = useUserStore()

const navItems = [
  { path: '/home', label: '首页' },
  { path: '/bills', label: '我的账单' },
  { path: '/repairs', label: '报修维修' },
  { path: '/complaints', label: '投诉建议' },
  { path: '/announces', label: '社区公告' },
  { path: '/parking', label: '停车管理' }
]

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
  background: var(--c-ivory);
}

/* ---- Header ---- */
.owner-header {
  position: sticky;
  top: 0;
  z-index: 100;
  background: rgba(255,255,255,.88);
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
  border-bottom: 1px solid var(--c-border-light);
  padding: 0 36px;
  height: 60px;
  line-height: 60px;
}

.header-inner {
  display: flex;
  align-items: center;
  max-width: 1160px;
  margin: 0 auto;
  height: 60px;
}

/* Brand */
.header-brand {
  display: flex;
  align-items: center;
  gap: 12px;
  cursor: pointer;
  flex-shrink: 0;
}

.brand-mark {
  font-family: var(--font-display);
  font-size: 22px;
  font-weight: 700;
  color: var(--c-ink);
  letter-spacing: -0.5px;
}

.brand-divider {
  width: 1px;
  height: 18px;
  background: var(--c-border);
}

.brand-label {
  font-size: 12px;
  color: var(--c-muted);
  font-weight: 500;
  letter-spacing: 0.5px;
}

/* Nav */
.header-nav {
  display: flex;
  align-items: center;
  gap: 2px;
  margin: 0 auto;
}

.nav-link {
  padding: 0 18px;
  height: 60px;
  line-height: 60px;
  text-decoration: none;
  color: var(--c-ink-soft);
  font-size: 14px;
  font-weight: 500;
  position: relative;
  transition: color var(--transition);
}

.nav-link:hover { color: var(--c-copper); }

.nav-link.active {
  color: var(--c-copper);
}
.nav-link.active::after {
  content: '';
  position: absolute;
  bottom: 0;
  left: 50%;
  transform: translateX(-50%);
  width: 20px;
  height: 3px;
  border-radius: 3px 3px 0 0;
  background: var(--c-copper);
}

/* User */
.header-user {
  flex-shrink: 0;
  margin-left: auto;
}

.user-trigger {
  display: flex;
  align-items: center;
  gap: 10px;
  cursor: pointer;
}

.user-name {
  font-size: 14px;
  font-weight: 500;
  color: var(--c-ink);
}

/* ---- Content ---- */
.owner-content {
  padding: 36px;
}

.content-inner {
  max-width: 1160px;
  margin: 0 auto;
}
</style>
