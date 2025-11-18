import { Company } from '@maxcrm/shared'
import db, { generateId } from '../db'

export class CompanyModel {
  static async findAll(): Promise<Company[]> {
    return Array.from(db.companies.values())
  }

  static async findById(id: string): Promise<Company | undefined> {
    return db.companies.get(id)
  }

  static async create(data: Omit<Company, 'id' | 'createdAt' | 'updatedAt'>): Promise<Company> {
    const company: Company = {
      ...data,
      id: generateId(),
      createdAt: new Date(),
      updatedAt: new Date(),
    }

    db.companies.set(company.id, company)
    return company
  }

  static async update(id: string, data: Partial<Omit<Company, 'id' | 'createdAt'>>): Promise<Company | undefined> {
    const existing = db.companies.get(id)
    if (!existing) {
      return undefined
    }

    const updated: Company = {
      ...existing,
      ...data,
      id: existing.id,
      createdAt: existing.createdAt,
      updatedAt: new Date(),
    }

    db.companies.set(id, updated)
    return updated
  }

  static async delete(id: string): Promise<boolean> {
    return db.companies.delete(id)
  }

  static async search(query: string): Promise<Company[]> {
    const lowerQuery = query.toLowerCase()
    return Array.from(db.companies.values()).filter(company =>
      company.name.toLowerCase().includes(lowerQuery) ||
      (company.website && company.website.toLowerCase().includes(lowerQuery)) ||
      (company.industry && company.industry.toLowerCase().includes(lowerQuery))
    )
  }
}
