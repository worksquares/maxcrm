import { create } from 'zustand'
import { Company } from '@maxcrm/shared'
import { apiClient } from '../lib/api'

interface CompanyState {
  companies: Company[]
  isLoading: boolean
  error: string | null
  currentPage: number
  totalPages: number

  fetchCompanies: (page?: number) => Promise<void>
  searchCompanies: (query: string) => Promise<void>
  createCompany: (data: Omit<Company, 'id' | 'createdAt' | 'updatedAt'>) => Promise<void>
  updateCompany: (id: string, data: Partial<Omit<Company, 'id' | 'createdAt'>>) => Promise<void>
  deleteCompany: (id: string) => Promise<void>
  clearError: () => void
}

export const useCompanyStore = create<CompanyState>((set, get) => ({
  companies: [],
  isLoading: false,
  error: null,
  currentPage: 1,
  totalPages: 1,

  fetchCompanies: async (page = 1) => {
    set({ isLoading: true, error: null })
    try {
      const response = await apiClient.getCompanies(page)
      if (response.success && response.data) {
        set({
          companies: response.data,
          currentPage: response.pagination?.page || 1,
          totalPages: response.pagination?.totalPages || 1,
          isLoading: false,
        })
      } else {
        set({ error: response.error || 'Failed to fetch companies', isLoading: false })
      }
    } catch (error) {
      set({
        error: error instanceof Error ? error.message : 'Failed to fetch companies',
        isLoading: false,
      })
    }
  },

  searchCompanies: async (query: string) => {
    set({ isLoading: true, error: null })
    try {
      const response = await apiClient.searchCompanies(query)
      if (response.success && response.data) {
        set({ companies: response.data, isLoading: false })
      } else {
        set({ error: response.error || 'Search failed', isLoading: false })
      }
    } catch (error) {
      set({
        error: error instanceof Error ? error.message : 'Search failed',
        isLoading: false,
      })
    }
  },

  createCompany: async (data) => {
    set({ isLoading: true, error: null })
    try {
      const response = await apiClient.createCompany(data)
      if (response.success) {
        await get().fetchCompanies(get().currentPage)
      } else {
        set({ error: response.error || 'Failed to create company', isLoading: false })
      }
    } catch (error) {
      set({
        error: error instanceof Error ? error.message : 'Failed to create company',
        isLoading: false,
      })
    }
  },

  updateCompany: async (id, data) => {
    set({ isLoading: true, error: null })
    try {
      const response = await apiClient.updateCompany(id, data)
      if (response.success) {
        await get().fetchCompanies(get().currentPage)
      } else {
        set({ error: response.error || 'Failed to update company', isLoading: false })
      }
    } catch (error) {
      set({
        error: error instanceof Error ? error.message : 'Failed to update company',
        isLoading: false,
      })
    }
  },

  deleteCompany: async (id) => {
    set({ isLoading: true, error: null })
    try {
      const response = await apiClient.deleteCompany(id)
      if (response.success) {
        await get().fetchCompanies(get().currentPage)
      } else {
        set({ error: response.error || 'Failed to delete company', isLoading: false })
      }
    } catch (error) {
      set({
        error: error instanceof Error ? error.message : 'Failed to delete company',
        isLoading: false,
      })
    }
  },

  clearError: () => set({ error: null }),
}))
