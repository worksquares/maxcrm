import { Deal, DealStage, ApiResponse, PaginatedResponse, DEFAULT_PAGE_SIZE } from '@maxcrm/shared'
import { DealModel } from '../models/Deal'

export class DealService {
  async getAllDeals(userId: string, page = 1, limit = DEFAULT_PAGE_SIZE): Promise<PaginatedResponse<Deal>> {
    const allDeals = await DealModel.findAll(userId)
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

  async getDealById(id: string, userId: string): Promise<ApiResponse<Deal>> {
    const deal = await DealModel.findById(id, userId)

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

  async getDealsByStage(stage: DealStage, userId: string): Promise<ApiResponse<Deal[]>> {
    const deals = await DealModel.findByStage(stage, userId)

    return {
      success: true,
      data: deals,
    }
  }

  async getDealsByContact(contactId: string, userId: string): Promise<ApiResponse<Deal[]>> {
    const deals = await DealModel.findByContactId(contactId, userId)

    return {
      success: true,
      data: deals,
    }
  }

  async getDealsByCompany(companyId: string, userId: string): Promise<ApiResponse<Deal[]>> {
    const deals = await DealModel.findByCompanyId(companyId, userId)

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

  async updateDeal(id: string, userId: string, data: Partial<Omit<Deal, 'id' | 'createdAt'>>): Promise<ApiResponse<Deal>> {
    const deal = await DealModel.update(id, userId, data)

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

  async deleteDeal(id: string, userId: string): Promise<ApiResponse<void>> {
    const deleted = await DealModel.delete(id, userId)

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

  async getDealStats(userId: string): Promise<ApiResponse<{
    totalValue: number
    totalDeals: number
    valueByStage: Record<DealStage, number>
  }>> {
    const allDeals = await DealModel.findAll(userId)
    const totalValue = await DealModel.getTotalValue(userId)

    const valueByStage: Record<DealStage, number> = {
      [DealStage.LEAD]: await DealModel.getTotalValueByStage(DealStage.LEAD, userId),
      [DealStage.QUALIFIED]: await DealModel.getTotalValueByStage(DealStage.QUALIFIED, userId),
      [DealStage.PROPOSAL]: await DealModel.getTotalValueByStage(DealStage.PROPOSAL, userId),
      [DealStage.NEGOTIATION]: await DealModel.getTotalValueByStage(DealStage.NEGOTIATION, userId),
      [DealStage.CLOSED_WON]: await DealModel.getTotalValueByStage(DealStage.CLOSED_WON, userId),
      [DealStage.CLOSED_LOST]: await DealModel.getTotalValueByStage(DealStage.CLOSED_LOST, userId),
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
