import { Deal, DealStage } from '@maxcrm/shared'
import { query } from '../db'

interface DealRow {
  id: string
  title: string
  value: string
  stage: DealStage
  contact_id: string | null
  company_id: string | null
  expected_close_date: Date | null
  created_at: Date
  updated_at: Date
}

const mapRowToDeal = (row: DealRow): Deal => ({
  id: row.id,
  title: row.title,
  value: parseFloat(row.value),
  stage: row.stage,
  contactId: row.contact_id || undefined,
  companyId: row.company_id || undefined,
  expectedCloseDate: row.expected_close_date || undefined,
  createdAt: row.created_at,
  updatedAt: row.updated_at,
})

export class DealModel {
  static async findAll(): Promise<Deal[]> {
    const rows = await query<DealRow>(
      'SELECT * FROM deals ORDER BY created_at DESC'
    )
    return rows.map(mapRowToDeal)
  }

  static async findById(id: string): Promise<Deal | undefined> {
    const rows = await query<DealRow>(
      'SELECT * FROM deals WHERE id = $1',
      [id]
    )
    return rows.length > 0 ? mapRowToDeal(rows[0]) : undefined
  }

  static async findByStage(stage: DealStage): Promise<Deal[]> {
    const rows = await query<DealRow>(
      'SELECT * FROM deals WHERE stage = $1 ORDER BY created_at DESC',
      [stage]
    )
    return rows.map(mapRowToDeal)
  }

  static async findByContactId(contactId: string): Promise<Deal[]> {
    const rows = await query<DealRow>(
      'SELECT * FROM deals WHERE contact_id = $1 ORDER BY created_at DESC',
      [contactId]
    )
    return rows.map(mapRowToDeal)
  }

  static async findByCompanyId(companyId: string): Promise<Deal[]> {
    const rows = await query<DealRow>(
      'SELECT * FROM deals WHERE company_id = $1 ORDER BY created_at DESC',
      [companyId]
    )
    return rows.map(mapRowToDeal)
  }

  static async create(data: Omit<Deal, 'id' | 'createdAt' | 'updatedAt'>): Promise<Deal> {
    const rows = await query<DealRow>(
      `INSERT INTO deals (title, value, stage, contact_id, company_id, expected_close_date)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING *`,
      [
        data.title,
        data.value,
        data.stage,
        data.contactId || null,
        data.companyId || null,
        data.expectedCloseDate || null,
      ]
    )
    return mapRowToDeal(rows[0])
  }

  static async update(id: string, data: Partial<Omit<Deal, 'id' | 'createdAt'>>): Promise<Deal | undefined> {
    const updates: string[] = []
    const values: any[] = []
    let paramCount = 1

    if (data.title !== undefined) {
      updates.push(`title = $${paramCount++}`)
      values.push(data.title)
    }
    if (data.value !== undefined) {
      updates.push(`value = $${paramCount++}`)
      values.push(data.value)
    }
    if (data.stage !== undefined) {
      updates.push(`stage = $${paramCount++}`)
      values.push(data.stage)
    }
    if (data.contactId !== undefined) {
      updates.push(`contact_id = $${paramCount++}`)
      values.push(data.contactId)
    }
    if (data.companyId !== undefined) {
      updates.push(`company_id = $${paramCount++}`)
      values.push(data.companyId)
    }
    if (data.expectedCloseDate !== undefined) {
      updates.push(`expected_close_date = $${paramCount++}`)
      values.push(data.expectedCloseDate)
    }

    if (updates.length === 0) {
      return this.findById(id)
    }

    values.push(id)
    const rows = await query<DealRow>(
      `UPDATE deals SET ${updates.join(', ')} WHERE id = $${paramCount} RETURNING *`,
      values
    )

    return rows.length > 0 ? mapRowToDeal(rows[0]) : undefined
  }

  static async delete(id: string): Promise<boolean> {
    const rows = await query<{ id: string }>(
      'DELETE FROM deals WHERE id = $1 RETURNING id',
      [id]
    )
    return rows.length > 0
  }

  static async getTotalValue(): Promise<number> {
    const rows = await query<{ total: string | null }>(
      'SELECT SUM(value) as total FROM deals'
    )
    return rows[0].total ? parseFloat(rows[0].total) : 0
  }

  static async getTotalValueByStage(stage: DealStage): Promise<number> {
    const rows = await query<{ total: string | null }>(
      'SELECT SUM(value) as total FROM deals WHERE stage = $1',
      [stage]
    )
    return rows[0].total ? parseFloat(rows[0].total) : 0
  }
}
