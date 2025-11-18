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
      const userId = req.user!.id
      const page = parseInt(req.query.page as string) || 1
      const limit = parseInt(req.query.limit as string) || 20

      const result = await contactService.getAllContacts(userId, page, limit)
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

  async getContactById(req: Request, res: Response) {
    try {
      const userId = req.user!.id
      const { id } = req.params
      const result = await contactService.getContactById(id, userId)

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

  async getContactsByCompany(req: Request, res: Response) {
    try {
      const userId = req.user!.id
      const { companyId } = req.params
      const result = await contactService.getContactsByCompany(companyId, userId)
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

  async createContact(req: Request, res: Response) {
    try {
      const userId = req.user!.id
      const validatedData = createContactSchema.parse(req.body)
      const result = await contactService.createContact({ ...validatedData, userId })

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

  async updateContact(req: Request, res: Response) {
    try {
      const userId = req.user!.id
      const { id } = req.params
      const validatedData = updateContactSchema.parse(req.body)
      const result = await contactService.updateContact(id, userId, validatedData)

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

  async deleteContact(req: Request, res: Response) {
    try {
      const userId = req.user!.id
      const { id } = req.params
      const result = await contactService.deleteContact(id, userId)

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

  async searchContacts(req: Request, res: Response) {
    try {
      const userId = req.user!.id
      const query = req.query.q as string

      if (!query) {
        return res.status(400).json({
          success: false,
          error: 'Search query is required',
        })
      }

      const result = await contactService.searchContacts(query, userId)
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

export default new ContactController()
