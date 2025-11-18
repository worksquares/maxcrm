import { Contact } from '@maxcrm/shared'
import db, { generateId } from '../db'

export class ContactModel {
  static async findAll(): Promise<Contact[]> {
    return Array.from(db.contacts.values())
  }

  static async findById(id: string): Promise<Contact | undefined> {
    return db.contacts.get(id)
  }

  static async findByCompanyId(companyId: string): Promise<Contact[]> {
    return Array.from(db.contacts.values()).filter(
      contact => contact.companyId === companyId
    )
  }

  static async create(data: Omit<Contact, 'id' | 'createdAt' | 'updatedAt'>): Promise<Contact> {
    const contact: Contact = {
      ...data,
      id: generateId(),
      createdAt: new Date(),
      updatedAt: new Date(),
    }

    db.contacts.set(contact.id, contact)
    return contact
  }

  static async update(id: string, data: Partial<Omit<Contact, 'id' | 'createdAt'>>): Promise<Contact | undefined> {
    const existing = db.contacts.get(id)
    if (!existing) {
      return undefined
    }

    const updated: Contact = {
      ...existing,
      ...data,
      id: existing.id,
      createdAt: existing.createdAt,
      updatedAt: new Date(),
    }

    db.contacts.set(id, updated)
    return updated
  }

  static async delete(id: string): Promise<boolean> {
    return db.contacts.delete(id)
  }

  static async search(query: string): Promise<Contact[]> {
    const lowerQuery = query.toLowerCase()
    return Array.from(db.contacts.values()).filter(contact =>
      contact.firstName.toLowerCase().includes(lowerQuery) ||
      contact.lastName.toLowerCase().includes(lowerQuery) ||
      contact.email.toLowerCase().includes(lowerQuery)
    )
  }
}
