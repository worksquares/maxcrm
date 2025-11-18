import { Request, Response, NextFunction } from 'express'
import jwt from 'jsonwebtoken'
import { User } from '@maxcrm/shared'
import { UserModel } from '../models/User'

// Extend Express Request type to include user
declare global {
  namespace Express {
    interface Request {
      user?: User
    }
  }
}

const JWT_SECRET = process.env.JWT_SECRET

if (!JWT_SECRET) {
  throw new Error('JWT_SECRET environment variable must be set')
}

export interface JWTPayload {
  userId: string
  email: string
  role: string
}

export const authenticateToken = async (req: Request, res: Response, next: NextFunction) => {
  const authHeader = req.headers['authorization']
  const token = authHeader && authHeader.split(' ')[1] // Bearer TOKEN

  if (!token) {
    return res.status(401).json({
      success: false,
      error: 'Access token required',
    })
  }

  try {
    const payload = jwt.verify(token, JWT_SECRET) as JWTPayload

    // Fetch the full user from the database
    const user = await UserModel.findById(payload.userId)

    if (!user) {
      return res.status(403).json({
        success: false,
        error: 'User not found',
      })
    }

    req.user = user
    next()
  } catch (error) {
    if (error instanceof jwt.JsonWebTokenError) {
      return res.status(403).json({
        success: false,
        error: 'Invalid or expired token',
      })
    }
    return res.status(500).json({
      success: false,
      error: 'Authentication failed',
    })
  }
}

export const generateToken = (user: User): string => {
  const payload: JWTPayload = {
    userId: user.id,
    email: user.email,
    role: user.role,
  }

  const expiresIn: string = process.env.JWT_EXPIRES_IN || '7d'

  return jwt.sign(payload, JWT_SECRET, { expiresIn } as jwt.SignOptions)
}
