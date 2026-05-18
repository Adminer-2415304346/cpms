import { defineStore } from 'pinia'

export const useUserStore = defineStore('user', {
  state: () => ({
    userId: null,
    username: '',
    role: '',
    realName: ''
  }),
  getters: {
    isLoggedIn: (state) => !!state.userId,
    isAdmin: (state) => state.role === 'admin',
    isStaff: (state) => state.role === 'staff',
    isOwner: (state) => state.role === 'owner'
  },
  actions: {
    setUser(data) {
      this.userId = data.userId
      this.username = data.username
      this.role = data.role
      this.realName = data.realName
    },
    logout() {
      this.userId = null
      this.username = ''
      this.role = ''
      this.realName = ''
    }
  },
  persist: {
    key: 'cpms-user',
    storage: localStorage
  }
})
