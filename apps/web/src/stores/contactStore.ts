import { create } from 'zustand'
import { Contact } from '@maxcrm/shared'
import { apiClient } from '../lib/api'

interface ContactState {
  contacts: Contact[]
  isLoading: boolean
  error: string | null
  currentPage: number
  totalPages: number

  fetchContacts: (page?: number) => Promise<void>
  searchContacts: (query: string) => Promise<void>
  createContact: (data: Omit<Contact, 'id' | 'createdAt' | 'updatedAt'>) => Promise<void>
  updateContact: (id: string, data: Partial<Omit<Contact, 'id' | 'createdAt'>>) => Promise<void>
  deleteContact: (id: string) => Promise<void>
  clearError: () => void
}

export const useContactStore = create<ContactState>((set, get) => ({
  contacts: [],
  isLoading: false,
  error: null,
  currentPage: 1,
  totalPages: 1,

  fetchContacts: async (page = 1) => {
    set({ isLoading: true, error: null })
    try {
      const response = await apiClient.getContacts(page)
      if (response.success && response.data) {
        set({
          contacts: response.data,
          currentPage: response.pagination?.page || 1,
          totalPages: response.pagination?.totalPages || 1,
          isLoading: false,
        })
      } else {
        set({ error: response.error || 'Failed to fetch contacts', isLoading: false })
      }
    } catch (error) {
      set({
        error: error instanceof Error ? error.message : 'Failed to fetch contacts',
        isLoading: false,
      })
    }
  },

  searchContacts: async (query: string) => {
    set({ isLoading: true, error: null })
    try {
      const response = await apiClient.searchContacts(query)
      if (response.success && response.data) {
        set({ contacts: response.data, isLoading: false })
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

  createContact: async (data) => {
    set({ isLoading: true, error: null })
    try {
      const response = await apiClient.createContact(data)
      if (response.success) {
        // Refresh contacts list
        await get().fetchContacts(get().currentPage)
      } else {
        set({ error: response.error || 'Failed to create contact', isLoading: false })
      }
    } catch (error) {
      set({
        error: error instanceof Error ? error.message : 'Failed to create contact',
        isLoading: false,
      })
    }
  },

  updateContact: async (id, data) => {
    set({ isLoading: true, error: null })
    try {
      const response = await apiClient.updateContact(id, data)
      if (response.success) {
        // Refresh contacts list
        await get().fetchContacts(get().currentPage)
      } else {
        set({ error: response.error || 'Failed to update contact', isLoading: false })
      }
    } catch (error) {
      set({
        error: error instanceof Error ? error.message : 'Failed to update contact',
        isLoading: false,
      })
    }
  },

  deleteContact: async (id) => {
    set({ isLoading: true, error: null })
    try {
      const response = await apiClient.deleteContact(id)
      if (response.success) {
        // Refresh contacts list
        await get().fetchContacts(get().currentPage)
      } else {
        set({ error: response.error || 'Failed to delete contact', isLoading: false })
      }
    } catch (error) {
      set({
        error: error instanceof Error ? error.message : 'Failed to delete contact',
        isLoading: false,
      })
    }
  },

  clearError: () => set({ error: null }),
}))
