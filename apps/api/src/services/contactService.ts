import { Contact, ApiResponse, PaginatedResponse, DEFAULT_PAGE_SIZE } from '@maxcrm/shared'
import { ContactModel } from '../models/Contact'

export class ContactService {
  async getAllContacts(userId: string, page = 1, limit = DEFAULT_PAGE_SIZE): Promise<PaginatedResponse<Contact>> {
    const allContacts = await ContactModel.findAll(userId)
    const total = allContacts.length
    const totalPages = Math.ceil(total / limit)
    const startIndex = (page - 1) * limit
    const endIndex = startIndex + limit
    const paginatedContacts = allContacts.slice(startIndex, endIndex)

    return {
      success: true,
      data: paginatedContacts,
      pagination: {
        page,
        limit,
        total,
        totalPages,
      },
    }
  }

  async getContactById(id: string, userId: string): Promise<ApiResponse<Contact>> {
    const contact = await ContactModel.findById(id, userId)

    if (!contact) {
      return {
        success: false,
        error: 'Contact not found',
      }
    }

    return {
      success: true,
      data: contact,
    }
  }

  async getContactsByCompany(companyId: string, userId: string): Promise<ApiResponse<Contact[]>> {
    const contacts = await ContactModel.findByCompanyId(companyId, userId)

    return {
      success: true,
      data: contacts,
    }
  }

  async createContact(data: Omit<Contact, 'id' | 'createdAt' | 'updatedAt'>): Promise<ApiResponse<Contact>> {
    try {
      const contact = await ContactModel.create(data)

      return {
        success: true,
        data: contact,
        message: 'Contact created successfully',
      }
    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Failed to create contact',
      }
    }
  }

  async updateContact(id: string, userId: string, data: Partial<Omit<Contact, 'id' | 'createdAt'>>): Promise<ApiResponse<Contact>> {
    const contact = await ContactModel.update(id, userId, data)

    if (!contact) {
      return {
        success: false,
        error: 'Contact not found',
      }
    }

    return {
      success: true,
      data: contact,
      message: 'Contact updated successfully',
    }
  }

  async deleteContact(id: string, userId: string): Promise<ApiResponse<void>> {
    const deleted = await ContactModel.delete(id, userId)

    if (!deleted) {
      return {
        success: false,
        error: 'Contact not found',
      }
    }

    return {
      success: true,
      message: 'Contact deleted successfully',
    }
  }

  async searchContacts(query: string, userId: string): Promise<ApiResponse<Contact[]>> {
    const contacts = await ContactModel.search(query, userId)

    return {
      success: true,
      data: contacts,
    }
  }
}

export default new ContactService()
