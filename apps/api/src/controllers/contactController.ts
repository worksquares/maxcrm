import { Request, Response } from 'express'
import contactService from '../services/contactService'
import { z } from 'zod'

// Validation schemas
const createContactSchema = z.object({
  firstName: z.string().min(1),
  lastName: z.string().min(1),
  email: z.string().email(),
  phone: z.string().optional(),
  companyId: z.string().optional(),
})

const updateContactSchema = z.object({
  firstName: z.string().min(1).optional(),
  lastName: z.string().min(1).optional(),
  email: z.string().email().optional(),
  phone: z.string().optional(),
  companyId: z.string().optional(),
})

export class ContactController {
  async getAllContacts(req: Request, res: Response) {
    try {
      const page = parseInt(req.query.page as string) || 1
      const limit = parseInt(req.query.limit as string) || 20

      const result = await contactService.getAllContacts(page, limit)
      res.json(result)
    } catch (error) {
      res.status(500).json({
        success: false,
        error: error instanceof Error ? error.message : 'Internal server error',
      })
    }
  }

  async getContactById(req: Request, res: Response) {
    try {
      const { id } = req.params
      const result = await contactService.getContactById(id)

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

  async getContactsByCompany(req: Request, res: Response) {
    try {
      const { companyId } = req.params
      const result = await contactService.getContactsByCompany(companyId)
      res.json(result)
    } catch (error) {
      res.status(500).json({
        success: false,
        error: error instanceof Error ? error.message : 'Internal server error',
      })
    }
  }

  async createContact(req: Request, res: Response) {
    try {
      const validatedData = createContactSchema.parse(req.body)
      const result = await contactService.createContact(validatedData)

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

  async updateContact(req: Request, res: Response) {
    try {
      const { id } = req.params
      const validatedData = updateContactSchema.parse(req.body)
      const result = await contactService.updateContact(id, validatedData)

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

  async deleteContact(req: Request, res: Response) {
    try {
      const { id } = req.params
      const result = await contactService.deleteContact(id)

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

  async searchContacts(req: Request, res: Response) {
    try {
      const query = req.query.q as string

      if (!query) {
        return res.status(400).json({
          success: false,
          error: 'Search query is required',
        })
      }

      const result = await contactService.searchContacts(query)
      res.json(result)
    } catch (error) {
      res.status(500).json({
        success: false,
        error: error instanceof Error ? error.message : 'Internal server error',
      })
    }
  }
}

export default new ContactController()
