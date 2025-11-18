import { Contact } from '@maxcrm/shared'
import { query } from '../db'

interface ContactRow {
  id: string
  first_name: string
  last_name: string
  email: string
  phone: string | null
  company_id: string | null
  user_id: string
  created_at: Date
  updated_at: Date
}

const mapRowToContact = (row: ContactRow): Contact => ({
  id: row.id,
  firstName: row.first_name,
  lastName: row.last_name,
  email: row.email,
  phone: row.phone || undefined,
  companyId: row.company_id || undefined,
  userId: row.user_id,
  createdAt: row.created_at,
  updatedAt: row.updated_at,
})

export class ContactModel {
  static async findAll(userId: string): Promise<Contact[]> {
    const rows = await query<ContactRow>(
      'SELECT * FROM contacts WHERE user_id = $1 ORDER BY created_at DESC',
      [userId]
    )
    return rows.map(mapRowToContact)
  }

  static async findById(id: string, userId: string): Promise<Contact | undefined> {
    const rows = await query<ContactRow>(
      'SELECT * FROM contacts WHERE id = $1 AND user_id = $2',
      [id, userId]
    )
    return rows.length > 0 ? mapRowToContact(rows[0]) : undefined
  }

  static async findByCompanyId(companyId: string, userId: string): Promise<Contact[]> {
    const rows = await query<ContactRow>(
      'SELECT * FROM contacts WHERE company_id = $1 AND user_id = $2 ORDER BY created_at DESC',
      [companyId, userId]
    )
    return rows.map(mapRowToContact)
  }

  static async create(data: Omit<Contact, 'id' | 'createdAt' | 'updatedAt'>): Promise<Contact> {
    const rows = await query<ContactRow>(
      `INSERT INTO contacts (first_name, last_name, email, phone, company_id, user_id)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING *`,
      [data.firstName, data.lastName, data.email, data.phone || null, data.companyId || null, data.userId]
    )
    return mapRowToContact(rows[0])
  }

  static async update(id: string, userId: string, data: Partial<Omit<Contact, 'id' | 'createdAt' | 'userId'>>): Promise<Contact | undefined> {
    const updates: string[] = []
    const values: (string | null)[] = []
    let paramCount = 1

    if (data.firstName !== undefined) {
      updates.push(`first_name = $${paramCount++}`)
      values.push(data.firstName)
    }
    if (data.lastName !== undefined) {
      updates.push(`last_name = $${paramCount++}`)
      values.push(data.lastName)
    }
    if (data.email !== undefined) {
      updates.push(`email = $${paramCount++}`)
      values.push(data.email)
    }
    if (data.phone !== undefined) {
      updates.push(`phone = $${paramCount++}`)
      values.push(data.phone || null)
    }
    if (data.companyId !== undefined) {
      updates.push(`company_id = $${paramCount++}`)
      values.push(data.companyId || null)
    }

    if (updates.length === 0) {
      return this.findById(id, userId)
    }

    values.push(id)
    values.push(userId)
    const rows = await query<ContactRow>(
      `UPDATE contacts SET ${updates.join(', ')} WHERE id = $${paramCount++} AND user_id = $${paramCount} RETURNING *`,
      values
    )

    return rows.length > 0 ? mapRowToContact(rows[0]) : undefined
  }

  static async delete(id: string, userId: string): Promise<boolean> {
    const rows = await query<{ id: string }>(
      'DELETE FROM contacts WHERE id = $1 AND user_id = $2 RETURNING id',
      [id, userId]
    )
    return rows.length > 0
  }

  static async search(searchQuery: string, userId: string): Promise<Contact[]> {
    const rows = await query<ContactRow>(
      `SELECT * FROM contacts
       WHERE user_id = $1 AND (first_name ILIKE $2
       OR last_name ILIKE $2
       OR email ILIKE $2)
       ORDER BY created_at DESC`,
      [userId, `%${searchQuery}%`]
    )
    return rows.map(mapRowToContact)
  }
}
