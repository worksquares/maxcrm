import { Contact, Company, Deal, User } from '@maxcrm/shared'

// In-memory database storage
// In production, replace this with a real database (PostgreSQL, MongoDB, etc.)
interface Database {
  contacts: Map<string, Contact>
  companies: Map<string, Company>
  deals: Map<string, Deal>
  users: Map<string, User>
}

const db: Database = {
  contacts: new Map(),
  companies: new Map(),
  deals: new Map(),
  users: new Map(),
}

// Helper function to generate unique IDs
export const generateId = (): string => {
  return `${Date.now()}-${Math.random().toString(36).substr(2, 9)}`
}

// Initialize with some sample data
const initializeData = () => {
  // Sample companies
  const company1: Company = {
    id: generateId(),
    name: 'Acme Corporation',
    website: 'https://acme.example.com',
    industry: 'Technology',
    size: '51-200',
    createdAt: new Date(),
    updatedAt: new Date(),
  }

  const company2: Company = {
    id: generateId(),
    name: 'Global Industries',
    website: 'https://global.example.com',
    industry: 'Manufacturing',
    size: '201+',
    createdAt: new Date(),
    updatedAt: new Date(),
  }

  db.companies.set(company1.id, company1)
  db.companies.set(company2.id, company2)

  // Sample contacts
  const contact1: Contact = {
    id: generateId(),
    firstName: 'John',
    lastName: 'Doe',
    email: 'john.doe@acme.example.com',
    phone: '+1-555-0101',
    companyId: company1.id,
    createdAt: new Date(),
    updatedAt: new Date(),
  }

  const contact2: Contact = {
    id: generateId(),
    firstName: 'Jane',
    lastName: 'Smith',
    email: 'jane.smith@global.example.com',
    phone: '+1-555-0102',
    companyId: company2.id,
    createdAt: new Date(),
    updatedAt: new Date(),
  }

  db.contacts.set(contact1.id, contact1)
  db.contacts.set(contact2.id, contact2)

  // Sample deals
  const deal1: Deal = {
    id: generateId(),
    title: 'Enterprise Software License',
    value: 50000,
    stage: 'proposal' as any,
    contactId: contact1.id,
    companyId: company1.id,
    expectedCloseDate: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000), // 30 days from now
    createdAt: new Date(),
    updatedAt: new Date(),
  }

  const deal2: Deal = {
    id: generateId(),
    title: 'Consulting Services',
    value: 25000,
    stage: 'negotiation' as any,
    contactId: contact2.id,
    companyId: company2.id,
    expectedCloseDate: new Date(Date.now() + 15 * 24 * 60 * 60 * 1000), // 15 days from now
    createdAt: new Date(),
    updatedAt: new Date(),
  }

  db.deals.set(deal1.id, deal1)
  db.deals.set(deal2.id, deal2)

  // Sample user (for authentication)
  const user1: User = {
    id: generateId(),
    email: 'admin@maxcrm.example.com',
    firstName: 'Admin',
    lastName: 'User',
    role: 'admin' as any,
    createdAt: new Date(),
    updatedAt: new Date(),
  }

  db.users.set(user1.id, user1)
}

// Initialize data on startup
initializeData()

export default db
