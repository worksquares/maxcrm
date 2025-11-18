import { Contact } from '@maxcrm/shared'
import { query } from '../db'

interface ContactRow {
  id: string
  first_name: string
  last_name: string
  email: string
  phone: string | null
  company_id: string | null
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
  createdAt: row.created_at,
  updatedAt: row.updated_at,
})

export class ContactModel {
  static async findAll(): Promise<Contact[]> {
    const rows = await query<ContactRow>(
      'SELECT * FROM contacts ORDER BY created_at DESC'
    )
    return rows.map(mapRowToContact)
  }

  static async findById(id: string): Promise<Contact | undefined> {
    const rows = await query<ContactRow>(
      'SELECT * FROM contacts WHERE id = $1',
      [id]
    )
    return rows.length > 0 ? mapRowToContact(rows[0]) : undefined
  }

  static async findByCompanyId(companyId: string): Promise<Contact[]> {
    const rows = await query<ContactRow>(
      'SELECT * FROM contacts WHERE company_id = $1 ORDER BY created_at DESC',
      [companyId]
    )
    return rows.map(mapRowToContact)
  }

  static async create(data: Omit<Contact, 'id' | 'createdAt' | 'updatedAt'>): Promise<Contact> {
    const rows = await query<ContactRow>(
      `INSERT INTO contacts (first_name, last_name, email, phone, company_id)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING *`,
      [data.firstName, data.lastName, data.email, data.phone || null, data.companyId || null]
    )
    return mapRowToContact(rows[0])
  }

  static async update(id: string, data: Partial<Omit<Contact, 'id' | 'createdAt'>>): Promise<Contact | undefined> {
    const updates: string[] = []
    const values: any[] = []
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
      values.push(data.phone)
    }
    if (data.companyId !== undefined) {
      updates.push(`company_id = $${paramCount++}`)
      values.push(data.companyId)
    }

    if (updates.length === 0) {
      return this.findById(id)
    }

    values.push(id)
    const rows = await query<ContactRow>(
      `UPDATE contacts SET ${updates.join(', ')} WHERE id = $${paramCount} RETURNING *`,
      values
    )

    return rows.length > 0 ? mapRowToContact(rows[0]) : undefined
  }

  static async delete(id: string): Promise<boolean> {
    const rows = await query<{ id: string }>(
      'DELETE FROM contacts WHERE id = $1 RETURNING id',
      [id]
    )
    return rows.length > 0
  }

  static async search(searchQuery: string): Promise<Contact[]> {
    const rows = await query<ContactRow>(
      `SELECT * FROM contacts
       WHERE first_name ILIKE $1
       OR last_name ILIKE $1
       OR email ILIKE $1
       ORDER BY created_at DESC`,
      [`%${searchQuery}%`]
    )
    return rows.map(mapRowToContact)
  }
}
