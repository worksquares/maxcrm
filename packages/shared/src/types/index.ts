// Common types shared between API and Web

export interface Contact {
  id: string
  firstName: string
  lastName: string
  email: string
  phone?: string
  companyId?: string
  createdAt: Date
  updatedAt: Date
}

export interface Company {
  id: string
  name: string
  website?: string
  industry?: string
  size?: string
  createdAt: Date
  updatedAt: Date
}

export interface Deal {
  id: string
  title: string
  value: number
  stage: DealStage
  contactId?: string
  companyId?: string
  expectedCloseDate?: Date
  createdAt: Date
  updatedAt: Date
}

export enum DealStage {
  LEAD = 'lead',
  QUALIFIED = 'qualified',
  PROPOSAL = 'proposal',
  NEGOTIATION = 'negotiation',
  CLOSED_WON = 'closed_won',
  CLOSED_LOST = 'closed_lost',
}

export interface User {
  id: string
  email: string
  firstName: string
  lastName: string
  role: UserRole
  createdAt: Date
  updatedAt: Date
}

export enum UserRole {
  ADMIN = 'admin',
  MANAGER = 'manager',
  SALES_REP = 'sales_rep',
  USER = 'user',
}

// API Response types
export interface ApiResponse<T = unknown> {
  success: boolean
  data?: T
  message?: string
  error?: string
}

export interface PaginatedResponse<T> extends ApiResponse<T[]> {
  pagination: {
    page: number
    limit: number
    total: number
    totalPages: number
  }
}
