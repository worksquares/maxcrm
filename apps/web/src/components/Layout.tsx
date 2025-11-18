import { Link, Outlet, useNavigate } from 'react-router-dom'
import { useAuthStore } from '../stores/authStore'
import { Button } from './ui/button'

export function Layout() {
  const navigate = useNavigate()
  const { isAuthenticated, user, logout } = useAuthStore()

  const handleLogout = () => {
    logout()
    navigate('/login')
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <nav className="bg-white shadow-sm border-b">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between h-16">
            <div className="flex">
              <div className="flex-shrink-0 flex items-center">
                <Link to="/" className="text-2xl font-bold text-blue-600">
                  MAXCRM
                </Link>
              </div>
              {isAuthenticated && (
                <div className="hidden sm:ml-6 sm:flex sm:space-x-8">
                  <Link
                    to="/"
                    className="inline-flex items-center px-1 pt-1 text-sm font-medium text-gray-900 hover:text-blue-600 transition-colors"
                  >
                    Dashboard
                  </Link>
                  <Link
                    to="/contacts"
                    className="inline-flex items-center px-1 pt-1 text-sm font-medium text-gray-500 hover:text-blue-600 transition-colors"
                  >
                    Contacts
                  </Link>
                  <Link
                    to="/companies"
                    className="inline-flex items-center px-1 pt-1 text-sm font-medium text-gray-500 hover:text-blue-600 transition-colors"
                  >
                    Companies
                  </Link>
                  <Link
                    to="/deals"
                    className="inline-flex items-center px-1 pt-1 text-sm font-medium text-gray-500 hover:text-blue-600 transition-colors"
                  >
                    Deals
                  </Link>
                </div>
              )}
            </div>
            <div className="flex items-center gap-4">
              {isAuthenticated ? (
                <>
                  {user && (
                    <span className="text-sm text-gray-700">
                      {user.firstName} {user.lastName}
                    </span>
                  )}
                  <Button onClick={handleLogout} variant="outline" size="sm">
                    Logout
                  </Button>
                </>
              ) : (
                <div className="flex gap-2">
                  <Button
                    variant="ghost"
                    size="sm"
                    onClick={() => navigate('/login')}
                  >
                    Login
                  </Button>
                  <Button
                    size="sm"
                    onClick={() => navigate('/register')}
                  >
                    Register
                  </Button>
                </div>
              )}
            </div>
          </div>
        </div>
      </nav>

      <main className="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
        <Outlet />
      </main>
    </div>
  )
}
