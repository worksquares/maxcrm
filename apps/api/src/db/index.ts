import { Pool, PoolClient } from 'pg'
import { readFileSync } from 'fs'
import { join } from 'path'
import { fileURLToPath } from 'url'
import { dirname } from 'path'

const __filename = fileURLToPath(import.meta.url)
const __dirname = dirname(__filename)

// PostgreSQL connection pool
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  max: 20, // Maximum number of clients in the pool
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
})

// Handle pool errors
pool.on('error', (err) => {
  console.error('Unexpected error on idle client', err)
  process.exit(-1)
})

// Test database connection
export const testConnection = async (): Promise<boolean> => {
  try {
    const client = await pool.connect()
    await client.query('SELECT NOW()')
    client.release()
    console.log('✓ Database connection successful')
    return true
  } catch (error) {
    console.error('✗ Database connection failed:', error)
    return false
  }
}

// Initialize database schema
export const initializeDatabase = async (): Promise<void> => {
  try {
    const client = await pool.connect()

    // Read and execute schema
    const schemaSQL = readFileSync(join(__dirname, 'schema.sql'), 'utf-8')
    await client.query(schemaSQL)
    console.log('✓ Database schema initialized')

    // Check if we need to seed data
    const result = await client.query('SELECT COUNT(*) FROM users')
    const userCount = parseInt(result.rows[0].count, 10)

    if (userCount === 0) {
      // Read and execute seed data
      const seedSQL = readFileSync(join(__dirname, 'seed.sql'), 'utf-8')
      await client.query(seedSQL)
      console.log('✓ Database seeded with sample data')
    } else {
      console.log('✓ Database already contains data, skipping seed')
    }

    client.release()
  } catch (error) {
    console.error('✗ Database initialization failed:', error)
    throw error
  }
}

// Query helper with automatic connection management
export const query = async <T = any>(
  text: string,
  params?: any[]
): Promise<T[]> => {
  const client = await pool.connect()
  try {
    const result = await client.query(text, params)
    return result.rows
  } finally {
    client.release()
  }
}

// Transaction helper
export const transaction = async <T>(
  callback: (client: PoolClient) => Promise<T>
): Promise<T> => {
  const client = await pool.connect()
  try {
    await client.query('BEGIN')
    const result = await callback(client)
    await client.query('COMMIT')
    return result
  } catch (error) {
    await client.query('ROLLBACK')
    throw error
  } finally {
    client.release()
  }
}

// Close pool on application shutdown
export const closePool = async (): Promise<void> => {
  await pool.end()
  console.log('✓ Database pool closed')
}

export default pool

