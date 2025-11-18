import { User, UserRole } from '@maxcrm/shared'
import { query } from '../db'

interface UserRow {
  id: string
  email: string
  password_hash: string
  first_name: string
  last_name: string
  role: UserRole
  created_at: Date
  updated_at: Date
}

const mapRowToUser = (row: UserRow): User => ({
  id: row.id,
  email: row.email,
  firstName: row.first_name,
  lastName: row.last_name,
  role: row.role,
  createdAt: row.created_at,
  updatedAt: row.updated_at,
})

export class UserModel {
  static async findAll(): Promise<User[]> {
    const rows = await query<UserRow>(
      'SELECT id, email, first_name, last_name, role, created_at, updated_at FROM users ORDER BY created_at DESC'
    )
    return rows.map(mapRowToUser)
  }

  static async findById(id: string): Promise<User | undefined> {
    const rows = await query<UserRow>(
      'SELECT id, email, first_name, last_name, role, created_at, updated_at FROM users WHERE id = $1',
      [id]
    )
    return rows.length > 0 ? mapRowToUser(rows[0]) : undefined
  }

  static async findByEmail(email: string): Promise<User | undefined> {
    const rows = await query<UserRow>(
      'SELECT id, email, first_name, last_name, role, created_at, updated_at FROM users WHERE email = $1',
      [email]
    )
    return rows.length > 0 ? mapRowToUser(rows[0]) : undefined
  }

  static async findByEmailWithPassword(email: string): Promise<(User & { passwordHash: string }) | undefined> {
    const rows = await query<UserRow>(
      'SELECT * FROM users WHERE email = $1',
      [email]
    )
    if (rows.length === 0) {
      return undefined
    }
    const row = rows[0]
    return {
      ...mapRowToUser(row),
      passwordHash: row.password_hash,
    }
  }

  static async create(
    data: Omit<User, 'id' | 'createdAt' | 'updatedAt'>,
    passwordHash: string
  ): Promise<User> {
    const rows = await query<UserRow>(
      `INSERT INTO users (email, password_hash, first_name, last_name, role)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING id, email, first_name, last_name, role, created_at, updated_at`,
      [data.email, passwordHash, data.firstName, data.lastName, data.role]
    )
    return mapRowToUser(rows[0])
  }

  static async update(id: string, data: Partial<Omit<User, 'id' | 'createdAt'>>): Promise<User | undefined> {
    const updates: string[] = []
    const values: any[] = []
    let paramCount = 1

    if (data.email !== undefined) {
      updates.push(`email = $${paramCount++}`)
      values.push(data.email)
    }
    if (data.firstName !== undefined) {
      updates.push(`first_name = $${paramCount++}`)
      values.push(data.firstName)
    }
    if (data.lastName !== undefined) {
      updates.push(`last_name = $${paramCount++}`)
      values.push(data.lastName)
    }
    if (data.role !== undefined) {
      updates.push(`role = $${paramCount++}`)
      values.push(data.role)
    }

    if (updates.length === 0) {
      return this.findById(id)
    }

    values.push(id)
    const rows = await query<UserRow>(
      `UPDATE users SET ${updates.join(', ')} WHERE id = $${paramCount}
       RETURNING id, email, first_name, last_name, role, created_at, updated_at`,
      values
    )

    return rows.length > 0 ? mapRowToUser(rows[0]) : undefined
  }

  static async delete(id: string): Promise<boolean> {
    const rows = await query<{ id: string }>(
      'DELETE FROM users WHERE id = $1 RETURNING id',
      [id]
    )
    return rows.length > 0
  }
}
