import { Request, Response } from 'express'
import dealService from '../services/dealService'
import { z } from 'zod'
import { DealStage } from '@maxcrm/shared'

// Validation schemas
const createDealSchema = z.object({
  title: z.string().min(1),
  value: z.number().positive(),
  stage: z.nativeEnum(DealStage),
  contactId: z.string().optional(),
  companyId: z.string().optional(),
  expectedCloseDate: z.string().datetime().optional(),
})

const updateDealSchema = z.object({
  title: z.string().min(1).optional(),
  value: z.number().positive().optional(),
  stage: z.nativeEnum(DealStage).optional(),
  contactId: z.string().optional(),
  companyId: z.string().optional(),
  expectedCloseDate: z.string().datetime().optional(),
})

export class DealController {
  async getAllDeals(req: Request, res: Response) {
    try {
      const userId = req.user!.id
      const page = parseInt(req.query.page as string) || 1
      const limit = parseInt(req.query.limit as string) || 20

      const result = await dealService.getAllDeals(userId, page, limit)
      res.json(result)
    } catch (error: unknown) {
      if (error instanceof Error) {
        return res.status(500).json({
          success: false,
          error: error.message,
        })
      }
      return res.status(500).json({
        success: false,
        error: 'Unknown error occurred',
      })
    }
  }

  async getDealById(req: Request, res: Response) {
    try {
      const userId = req.user!.id
      const { id } = req.params
      const result = await dealService.getDealById(id, userId)

      if (!result.success) {
        return res.status(404).json(result)
      }

      res.json(result)
    } catch (error: unknown) {
      if (error instanceof Error) {
        return res.status(500).json({
          success: false,
          error: error.message,
        })
      }
      return res.status(500).json({
        success: false,
        error: 'Unknown error occurred',
      })
    }
  }

  async getDealsByStage(req: Request, res: Response) {
    try {
      const userId = req.user!.id
      const { stage } = req.params as { stage: DealStage }
      const result = await dealService.getDealsByStage(stage, userId)
      res.json(result)
    } catch (error: unknown) {
      if (error instanceof Error) {
        return res.status(500).json({
          success: false,
          error: error.message,
        })
      }
      return res.status(500).json({
        success: false,
        error: 'Unknown error occurred',
      })
    }
  }

  async getDealsByContact(req: Request, res: Response) {
    try {
      const userId = req.user!.id
      const { contactId } = req.params
      const result = await dealService.getDealsByContact(contactId, userId)
      res.json(result)
    } catch (error: unknown) {
      if (error instanceof Error) {
        return res.status(500).json({
          success: false,
          error: error.message,
        })
      }
      return res.status(500).json({
        success: false,
        error: 'Unknown error occurred',
      })
    }
  }

  async getDealsByCompany(req: Request, res: Response) {
    try {
      const userId = req.user!.id
      const { companyId } = req.params
      const result = await dealService.getDealsByCompany(companyId, userId)
      res.json(result)
    } catch (error: unknown) {
      if (error instanceof Error) {
        return res.status(500).json({
          success: false,
          error: error.message,
        })
      }
      return res.status(500).json({
        success: false,
        error: 'Unknown error occurred',
      })
    }
  }

  async createDeal(req: Request, res: Response) {
    try {
      const userId = req.user!.id
      const validatedData = createDealSchema.parse(req.body)

      // Convert string date to Date object if provided
      const dealData = {
        ...validatedData,
        userId,
        expectedCloseDate: validatedData.expectedCloseDate
          ? new Date(validatedData.expectedCloseDate)
          : undefined,
      }

      const result = await dealService.createDeal(dealData)

      if (!result.success) {
        return res.status(400).json(result)
      }

      res.status(201).json(result)
    } catch (error: unknown) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({
          success: false,
          error: 'Validation error',
          details: error.errors,
        })
      }

      if (error instanceof Error) {
        return res.status(500).json({
          success: false,
          error: error.message,
        })
      }

      return res.status(500).json({
        success: false,
        error: 'Unknown error occurred',
      })
    }
  }

  async updateDeal(req: Request, res: Response) {
    try {
      const userId = req.user!.id
      const { id } = req.params
      const validatedData = updateDealSchema.parse(req.body)

      // Convert string date to Date object if provided
      const dealData = {
        ...validatedData,
        expectedCloseDate: validatedData.expectedCloseDate
          ? new Date(validatedData.expectedCloseDate)
          : undefined,
      }

      const result = await dealService.updateDeal(id, userId, dealData)

      if (!result.success) {
        return res.status(404).json(result)
      }

      res.json(result)
    } catch (error: unknown) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({
          success: false,
          error: 'Validation error',
          details: error.errors,
        })
      }

      if (error instanceof Error) {
        return res.status(500).json({
          success: false,
          error: error.message,
        })
      }

      return res.status(500).json({
        success: false,
        error: 'Unknown error occurred',
      })
    }
  }

  async deleteDeal(req: Request, res: Response) {
    try {
      const userId = req.user!.id
      const { id } = req.params
      const result = await dealService.deleteDeal(id, userId)

      if (!result.success) {
        return res.status(404).json(result)
      }

      res.json(result)
    } catch (error: unknown) {
      if (error instanceof Error) {
        return res.status(500).json({
          success: false,
          error: error.message,
        })
      }
      return res.status(500).json({
        success: false,
        error: 'Unknown error occurred',
      })
    }
  }

  async getDealStats(req: Request, res: Response) {
    try {
      const userId = req.user!.id
      const result = await dealService.getDealStats(userId)
      res.json(result)
    } catch (error: unknown) {
      if (error instanceof Error) {
        return res.status(500).json({
          success: false,
          error: error.message,
        })
      }
      return res.status(500).json({
        success: false,
        error: 'Unknown error occurred',
      })
    }
  }
}

export default new DealController()
