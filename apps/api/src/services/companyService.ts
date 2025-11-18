import { Company, ApiResponse, PaginatedResponse, DEFAULT_PAGE_SIZE } from '@maxcrm/shared'
import { CompanyModel } from '../models/Company'

export class CompanyService {
  async getAllCompanies(page = 1, limit = DEFAULT_PAGE_SIZE): Promise<PaginatedResponse<Company>> {
    const allCompanies = await CompanyModel.findAll()
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

  async getCompanyById(id: string): Promise<ApiResponse<Company>> {
    const company = await CompanyModel.findById(id)

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

  async updateCompany(id: string, data: Partial<Omit<Company, 'id' | 'createdAt'>>): Promise<ApiResponse<Company>> {
    const company = await CompanyModel.update(id, data)

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

  async deleteCompany(id: string): Promise<ApiResponse<void>> {
    const deleted = await CompanyModel.delete(id)

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

  async searchCompanies(query: string): Promise<ApiResponse<Company[]>> {
    const companies = await CompanyModel.search(query)

    return {
      success: true,
      data: companies,
    }
  }
}

export default new CompanyService()
