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

// Auth routes
router.post('/auth/register', authController.register.bind(authController))
router.post('/auth/login', authController.login.bind(authController))
router.post('/auth/logout', authenticateToken, authController.logout.bind(authController))
router.get('/auth/me', authenticateToken, authController.getCurrentUser.bind(authController))

// Contact routes
router.get('/contacts', authenticateToken, contactController.getAllContacts.bind(contactController))
router.get('/contacts/search', authenticateToken, contactController.searchContacts.bind(contactController))
router.get('/contacts/:id', authenticateToken, contactController.getContactById.bind(contactController))
router.post('/contacts', authenticateToken, contactController.createContact.bind(contactController))
router.put('/contacts/:id', authenticateToken, contactController.updateContact.bind(contactController))
router.delete('/contacts/:id', authenticateToken, contactController.deleteContact.bind(contactController))

// Company routes
router.get('/companies', authenticateToken, companyController.getAllCompanies.bind(companyController))
router.get('/companies/search', authenticateToken, companyController.searchCompanies.bind(companyController))
router.get('/companies/:id', authenticateToken, companyController.getCompanyById.bind(companyController))
router.get('/companies/:companyId/contacts', authenticateToken, contactController.getContactsByCompany.bind(contactController))
router.post('/companies', authenticateToken, companyController.createCompany.bind(companyController))
router.put('/companies/:id', authenticateToken, companyController.updateCompany.bind(companyController))
router.delete('/companies/:id', authenticateToken, companyController.deleteCompany.bind(companyController))

// Deal routes
router.get('/deals', authenticateToken, dealController.getAllDeals.bind(dealController))
router.get('/deals/stats', authenticateToken, dealController.getDealStats.bind(dealController))
router.get('/deals/stage/:stage', authenticateToken, dealController.getDealsByStage.bind(dealController))
router.get('/deals/:id', authenticateToken, dealController.getDealById.bind(dealController))
router.get('/deals/contact/:contactId', authenticateToken, dealController.getDealsByContact.bind(dealController))
router.get('/deals/company/:companyId', authenticateToken, dealController.getDealsByCompany.bind(dealController))
router.post('/deals', authenticateToken, dealController.createDeal.bind(dealController))
router.put('/deals/:id', authenticateToken, dealController.updateDeal.bind(dealController))
router.delete('/deals/:id', authenticateToken, dealController.deleteDeal.bind(dealController))

export default router
