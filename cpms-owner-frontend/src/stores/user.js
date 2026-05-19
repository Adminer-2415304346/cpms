import { defineStore } from 'pinia'
import http from '@/api'

export const useUserStore = defineStore('user', {
  state: () => ({
    userId: null,
    username: '',
    role: '',
    realName: '',
    ownerId: null
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
    async fetchOwnerId() {
      if (this.ownerId) return this.ownerId
      try {
        const owner = await http.get(`/owners/by-user/${this.userId}`)
        if (owner) {
          this.ownerId = owner.ownerId
          return this.ownerId
        }
      } catch {
        // user may not be linked to an owner profile
      }
      return null
    },
    logout() {
      this.userId = null
      this.username = ''
      this.role = ''
      this.realName = ''
      this.ownerId = null
    }
  },
  persist: {
    key: 'cpms-owner-user',
    storage: localStorage
  }
})
