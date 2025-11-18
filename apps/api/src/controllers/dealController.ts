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
      const page = parseInt(req.query.page as string) || 1
      const limit = parseInt(req.query.limit as string) || 20

      const result = await dealService.getAllDeals(page, limit)
      res.json(result)
    } catch (error) {
      res.status(500).json({
        success: false,
        error: error instanceof Error ? error.message : 'Internal server error',
      })
    }
  }

  async getDealById(req: Request, res: Response) {
    try {
      const { id } = req.params
      const result = await dealService.getDealById(id)

      if (!result.success) {
        return res.status(404).json(result)
      }

      res.json(result)
    } catch (error) {
      res.status(500).json({
        success: false,
        error: error instanceof Error ? error.message : 'Internal server error',
      })
    }
  }

  async getDealsByStage(req: Request, res: Response) {
    try {
      const { stage } = req.params as { stage: DealStage }
      const result = await dealService.getDealsByStage(stage)
      res.json(result)
    } catch (error) {
      res.status(500).json({
        success: false,
        error: error instanceof Error ? error.message : 'Internal server error',
      })
    }
  }

  async getDealsByContact(req: Request, res: Response) {
    try {
      const { contactId } = req.params
      const result = await dealService.getDealsByContact(contactId)
      res.json(result)
    } catch (error) {
      res.status(500).json({
        success: false,
        error: error instanceof Error ? error.message : 'Internal server error',
      })
    }
  }

  async getDealsByCompany(req: Request, res: Response) {
    try {
      const { companyId } = req.params
      const result = await dealService.getDealsByCompany(companyId)
      res.json(result)
    } catch (error) {
      res.status(500).json({
        success: false,
        error: error instanceof Error ? error.message : 'Internal server error',
      })
    }
  }

  async createDeal(req: Request, res: Response) {
    try {
      const validatedData = createDealSchema.parse(req.body)

      // Convert string date to Date object if provided
      const dealData = {
        ...validatedData,
        expectedCloseDate: validatedData.expectedCloseDate
          ? new Date(validatedData.expectedCloseDate)
          : undefined,
      }

      const result = await dealService.createDeal(dealData)

      if (!result.success) {
        return res.status(400).json(result)
      }

      res.status(201).json(result)
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({
          success: false,
          error: 'Validation error',
          details: error.errors,
        })
      }

      res.status(500).json({
        success: false,
        error: error instanceof Error ? error.message : 'Internal server error',
      })
    }
  }

  async updateDeal(req: Request, res: Response) {
    try {
      const { id } = req.params
      const validatedData = updateDealSchema.parse(req.body)

      // Convert string date to Date object if provided
      const dealData = {
        ...validatedData,
        expectedCloseDate: validatedData.expectedCloseDate
          ? new Date(validatedData.expectedCloseDate)
          : undefined,
      }

      const result = await dealService.updateDeal(id, dealData)

      if (!result.success) {
        return res.status(404).json(result)
      }

      res.json(result)
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({
          success: false,
          error: 'Validation error',
          details: error.errors,
        })
      }

      res.status(500).json({
        success: false,
        error: error instanceof Error ? error.message : 'Internal server error',
      })
    }
  }

  async deleteDeal(req: Request, res: Response) {
    try {
      const { id } = req.params
      const result = await dealService.deleteDeal(id)

      if (!result.success) {
        return res.status(404).json(result)
      }

      res.json(result)
    } catch (error) {
      res.status(500).json({
        success: false,
        error: error instanceof Error ? error.message : 'Internal server error',
      })
    }
  }

  async getDealStats(_req: Request, res: Response) {
    try {
      const result = await dealService.getDealStats()
      res.json(result)
    } catch (error) {
      res.status(500).json({
        success: false,
        error: error instanceof Error ? error.message : 'Internal server error',
      })
    }
  }
}

export default new DealController()
