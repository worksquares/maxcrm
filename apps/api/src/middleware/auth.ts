import { Request, Response, NextFunction } from 'express'
import jwt from 'jsonwebtoken'
import { User } from '@maxcrm/shared'

// Extend Express Request type to include user
declare global {
  namespace Express {
    interface Request {
      user?: User
    }
  }
}

const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key-change-in-production'

export interface JWTPayload {
  userId: string
  email: string
  role: string
}

export const authenticateToken = (req: Request, res: Response, next: NextFunction) => {
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

    // In a real application, you would fetch the full user from the database
    // For now, we'll attach the payload to the request
    req.user = {
      id: payload.userId,
      email: payload.email,
      role: payload.role as any,
      firstName: '',
      lastName: '',
      createdAt: new Date(),
      updatedAt: new Date(),
    }

    next()
  } catch (error) {
    return res.status(403).json({
      success: false,
      error: 'Invalid or expired token',
    })
  }
}

export const generateToken = (user: User): string => {
  const payload: JWTPayload = {
    userId: user.id,
    email: user.email,
    role: user.role,
  }

  const expiresIn = process.env.JWT_EXPIRES_IN || '7d'

  return jwt.sign(payload, JWT_SECRET, { expiresIn } as any)
}
