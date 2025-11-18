import { Company } from '@maxcrm/shared'
import { query } from '../db'

interface CompanyRow {
  id: string
  name: string
  website: string | null
  industry: string | null
  size: string | null
  user_id: string
  created_at: Date
  updated_at: Date
}

const mapRowToCompany = (row: CompanyRow): Company => ({
  id: row.id,
  name: row.name,
  website: row.website || undefined,
  industry: row.industry || undefined,
  size: row.size || undefined,
  userId: row.user_id,
  createdAt: row.created_at,
  updatedAt: row.updated_at,
})

export class CompanyModel {
  static async findAll(userId: string): Promise<Company[]> {
    const rows = await query<CompanyRow>(
      'SELECT * FROM companies WHERE user_id = $1 ORDER BY created_at DESC',
      [userId]
    )
    return rows.map(mapRowToCompany)
  }

  static async findById(id: string, userId: string): Promise<Company | undefined> {
    const rows = await query<CompanyRow>(
      'SELECT * FROM companies WHERE id = $1 AND user_id = $2',
      [id, userId]
    )
    return rows.length > 0 ? mapRowToCompany(rows[0]) : undefined
  }

  static async create(data: Omit<Company, 'id' | 'createdAt' | 'updatedAt'>): Promise<Company> {
    const rows = await query<CompanyRow>(
      `INSERT INTO companies (name, website, industry, size, user_id)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING *`,
      [data.name, data.website || null, data.industry || null, data.size || null, data.userId]
    )
    return mapRowToCompany(rows[0])
  }

  static async update(id: string, userId: string, data: Partial<Omit<Company, 'id' | 'createdAt' | 'userId'>>): Promise<Company | undefined> {
    const updates: string[] = []
    const values: (string | number | Date | null)[] = []
    let paramCount = 1

    if (data.name !== undefined) {
      updates.push(`name = $${paramCount++}`)
      values.push(data.name)
    }
    if (data.website !== undefined) {
      updates.push(`website = $${paramCount++}`)
      values.push(data.website || null)
    }
    if (data.industry !== undefined) {
      updates.push(`industry = $${paramCount++}`)
      values.push(data.industry || null)
    }
    if (data.size !== undefined) {
      updates.push(`size = $${paramCount++}`)
      values.push(data.size || null)
    }

    if (updates.length === 0) {
      return this.findById(id, userId)
    }

    values.push(id)
    values.push(userId)
    const rows = await query<CompanyRow>(
      `UPDATE companies SET ${updates.join(', ')} WHERE id = $${paramCount++} AND user_id = $${paramCount} RETURNING *`,
      values
    )

    return rows.length > 0 ? mapRowToCompany(rows[0]) : undefined
  }

  static async delete(id: string, userId: string): Promise<boolean> {
    const rows = await query<{ id: string }>(
      'DELETE FROM companies WHERE id = $1 AND user_id = $2 RETURNING id',
      [id, userId]
    )
    return rows.length > 0
  }

  static async search(searchQuery: string, userId: string): Promise<Company[]> {
    const rows = await query<CompanyRow>(
      `SELECT * FROM companies
       WHERE user_id = $1 AND (name ILIKE $2
       OR website ILIKE $2
       OR industry ILIKE $2)
       ORDER BY created_at DESC`,
      [userId, `%${searchQuery}%`]
    )
    return rows.map(mapRowToCompany)
  }
}
