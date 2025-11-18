import { Request, Response } from 'express'
import { z } from 'zod'
import bcrypt from 'bcrypt'
import { UserModel } from '../models/User'
import { generateToken } from '../middleware/auth'
import { UserRole } from '@maxcrm/shared'

// Validation schemas
const registerSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
  firstName: z.string().min(1),
  lastName: z.string().min(1),
  role: z.nativeEnum(UserRole).optional(),
})

const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(1),
})

// In-memory password storage (in production, store hashed passwords in database)
const passwordStore = new Map<string, string>()

export class AuthController {
  async register(req: Request, res: Response) {
    try {
      const validatedData = registerSchema.parse(req.body)

      // Check if user already exists
      const existingUser = await UserModel.findByEmail(validatedData.email)
      if (existingUser) {
        return res.status(400).json({
          success: false,
          error: 'User with this email already exists',
        })
      }

      // Hash password
      const hashedPassword = await bcrypt.hash(validatedData.password, 10)

      // Create user
      const user = await UserModel.create({
        email: validatedData.email,
        firstName: validatedData.firstName,
        lastName: validatedData.lastName,
        role: validatedData.role || UserRole.USER,
      })

      // Store password (in production, this would be in the database)
      passwordStore.set(user.id, hashedPassword)

      // Generate token
      const token = generateToken(user)

      res.status(201).json({
        success: true,
        data: {
          user: {
            id: user.id,
            email: user.email,
            firstName: user.firstName,
            lastName: user.lastName,
            role: user.role,
          },
          token,
        },
        message: 'User registered successfully',
      })
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

  async login(req: Request, res: Response) {
    try {
      const validatedData = loginSchema.parse(req.body)

      // Find user
      const user = await UserModel.findByEmail(validatedData.email)
      if (!user) {
        return res.status(401).json({
          success: false,
          error: 'Invalid credentials',
        })
      }

      // Verify password
      const hashedPassword = passwordStore.get(user.id)
      if (!hashedPassword) {
        // For demo purposes, allow login without password for existing users
        // In production, this should always be checked
        if (user.email !== 'admin@maxcrm.example.com') {
          return res.status(401).json({
            success: false,
            error: 'Invalid credentials',
          })
        }
      } else {
        const isPasswordValid = await bcrypt.compare(validatedData.password, hashedPassword)
        if (!isPasswordValid) {
          return res.status(401).json({
            success: false,
            error: 'Invalid credentials',
          })
        }
      }

      // Generate token
      const token = generateToken(user)

      res.json({
        success: true,
        data: {
          user: {
            id: user.id,
            email: user.email,
            firstName: user.firstName,
            lastName: user.lastName,
            role: user.role,
          },
          token,
        },
        message: 'Login successful',
      })
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

  async getCurrentUser(req: Request, res: Response) {
    try {
      if (!req.user) {
        return res.status(401).json({
          success: false,
          error: 'Not authenticated',
        })
      }

      // Fetch full user data
      const user = await UserModel.findById(req.user.id)
      if (!user) {
        return res.status(404).json({
          success: false,
          error: 'User not found',
        })
      }

      res.json({
        success: true,
        data: {
          id: user.id,
          email: user.email,
          firstName: user.firstName,
          lastName: user.lastName,
          role: user.role,
        },
      })
    } catch (error) {
      res.status(500).json({
        success: false,
        error: error instanceof Error ? error.message : 'Internal server error',
      })
    }
  }
}

export default new AuthController()
