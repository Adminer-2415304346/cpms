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
    component: () => import('@/layouts/MainLayout.vue'),
    redirect: '/dashboard',
    children: [
      {
        path: 'dashboard',
        name: 'Dashboard',
        component: () => import('@/views/DashboardView.vue'),
        meta: { title: '首页' }
      },
      {
        path: 'users',
        name: 'Users',
        component: () => import('@/views/user/UserList.vue'),
        meta: { title: '用户管理' }
      },
      {
        path: 'buildings',
        name: 'Buildings',
        component: () => import('@/views/building/BuildingList.vue'),
        meta: { title: '楼栋管理' }
      },
      {
        path: 'rooms',
        name: 'Rooms',
        component: () => import('@/views/room/RoomList.vue'),
        meta: { title: '房间管理' }
      },
      {
        path: 'owners',
        name: 'Owners',
        component: () => import('@/views/owner/OwnerList.vue'),
        meta: { title: '业主管理' }
      },
      {
        path: 'bills',
        name: 'Bills',
        component: () => import('@/views/bill/BillList.vue'),
        meta: { title: '费用管理' }
      },
      {
        path: 'repairs',
        name: 'Repairs',
        component: () => import('@/views/repair/RepairList.vue'),
        meta: { title: '报修管理' }
      },
      {
        path: 'complaints',
        name: 'Complaints',
        component: () => import('@/views/complaint/ComplaintList.vue'),
        meta: { title: '投诉建议' }
      },
      {
        path: 'announcements',
        name: 'Announcements',
        component: () => import('@/views/announcement/AnnouncementList.vue'),
        meta: { title: '公告管理' }
      },
      {
        path: 'parking',
        name: 'Parking',
        component: () => import('@/views/parking/ParkingManage.vue'),
        meta: { title: '停车管理' }
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
