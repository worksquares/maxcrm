import { Company } from '@maxcrm/shared'
import { query } from '../db'

interface CompanyRow {
  id: string
  name: string
  website: string | null
  industry: string | null
  size: string | null
  created_at: Date
  updated_at: Date
}

const mapRowToCompany = (row: CompanyRow): Company => ({
  id: row.id,
  name: row.name,
  website: row.website || undefined,
  industry: row.industry || undefined,
  size: row.size || undefined,
  createdAt: row.created_at,
  updatedAt: row.updated_at,
})

export class CompanyModel {
  static async findAll(): Promise<Company[]> {
    const rows = await query<CompanyRow>(
      'SELECT * FROM companies ORDER BY created_at DESC'
    )
    return rows.map(mapRowToCompany)
  }

  static async findById(id: string): Promise<Company | undefined> {
    const rows = await query<CompanyRow>(
      'SELECT * FROM companies WHERE id = $1',
      [id]
    )
    return rows.length > 0 ? mapRowToCompany(rows[0]) : undefined
  }

  static async create(data: Omit<Company, 'id' | 'createdAt' | 'updatedAt'>): Promise<Company> {
    const rows = await query<CompanyRow>(
      `INSERT INTO companies (name, website, industry, size)
       VALUES ($1, $2, $3, $4)
       RETURNING *`,
      [data.name, data.website || null, data.industry || null, data.size || null]
    )
    return mapRowToCompany(rows[0])
  }

  static async update(id: string, data: Partial<Omit<Company, 'id' | 'createdAt'>>): Promise<Company | undefined> {
    const updates: string[] = []
    const values: any[] = []
    let paramCount = 1

    if (data.name !== undefined) {
      updates.push(`name = $${paramCount++}`)
      values.push(data.name)
    }
    if (data.website !== undefined) {
      updates.push(`website = $${paramCount++}`)
      values.push(data.website)
    }
    if (data.industry !== undefined) {
      updates.push(`industry = $${paramCount++}`)
      values.push(data.industry)
    }
    if (data.size !== undefined) {
      updates.push(`size = $${paramCount++}`)
      values.push(data.size)
    }

    if (updates.length === 0) {
      return this.findById(id)
    }

    values.push(id)
    const rows = await query<CompanyRow>(
      `UPDATE companies SET ${updates.join(', ')} WHERE id = $${paramCount} RETURNING *`,
      values
    )

    return rows.length > 0 ? mapRowToCompany(rows[0]) : undefined
  }

  static async delete(id: string): Promise<boolean> {
    const rows = await query<{ id: string }>(
      'DELETE FROM companies WHERE id = $1 RETURNING id',
      [id]
    )
    return rows.length > 0
  }

  static async search(searchQuery: string): Promise<Company[]> {
    const rows = await query<CompanyRow>(
      `SELECT * FROM companies
       WHERE name ILIKE $1
       OR website ILIKE $1
       OR industry ILIKE $1
       ORDER BY created_at DESC`,
      [`%${searchQuery}%`]
    )
    return rows.map(mapRowToCompany)
  }
}
