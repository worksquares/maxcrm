import express, { Express, Request, Response } from 'express'
import cors from 'cors'
import helmet from 'helmet'
import morgan from 'morgan'
import dotenv from 'dotenv'
import { errorHandler } from './middleware/errorHandler.js'
import apiRoutes from './routes/index.js'
import { testConnection, initializeDatabase, closePool } from './db/index.js'

dotenv.config()

const app: Express = express()
const port = process.env.PORT || 4000

// Middleware
app.use(helmet())
app.use(cors({
  origin: process.env.CORS_ORIGIN || 'http://localhost:3000',
  credentials: true,
}))
app.use(morgan('dev'))
app.use(express.json())
app.use(express.urlencoded({ extended: true }))

// Health check
app.get('/health', (_req: Request, res: Response) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() })
})

// API Routes
app.use('/api', apiRoutes)

// Error handling
app.use(errorHandler)

// Initialize database and start server
const startServer = async () => {
  try {
    // Test database connection
    const isConnected = await testConnection()
    if (!isConnected) {
      console.error('Failed to connect to database. Please check your DATABASE_URL environment variable.')
      process.exit(1)
    }

    // Initialize database schema and seed data
    await initializeDatabase()

    // Start HTTP server
    app.listen(port, () => {
      console.log(`⚡️ [server]: Server is running at http://localhost:${port}`)
    })
  } catch (error) {
    console.error('Failed to start server:', error)
    process.exit(1)
  }
}

// Handle graceful shutdown
process.on('SIGINT', async () => {
  console.log('\n⏳ Shutting down gracefully...')
  await closePool()
  process.exit(0)
})

process.on('SIGTERM', async () => {
  console.log('\n⏳ Shutting down gracefully...')
  await closePool()
  process.exit(0)
})

// Start the server
startServer()
