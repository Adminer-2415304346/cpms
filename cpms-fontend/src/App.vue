<template>
  <a-config-provider>
    <template #renderEmpty>
      <div class="empty-state">
        <div class="empty-icon">
          <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="#c4b5fd" stroke-width="1" stroke-linecap="round">
            <rect x="3" y="3" width="18" height="18" rx="2" />
            <line x1="9" y1="9" x2="15" y2="15" />
            <line x1="15" y1="9" x2="9" y2="15" />
          </svg>
        </div>
        <p class="empty-text">暂无数据</p>
        <p class="empty-hint">点击上方按钮开始添加</p>
      </div>
    </template>
    <router-view v-slot="{ Component, route }">
      <transition :name="transitionName" mode="out-in">
        <component :is="Component" :key="route.path" />
      </transition>
    </router-view>
  </a-config-provider>
</template>

<script setup>
import { ref, watch } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()
const transitionName = ref('page-slide')

watch(() => router.currentRoute.value, (to, from) => {
  if (!from) return
  if (to.path === '/login' || from.path === '/login') {
    transitionName.value = 'page-fade'
  } else {
    const toDepth = to.path.split('/').length
    const fromDepth = from.path.split('/').length
    transitionName.value = toDepth >= fromDepth ? 'page-slide' : 'page-slide-reverse'
  }
})
</script>

<style>
/* ====== 页面滑动过渡 ====== */
.page-slide-enter-active,
.page-slide-leave-active {
  transition: all 0.2s ease;
}
.page-slide-enter-from {
  opacity: 0;
  transform: translateX(20px);
}
.page-slide-leave-to {
  opacity: 0;
  transform: translateX(-20px);
}

/* ====== 页面反向滑动 ====== */
.page-slide-reverse-enter-active,
.page-slide-reverse-leave-active {
  transition: all 0.2s ease;
}
.page-slide-reverse-enter-from {
  opacity: 0;
  transform: translateX(-20px);
}
.page-slide-reverse-leave-to {
  opacity: 0;
  transform: translateX(20px);
}

/* ====== 淡入淡出 ====== */
.page-fade-enter-active,
.page-fade-leave-active {
  transition: all 0.25s ease;
}
.page-fade-enter-from,
.page-fade-leave-to {
  opacity: 0;
}

/* ====== 空状态 ====== */
.empty-state {
  text-align: center;
  padding: 40px 16px;
}

.empty-icon {
  margin-bottom: 12px;
  display: inline-block;
}

.empty-text {
  margin: 0 0 4px;
  font-size: 14px;
  color: #8e8a9e;
}

.empty-hint {
  margin: 0;
  font-size: 12px;
  color: #c4c0d0;
}
</style>
