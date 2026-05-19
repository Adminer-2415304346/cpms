import { createRouter, createWebHashHistory } from 'vue-router'
import { useUserStore } from '@/stores/user'

const routes = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/LoginView.vue'),
    meta: { title: '登录' }
  },
  {
    path: '/',
    component: () => import('@/layouts/OwnerLayout.vue'),
    redirect: '/home',
    children: [
      {
        path: 'home',
        name: 'Home',
        component: () => import('@/views/HomeView.vue'),
        meta: { title: '首页' }
      },
      {
        path: 'bills',
        name: 'Bills',
        component: () => import('@/views/BillView.vue'),
        meta: { title: '我的账单' }
      },
      {
        path: 'repairs',
        name: 'Repairs',
        component: () => import('@/views/RepairView.vue'),
        meta: { title: '报修维修' }
      },
      {
        path: 'complaints',
        name: 'Complaints',
        component: () => import('@/views/ComplaintView.vue'),
        meta: { title: '投诉建议' }
      },
      {
        path: 'announces',
        name: 'Announces',
        component: () => import('@/views/AnnounceView.vue'),
        meta: { title: '社区公告' }
      },
      {
        path: 'parking',
        name: 'Parking',
        component: () => import('@/views/ParkingView.vue'),
        meta: { title: '停车管理' }
      },
      {
        path: 'profile',
        name: 'Profile',
        component: () => import('@/views/ProfileView.vue'),
        meta: { title: '个人中心' }
      }
    ]
  }
]

const router = createRouter({
  history: createWebHashHistory(),
  routes
})

router.beforeEach((to, from, next) => {
  const store = useUserStore()
  if (to.path !== '/login' && !store.isLoggedIn) {
    next('/login')
  } else {
    next()
  }
})

export default router
