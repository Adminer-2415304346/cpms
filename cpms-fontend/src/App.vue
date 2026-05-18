<template>
  <router-view v-slot="{ Component, route }">
    <transition :name="transitionName" mode="out-in">
      <component :is="Component" :key="route.path" />
    </transition>
  </router-view>
</template>

<script setup>
import { ref, watch } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()
const transitionName = ref('page-slide')

watch(() => router.currentRoute.value, (to, from) => {
  if (!from) return
  // 登录页用 fade，其他页面用 slide
  if (to.path === '/login' || from.path === '/login') {
    transitionName.value = 'page-fade'
  } else {
    // 根据路由深度决定方向
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
  transition: all 0.28s cubic-bezier(0.4, 0, 0.2, 1);
}
.page-slide-enter-from {
  opacity: 0;
  transform: translateX(24px);
}
.page-slide-leave-to {
  opacity: 0;
  transform: translateX(-24px);
}

/* ====== 页面反向滑动 ====== */
.page-slide-reverse-enter-active,
.page-slide-reverse-leave-active {
  transition: all 0.28s cubic-bezier(0.4, 0, 0.2, 1);
}
.page-slide-reverse-enter-from {
  opacity: 0;
  transform: translateX(-24px);
}
.page-slide-reverse-leave-to {
  opacity: 0;
  transform: translateX(24px);
}

/* ====== 淡入淡出（登录页切换） ====== */
.page-fade-enter-active,
.page-fade-leave-active {
  transition: all 0.35s cubic-bezier(0.4, 0, 0.2, 1);
}
.page-fade-enter-from,
.page-fade-leave-to {
  opacity: 0;
}
</style>
