import { Router, Request, Response } from 'express'
import contactController from '../controllers/contactController'
import companyController from '../controllers/companyController'
import dealController from '../controllers/dealController'
import authController from '../controllers/authController'
import { authenticateToken } from '../middleware/auth'

const router = Router()

// Welcome route
router.get('/', (_req: Request, res: Response) => {
  res.json({
    message: 'Welcome to MAXCRM API',
    version: '0.0.1',
    endpoints: {
      health: '/health',
      api: '/api',
      auth: {
        register: '/api/auth/register',
        login: '/api/auth/login',
        me: '/api/auth/me',
      },
      contacts: '/api/contacts',
      companies: '/api/companies',
      deals: '/api/deals',
    },
  })
})

// Auth routes (public)
router.post('/auth/register', authController.register.bind(authController))
router.post('/auth/login', authController.login.bind(authController))
router.get('/auth/me', authenticateToken, authController.getCurrentUser.bind(authController))

// Contact routes
router.get('/contacts', contactController.getAllContacts.bind(contactController))
router.get('/contacts/search', contactController.searchContacts.bind(contactController))
router.get('/contacts/:id', contactController.getContactById.bind(contactController))
router.post('/contacts', contactController.createContact.bind(contactController))
router.put('/contacts/:id', contactController.updateContact.bind(contactController))
router.delete('/contacts/:id', contactController.deleteContact.bind(contactController))

// Company routes
router.get('/companies', companyController.getAllCompanies.bind(companyController))
router.get('/companies/search', companyController.searchCompanies.bind(companyController))
router.get('/companies/:id', companyController.getCompanyById.bind(companyController))
router.get('/companies/:companyId/contacts', contactController.getContactsByCompany.bind(contactController))
router.post('/companies', companyController.createCompany.bind(companyController))
router.put('/companies/:id', companyController.updateCompany.bind(companyController))
router.delete('/companies/:id', companyController.deleteCompany.bind(companyController))

// Deal routes
router.get('/deals', dealController.getAllDeals.bind(dealController))
router.get('/deals/stats', dealController.getDealStats.bind(dealController))
router.get('/deals/stage/:stage', dealController.getDealsByStage.bind(dealController))
router.get('/deals/:id', dealController.getDealById.bind(dealController))
router.get('/deals/contact/:contactId', dealController.getDealsByContact.bind(dealController))
router.get('/deals/company/:companyId', dealController.getDealsByCompany.bind(dealController))
router.post('/deals', dealController.createDeal.bind(dealController))
router.put('/deals/:id', dealController.updateDeal.bind(dealController))
router.delete('/deals/:id', dealController.deleteDeal.bind(dealController))

export default router
