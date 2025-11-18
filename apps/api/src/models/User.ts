import { User } from '@maxcrm/shared'
import db, { generateId } from '../db'

export class UserModel {
  static async findAll(): Promise<User[]> {
    return Array.from(db.users.values())
  }

  static async findById(id: string): Promise<User | undefined> {
    return db.users.get(id)
  }

  static async findByEmail(email: string): Promise<User | undefined> {
    return Array.from(db.users.values()).find(user => user.email === email)
  }

  static async create(data: Omit<User, 'id' | 'createdAt' | 'updatedAt'>): Promise<User> {
    const user: User = {
      ...data,
      id: generateId(),
      createdAt: new Date(),
      updatedAt: new Date(),
    }

    db.users.set(user.id, user)
    return user
  }

  static async update(id: string, data: Partial<Omit<User, 'id' | 'createdAt'>>): Promise<User | undefined> {
    const existing = db.users.get(id)
    if (!existing) {
      return undefined
    }

    const updated: User = {
      ...existing,
      ...data,
      id: existing.id,
      createdAt: existing.createdAt,
      updatedAt: new Date(),
    }

    db.users.set(id, updated)
    return updated
  }

  static async delete(id: string): Promise<boolean> {
    return db.users.delete(id)
  }
}
