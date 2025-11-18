import { Request, Response } from 'express'
import companyService from '../services/companyService'
import { z } from 'zod'

// Validation schemas
const createCompanySchema = z.object({
  name: z.string().min(1),
  website: z.string().url().optional(),
  industry: z.string().optional(),
  size: z.string().optional(),
})

const updateCompanySchema = z.object({
  name: z.string().min(1).optional(),
  website: z.string().url().optional(),
  industry: z.string().optional(),
  size: z.string().optional(),
})

export class CompanyController {
  async getAllCompanies(req: Request, res: Response) {
    try {
      const userId = req.user!.id
      const page = parseInt(req.query.page as string) || 1
      const limit = parseInt(req.query.limit as string) || 20

      const result = await companyService.getAllCompanies(userId, page, limit)
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

  async getCompanyById(req: Request, res: Response) {
    try {
      const userId = req.user!.id
      const { id } = req.params
      const result = await companyService.getCompanyById(id, userId)

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

  async createCompany(req: Request, res: Response) {
    try {
      const userId = req.user!.id
      const validatedData = createCompanySchema.parse(req.body)
      const result = await companyService.createCompany({ ...validatedData, userId })

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

  async updateCompany(req: Request, res: Response) {
    try {
      const userId = req.user!.id
      const { id } = req.params
      const validatedData = updateCompanySchema.parse(req.body)
      const result = await companyService.updateCompany(id, userId, validatedData)

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

  async deleteCompany(req: Request, res: Response) {
    try {
      const userId = req.user!.id
      const { id } = req.params
      const result = await companyService.deleteCompany(id, userId)

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

  async searchCompanies(req: Request, res: Response) {
    try {
      const userId = req.user!.id
      const query = req.query.q as string

      if (!query) {
        return res.status(400).json({
          success: false,
          error: 'Search query is required',
        })
      }

      const result = await companyService.searchCompanies(query, userId)
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

export default new CompanyController()
