import { Deal, DealStage, ApiResponse, PaginatedResponse, DEFAULT_PAGE_SIZE } from '@maxcrm/shared'
import { DealModel } from '../models/Deal'

export class DealService {
  async getAllDeals(page = 1, limit = DEFAULT_PAGE_SIZE): Promise<PaginatedResponse<Deal>> {
    const allDeals = await DealModel.findAll()
    const total = allDeals.length
    const totalPages = Math.ceil(total / limit)
    const startIndex = (page - 1) * limit
    const endIndex = startIndex + limit
    const paginatedDeals = allDeals.slice(startIndex, endIndex)

    return {
      success: true,
      data: paginatedDeals,
      pagination: {
        page,
        limit,
        total,
        totalPages,
      },
    }
  }

  async getDealById(id: string): Promise<ApiResponse<Deal>> {
    const deal = await DealModel.findById(id)

    if (!deal) {
      return {
        success: false,
        error: 'Deal not found',
      }
    }

    return {
      success: true,
      data: deal,
    }
  }

  async getDealsByStage(stage: DealStage): Promise<ApiResponse<Deal[]>> {
    const deals = await DealModel.findByStage(stage)

    return {
      success: true,
      data: deals,
    }
  }

  async getDealsByContact(contactId: string): Promise<ApiResponse<Deal[]>> {
    const deals = await DealModel.findByContactId(contactId)

    return {
      success: true,
      data: deals,
    }
  }

  async getDealsByCompany(companyId: string): Promise<ApiResponse<Deal[]>> {
    const deals = await DealModel.findByCompanyId(companyId)

    return {
      success: true,
      data: deals,
    }
  }

  async createDeal(data: Omit<Deal, 'id' | 'createdAt' | 'updatedAt'>): Promise<ApiResponse<Deal>> {
    try {
      const deal = await DealModel.create(data)

      return {
        success: true,
        data: deal,
        message: 'Deal created successfully',
      }
    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Failed to create deal',
      }
    }
  }

  async updateDeal(id: string, data: Partial<Omit<Deal, 'id' | 'createdAt'>>): Promise<ApiResponse<Deal>> {
    const deal = await DealModel.update(id, data)

    if (!deal) {
      return {
        success: false,
        error: 'Deal not found',
      }
    }

    return {
      success: true,
      data: deal,
      message: 'Deal updated successfully',
    }
  }

  async deleteDeal(id: string): Promise<ApiResponse<void>> {
    const deleted = await DealModel.delete(id)

    if (!deleted) {
      return {
        success: false,
        error: 'Deal not found',
      }
    }

    return {
      success: true,
      message: 'Deal deleted successfully',
    }
  }

  async getDealStats(): Promise<ApiResponse<{
    totalValue: number
    totalDeals: number
    valueByStage: Record<DealStage, number>
  }>> {
    const allDeals = await DealModel.findAll()
    const totalValue = await DealModel.getTotalValue()

    const valueByStage: Record<DealStage, number> = {
      [DealStage.LEAD]: await DealModel.getTotalValueByStage(DealStage.LEAD),
      [DealStage.QUALIFIED]: await DealModel.getTotalValueByStage(DealStage.QUALIFIED),
      [DealStage.PROPOSAL]: await DealModel.getTotalValueByStage(DealStage.PROPOSAL),
      [DealStage.NEGOTIATION]: await DealModel.getTotalValueByStage(DealStage.NEGOTIATION),
      [DealStage.CLOSED_WON]: await DealModel.getTotalValueByStage(DealStage.CLOSED_WON),
      [DealStage.CLOSED_LOST]: await DealModel.getTotalValueByStage(DealStage.CLOSED_LOST),
    }

    return {
      success: true,
      data: {
        totalValue,
        totalDeals: allDeals.length,
        valueByStage,
      },
    }
  }
}

export default new DealService()
