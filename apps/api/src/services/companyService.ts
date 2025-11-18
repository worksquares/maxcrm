import { Company, ApiResponse, PaginatedResponse, DEFAULT_PAGE_SIZE } from '@maxcrm/shared'
import { CompanyModel } from '../models/Company'

export class CompanyService {
  async getAllCompanies(userId: string, page = 1, limit = DEFAULT_PAGE_SIZE): Promise<PaginatedResponse<Company>> {
    const allCompanies = await CompanyModel.findAll(userId)
    const total = allCompanies.length
    const totalPages = Math.ceil(total / limit)
    const startIndex = (page - 1) * limit
    const endIndex = startIndex + limit
    const paginatedCompanies = allCompanies.slice(startIndex, endIndex)

    return {
      success: true,
      data: paginatedCompanies,
      pagination: {
        page,
        limit,
        total,
        totalPages,
      },
    }
  }

  async getCompanyById(id: string, userId: string): Promise<ApiResponse<Company>> {
    const company = await CompanyModel.findById(id, userId)

    if (!company) {
      return {
        success: false,
        error: 'Company not found',
      }
    }

    return {
      success: true,
      data: company,
    }
  }

  async createCompany(data: Omit<Company, 'id' | 'createdAt' | 'updatedAt'>): Promise<ApiResponse<Company>> {
    try {
      const company = await CompanyModel.create(data)

      return {
        success: true,
        data: company,
        message: 'Company created successfully',
      }
    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Failed to create company',
      }
    }
  }

  async updateCompany(id: string, userId: string, data: Partial<Omit<Company, 'id' | 'createdAt'>>): Promise<ApiResponse<Company>> {
    const company = await CompanyModel.update(id, userId, data)

    if (!company) {
      return {
        success: false,
        error: 'Company not found',
      }
    }

    return {
      success: true,
      data: company,
      message: 'Company updated successfully',
    }
  }

  async deleteCompany(id: string, userId: string): Promise<ApiResponse<void>> {
    const deleted = await CompanyModel.delete(id, userId)

    if (!deleted) {
      return {
        success: false,
        error: 'Company not found',
      }
    }

    return {
      success: true,
      message: 'Company deleted successfully',
    }
  }

  async searchCompanies(query: string, userId: string): Promise<ApiResponse<Company[]>> {
    const companies = await CompanyModel.search(query, userId)

    return {
      success: true,
      data: companies,
    }
  }
}

export default new CompanyService()
