import { create } from 'zustand'
import { Deal } from '@maxcrm/shared'
import { apiClient } from '../lib/api'

interface DealState {
  deals: Deal[]
  stats: {
    totalValue: number
    totalDeals: number
    valueByStage: Record<string, number>
  } | null
  isLoading: boolean
  error: string | null
  currentPage: number
  totalPages: number

  fetchDeals: (page?: number) => Promise<void>
  fetchDealStats: () => Promise<void>
  createDeal: (data: Omit<Deal, 'id' | 'createdAt' | 'updatedAt'>) => Promise<void>
  updateDeal: (id: string, data: Partial<Omit<Deal, 'id' | 'createdAt'>>) => Promise<void>
  deleteDeal: (id: string) => Promise<void>
  clearError: () => void
}

export const useDealStore = create<DealState>((set, get) => ({
  deals: [],
  stats: null,
  isLoading: false,
  error: null,
  currentPage: 1,
  totalPages: 1,

  fetchDeals: async (page = 1) => {
    set({ isLoading: true, error: null })
    try {
      const response = await apiClient.getDeals(page)
      if (response.success && response.data) {
        set({
          deals: response.data,
          currentPage: response.pagination?.page || 1,
          totalPages: response.pagination?.totalPages || 1,
          isLoading: false,
        })
      } else {
        set({ error: response.error || 'Failed to fetch deals', isLoading: false })
      }
    } catch (error) {
      set({
        error: error instanceof Error ? error.message : 'Failed to fetch deals',
        isLoading: false,
      })
    }
  },

  fetchDealStats: async () => {
    try {
      const response = await apiClient.getDealStats()
      if (response.success && response.data) {
        set({ stats: response.data })
      }
    } catch (error) {
      console.error('Failed to fetch deal stats:', error)
    }
  },

  createDeal: async (data) => {
    set({ isLoading: true, error: null })
    try {
      const response = await apiClient.createDeal(data)
      if (response.success) {
        await get().fetchDeals(get().currentPage)
        await get().fetchDealStats()
      } else {
        set({ error: response.error || 'Failed to create deal', isLoading: false })
      }
    } catch (error) {
      set({
        error: error instanceof Error ? error.message : 'Failed to create deal',
        isLoading: false,
      })
    }
  },

  updateDeal: async (id, data) => {
    set({ isLoading: true, error: null })
    try {
      const response = await apiClient.updateDeal(id, data)
      if (response.success) {
        await get().fetchDeals(get().currentPage)
        await get().fetchDealStats()
      } else {
        set({ error: response.error || 'Failed to update deal', isLoading: false })
      }
    } catch (error) {
      set({
        error: error instanceof Error ? error.message : 'Failed to update deal',
        isLoading: false,
      })
    }
  },

  deleteDeal: async (id) => {
    set({ isLoading: true, error: null })
    try {
      const response = await apiClient.deleteDeal(id)
      if (response.success) {
        await get().fetchDeals(get().currentPage)
        await get().fetchDealStats()
      } else {
        set({ error: response.error || 'Failed to delete deal', isLoading: false })
      }
    } catch (error) {
      set({
        error: error instanceof Error ? error.message : 'Failed to delete deal',
        isLoading: false,
      })
    }
  },

  clearError: () => set({ error: null }),
}))
