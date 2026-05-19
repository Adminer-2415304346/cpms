<template>
  <a-config-provider>
    <template #renderEmpty>
      <div class="empty-state">
        <div class="empty-icon">
          <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="#d1cce0" stroke-width="1" stroke-linecap="round">
            <rect x="3" y="3" width="18" height="18" rx="2" />
            <line x1="9" y1="9" x2="15" y2="15" />
            <line x1="15" y1="9" x2="9" y2="15" />
          </svg>
        </div>
        <p class="empty-text">暂无数据</p>
        <p class="empty-hint">暂时没有内容</p>
      </div>
    </template>
    <router-view v-slot="{ Component, route }">
      <transition name="page-fade" mode="out-in">
        <component :is="Component" :key="route.path" />
      </transition>
    </router-view>
  </a-config-provider>
</template>

<style>
.page-fade-enter-active,
.page-fade-leave-active {
  transition: opacity 0.2s ease;
}
.page-fade-enter-from,
.page-fade-leave-to {
  opacity: 0;
}

.empty-state {
  text-align: center;
  padding: 48px 16px;
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
