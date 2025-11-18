// Shared constants

export const API_VERSION = 'v1'

export const DEFAULT_PAGE_SIZE = 20
export const MAX_PAGE_SIZE = 100

export const DATE_FORMAT = 'YYYY-MM-DD'
export const DATETIME_FORMAT = 'YYYY-MM-DD HH:mm:ss'

export const CONTACT_STATUS = {
  ACTIVE: 'active',
  INACTIVE: 'inactive',
  ARCHIVED: 'archived',
} as const

export const COMPANY_SIZE = {
  SMALL: '1-10',
  MEDIUM: '11-50',
  LARGE: '51-200',
  ENTERPRISE: '201+',
} as const
