import { Contact, Company, Deal, ApiResponse, PaginatedResponse } from '@maxcrm/shared'

const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:4000/api'

interface LoginCredentials {
  email: string
  password: string
}

interface RegisterData extends LoginCredentials {
  firstName: string
  lastName: string
}

interface AuthResponse {
  user: {
    id: string
    email: string
    firstName: string
    lastName: string
    role: string
  }
  token: string
}

class ApiClient {
  private token: string | null = null

  constructor() {
    // Load token from localStorage if available
    this.token = localStorage.getItem('auth_token')
  }

  setToken(token: string) {
    this.token = token
    localStorage.setItem('auth_token', token)
  }

  clearToken() {
    this.token = null
    localStorage.removeItem('auth_token')
  }

  private async request<T>(
    endpoint: string,
    options: RequestInit = {}
  ): Promise<T> {
    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
      ...(options.headers as Record<string, string>),
    }

    if (this.token) {
      headers['Authorization'] = `Bearer ${this.token}`
    }

    const response = await fetch(`${API_BASE_URL}${endpoint}`, {
      ...options,
      headers,
    })

    if (!response.ok) {
      const error = await response.json().catch(() => ({ error: 'Request failed' }))
      throw new Error(error.error || `HTTP error! status: ${response.status}`)
    }

    return response.json()
  }

  // Auth endpoints
  async register(data: RegisterData): Promise<ApiResponse<AuthResponse>> {
    const response = await this.request<ApiResponse<AuthResponse>>('/auth/register', {
      method: 'POST',
      body: JSON.stringify(data),
    })

    if (response.success && response.data) {
      this.setToken(response.data.token)
    }

    return response
  }

  async login(credentials: LoginCredentials): Promise<ApiResponse<AuthResponse>> {
    const response = await this.request<ApiResponse<AuthResponse>>('/auth/login', {
      method: 'POST',
      body: JSON.stringify(credentials),
    })

    if (response.success && response.data) {
      this.setToken(response.data.token)
    }

    return response
  }

  async getCurrentUser(): Promise<ApiResponse<AuthResponse['user']>> {
    return this.request('/auth/me')
  }

  logout() {
    this.clearToken()
  }

  // Contact endpoints
  async getContacts(page = 1, limit = 20): Promise<PaginatedResponse<Contact>> {
    return this.request(`/contacts?page=${page}&limit=${limit}`)
  }

  async getContact(id: string): Promise<ApiResponse<Contact>> {
    return this.request(`/contacts/${id}`)
  }

  async createContact(data: Omit<Contact, 'id' | 'createdAt' | 'updatedAt'>): Promise<ApiResponse<Contact>> {
    return this.request('/contacts', {
      method: 'POST',
      body: JSON.stringify(data),
    })
  }

  async updateContact(id: string, data: Partial<Omit<Contact, 'id' | 'createdAt'>>): Promise<ApiResponse<Contact>> {
    return this.request(`/contacts/${id}`, {
      method: 'PUT',
      body: JSON.stringify(data),
    })
  }

  async deleteContact(id: string): Promise<ApiResponse<void>> {
    return this.request(`/contacts/${id}`, {
      method: 'DELETE',
    })
  }

  async searchContacts(query: string): Promise<ApiResponse<Contact[]>> {
    return this.request(`/contacts/search?q=${encodeURIComponent(query)}`)
  }

  // Company endpoints
  async getCompanies(page = 1, limit = 20): Promise<PaginatedResponse<Company>> {
    return this.request(`/companies?page=${page}&limit=${limit}`)
  }

  async getCompany(id: string): Promise<ApiResponse<Company>> {
    return this.request(`/companies/${id}`)
  }

  async createCompany(data: Omit<Company, 'id' | 'createdAt' | 'updatedAt'>): Promise<ApiResponse<Company>> {
    return this.request('/companies', {
      method: 'POST',
      body: JSON.stringify(data),
    })
  }

  async updateCompany(id: string, data: Partial<Omit<Company, 'id' | 'createdAt'>>): Promise<ApiResponse<Company>> {
    return this.request(`/companies/${id}`, {
      method: 'PUT',
      body: JSON.stringify(data),
    })
  }

  async deleteCompany(id: string): Promise<ApiResponse<void>> {
    return this.request(`/companies/${id}`, {
      method: 'DELETE',
    })
  }

  async searchCompanies(query: string): Promise<ApiResponse<Company[]>> {
    return this.request(`/companies/search?q=${encodeURIComponent(query)}`)
  }

  // Deal endpoints
  async getDeals(page = 1, limit = 20): Promise<PaginatedResponse<Deal>> {
    return this.request(`/deals?page=${page}&limit=${limit}`)
  }

  async getDeal(id: string): Promise<ApiResponse<Deal>> {
    return this.request(`/deals/${id}`)
  }

  async createDeal(data: Omit<Deal, 'id' | 'createdAt' | 'updatedAt'>): Promise<ApiResponse<Deal>> {
    return this.request('/deals', {
      method: 'POST',
      body: JSON.stringify(data),
    })
  }

  async updateDeal(id: string, data: Partial<Omit<Deal, 'id' | 'createdAt'>>): Promise<ApiResponse<Deal>> {
    return this.request(`/deals/${id}`, {
      method: 'PUT',
      body: JSON.stringify(data),
    })
  }

  async deleteDeal(id: string): Promise<ApiResponse<void>> {
    return this.request(`/deals/${id}`, {
      method: 'DELETE',
    })
  }

  async getDealStats(): Promise<ApiResponse<{
    totalValue: number
    totalDeals: number
    valueByStage: Record<string, number>
  }>> {
    return this.request('/deals/stats')
  }
}

export const apiClient = new ApiClient()
export default apiClient
