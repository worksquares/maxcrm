import { Router, Request, Response } from 'express'

const router = Router()

// Welcome route
router.get('/', (_req: Request, res: Response) => {
  res.json({
    message: 'Welcome to MAXCRM API',
    version: '0.0.1',
    endpoints: {
      health: '/health',
      api: '/api',
    },
  })
})

// Example routes - expand as needed
router.get('/contacts', (_req: Request, res: Response) => {
  res.json({
    message: 'Contacts endpoint - to be implemented',
    data: [],
  })
})

router.get('/companies', (_req: Request, res: Response) => {
  res.json({
    message: 'Companies endpoint - to be implemented',
    data: [],
  })
})

router.get('/deals', (_req: Request, res: Response) => {
  res.json({
    message: 'Deals endpoint - to be implemented',
    data: [],
  })
})

export default router
