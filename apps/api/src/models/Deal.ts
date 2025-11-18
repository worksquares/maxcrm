import { Deal, DealStage } from '@maxcrm/shared'
import db, { generateId } from '../db'

export class DealModel {
  static async findAll(): Promise<Deal[]> {
    return Array.from(db.deals.values())
  }

  static async findById(id: string): Promise<Deal | undefined> {
    return db.deals.get(id)
  }

  static async findByStage(stage: DealStage): Promise<Deal[]> {
    return Array.from(db.deals.values()).filter(deal => deal.stage === stage)
  }

  static async findByContactId(contactId: string): Promise<Deal[]> {
    return Array.from(db.deals.values()).filter(deal => deal.contactId === contactId)
  }

  static async findByCompanyId(companyId: string): Promise<Deal[]> {
    return Array.from(db.deals.values()).filter(deal => deal.companyId === companyId)
  }

  static async create(data: Omit<Deal, 'id' | 'createdAt' | 'updatedAt'>): Promise<Deal> {
    const deal: Deal = {
      ...data,
      id: generateId(),
      createdAt: new Date(),
      updatedAt: new Date(),
    }

    db.deals.set(deal.id, deal)
    return deal
  }

  static async update(id: string, data: Partial<Omit<Deal, 'id' | 'createdAt'>>): Promise<Deal | undefined> {
    const existing = db.deals.get(id)
    if (!existing) {
      return undefined
    }

    const updated: Deal = {
      ...existing,
      ...data,
      id: existing.id,
      createdAt: existing.createdAt,
      updatedAt: new Date(),
    }

    db.deals.set(id, updated)
    return updated
  }

  static async delete(id: string): Promise<boolean> {
    return db.deals.delete(id)
  }

  static async getTotalValue(): Promise<number> {
    return Array.from(db.deals.values()).reduce((sum, deal) => sum + deal.value, 0)
  }

  static async getTotalValueByStage(stage: DealStage): Promise<number> {
    return Array.from(db.deals.values())
      .filter(deal => deal.stage === stage)
      .reduce((sum, deal) => sum + deal.value, 0)
  }
}
