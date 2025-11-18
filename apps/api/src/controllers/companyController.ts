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
      const page = parseInt(req.query.page as string) || 1
      const limit = parseInt(req.query.limit as string) || 20

      const result = await companyService.getAllCompanies(page, limit)
      res.json(result)
    } catch (error) {
      res.status(500).json({
        success: false,
        error: error instanceof Error ? error.message : 'Internal server error',
      })
    }
  }

  async getCompanyById(req: Request, res: Response) {
    try {
      const { id } = req.params
      const result = await companyService.getCompanyById(id)

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

  async createCompany(req: Request, res: Response) {
    try {
      const validatedData = createCompanySchema.parse(req.body)
      const result = await companyService.createCompany(validatedData)

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

  async updateCompany(req: Request, res: Response) {
    try {
      const { id } = req.params
      const validatedData = updateCompanySchema.parse(req.body)
      const result = await companyService.updateCompany(id, validatedData)

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

  async deleteCompany(req: Request, res: Response) {
    try {
      const { id } = req.params
      const result = await companyService.deleteCompany(id)

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

  async searchCompanies(req: Request, res: Response) {
    try {
      const query = req.query.q as string

      if (!query) {
        return res.status(400).json({
          success: false,
          error: 'Search query is required',
        })
      }

      const result = await companyService.searchCompanies(query)
      res.json(result)
    } catch (error) {
      res.status(500).json({
        success: false,
        error: error instanceof Error ? error.message : 'Internal server error',
      })
    }
  }
}

export default new CompanyController()
