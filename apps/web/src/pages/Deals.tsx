import { useEffect, useState } from 'react'
import { Deal, DealStage } from '@maxcrm/shared'
import { useDealStore } from '../stores/dealStore'

export function Deals() {
  const { deals, isLoading, error, fetchDeals, createDeal, updateDeal, deleteDeal, clearError } = useDealStore()

  const [isCreateModalOpen, setIsCreateModalOpen] = useState(false)
  const [isEditModalOpen, setIsEditModalOpen] = useState(false)
  const [isDeleteModalOpen, setIsDeleteModalOpen] = useState(false)
  const [selectedDeal, setSelectedDeal] = useState<Deal | null>(null)

  useEffect(() => {
    fetchDeals()
  }, [])

  const handleCreate = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    const formData = new FormData(e.currentTarget)
    try {
      const expectedCloseDateStr = formData.get('expectedCloseDate') as string
      await createDeal({
        title: formData.get('title') as string,
        value: parseFloat(formData.get('value') as string),
        stage: formData.get('stage') as DealStage,
        contactId: formData.get('contactId') as string || undefined,
        companyId: formData.get('companyId') as string || undefined,
        expectedCloseDate: expectedCloseDateStr ? new Date(expectedCloseDateStr) : undefined,
        userId: '', // This will be set by the backend
      })
      setIsCreateModalOpen(false)
      e.currentTarget.reset()
    } catch (err) {
      console.error('Create failed:', err)
    }
  }

  const handleEdit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    if (!selectedDeal) return
    const formData = new FormData(e.currentTarget)
    try {
      const expectedCloseDateStr = formData.get('expectedCloseDate') as string
      await updateDeal(selectedDeal.id, {
        title: formData.get('title') as string,
        value: parseFloat(formData.get('value') as string),
        stage: formData.get('stage') as DealStage,
        contactId: formData.get('contactId') as string || undefined,
        companyId: formData.get('companyId') as string || undefined,
        expectedCloseDate: expectedCloseDateStr ? new Date(expectedCloseDateStr) : undefined,
      })
      setIsEditModalOpen(false)
      setSelectedDeal(null)
    } catch (err) {
      console.error('Update failed:', err)
    }
  }

  const handleDelete = async () => {
    if (!selectedDeal) return
    try {
      await deleteDeal(selectedDeal.id)
      setIsDeleteModalOpen(false)
      setSelectedDeal(null)
    } catch (err) {
      console.error('Delete failed:', err)
    }
  }

  const getStageColor = (stage: string) => {
    const colors: Record<string, string> = {
      lead: 'bg-gray-100 text-gray-800',
      qualified: 'bg-blue-100 text-blue-800',
      proposal: 'bg-yellow-100 text-yellow-800',
      negotiation: 'bg-purple-100 text-purple-800',
      closed_won: 'bg-green-100 text-green-800',
      closed_lost: 'bg-red-100 text-red-800',
    }
    return colors[stage] || 'bg-gray-100 text-gray-800'
  }

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-gray-500">Loading...</div>
      </div>
    )
  }

  return (
    <div className="px-4 py-6 sm:px-0">
      <div className="sm:flex sm:items-center">
        <div className="sm:flex-auto">
          <h1 className="text-3xl font-bold text-gray-900">Deals</h1>
          <p className="mt-2 text-sm text-gray-700">
            A list of all deals in your pipeline including their value, stage, and expected close date.
          </p>
        </div>
        <div className="mt-4 sm:mt-0 sm:ml-16 sm:flex-none">
          <button
            type="button"
            onClick={() => setIsCreateModalOpen(true)}
            className="inline-flex items-center justify-center rounded-md border border-transparent bg-blue-600 px-4 py-2 text-sm font-medium text-white shadow-sm hover:bg-blue-700"
          >
            Add deal
          </button>
        </div>
      </div>

      <div className="mt-8 flex flex-col">
        <div className="-my-2 -mx-4 overflow-x-auto sm:-mx-6 lg:-mx-8">
          <div className="inline-block min-w-full py-2 align-middle md:px-6 lg:px-8">
            <div className="overflow-hidden shadow ring-1 ring-black ring-opacity-5 md:rounded-lg">
              <table className="min-w-full divide-y divide-gray-300">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="py-3.5 pl-4 pr-3 text-left text-sm font-semibold text-gray-900 sm:pl-6">
                      Title
                    </th>
                    <th className="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">
                      Value
                    </th>
                    <th className="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">
                      Stage
                    </th>
                    <th className="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">
                      Expected Close
                    </th>
                    <th className="relative py-3.5 pl-3 pr-4 sm:pr-6">
                      <span className="sr-only">Actions</span>
                    </th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-200 bg-white">
                  {deals.length === 0 ? (
                    <tr>
                      <td colSpan={5} className="text-center py-8 text-gray-500">
                        No deals found
                      </td>
                    </tr>
                  ) : (
                    deals.map((deal) => (
                      <tr key={deal.id}>
                        <td className="whitespace-nowrap py-4 pl-4 pr-3 text-sm font-medium text-gray-900 sm:pl-6">
                          {deal.title}
                        </td>
                        <td className="whitespace-nowrap px-3 py-4 text-sm text-gray-500">
                          ${deal.value.toLocaleString()}
                        </td>
                        <td className="whitespace-nowrap px-3 py-4 text-sm text-gray-500">
                          <span className={`inline-flex rounded-full px-2 text-xs font-semibold leading-5 ${getStageColor(deal.stage)}`}>
                            {deal.stage.replace('_', ' ')}
                          </span>
                        </td>
                        <td className="whitespace-nowrap px-3 py-4 text-sm text-gray-500">
                          {deal.expectedCloseDate
                            ? new Date(deal.expectedCloseDate).toLocaleDateString()
                            : '-'}
                        </td>
                        <td className="relative whitespace-nowrap py-4 pl-3 pr-4 text-right text-sm font-medium sm:pr-6">
                          <button
                            onClick={() => {
                              setSelectedDeal(deal)
                              setIsEditModalOpen(true)
                            }}
                            className="text-blue-600 hover:text-blue-900 mr-4"
                          >
                            Edit
                          </button>
                          <button
                            onClick={() => {
                              setSelectedDeal(deal)
                              setIsDeleteModalOpen(true)
                            }}
                            className="text-red-600 hover:text-red-900"
                          >
                            Delete
                          </button>
                        </td>
                      </tr>
                    ))
                  )}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>

      {/* Create Modal */}
      {isCreateModalOpen && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6 w-full max-w-md max-h-[90vh] overflow-y-auto">
            <h2 className="text-2xl font-bold mb-4">Create Deal</h2>
            {error && (
              <div className="mb-4 p-3 bg-red-100 text-red-700 rounded">
                {error}
              </div>
            )}
            <form onSubmit={handleCreate}>
              <div className="mb-4">
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Title *
                </label>
                <input
                  type="text"
                  name="title"
                  required
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                />
              </div>
              <div className="mb-4">
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Value *
                </label>
                <input
                  type="number"
                  name="value"
                  step="0.01"
                  min="0"
                  required
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                />
              </div>
              <div className="mb-4">
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Stage *
                </label>
                <select
                  name="stage"
                  required
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                >
                  <option value={DealStage.LEAD}>Lead</option>
                  <option value={DealStage.QUALIFIED}>Qualified</option>
                  <option value={DealStage.PROPOSAL}>Proposal</option>
                  <option value={DealStage.NEGOTIATION}>Negotiation</option>
                  <option value={DealStage.CLOSED_WON}>Closed Won</option>
                  <option value={DealStage.CLOSED_LOST}>Closed Lost</option>
                </select>
              </div>
              <div className="mb-4">
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Expected Close Date
                </label>
                <input
                  type="date"
                  name="expectedCloseDate"
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                />
              </div>
              <div className="mb-4">
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Contact ID
                </label>
                <input
                  type="text"
                  name="contactId"
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                />
              </div>
              <div className="mb-4">
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Company ID
                </label>
                <input
                  type="text"
                  name="companyId"
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                />
              </div>
              <div className="flex justify-end gap-3">
                <button
                  type="button"
                  onClick={() => {
                    setIsCreateModalOpen(false)
                    clearError()
                  }}
                  className="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-100 rounded-md hover:bg-gray-200"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={isLoading}
                  className="px-4 py-2 text-sm font-medium text-white bg-blue-600 rounded-md hover:bg-blue-700 disabled:opacity-50"
                >
                  {isLoading ? 'Creating...' : 'Create'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Edit Modal */}
      {isEditModalOpen && selectedDeal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6 w-full max-w-md max-h-[90vh] overflow-y-auto">
            <h2 className="text-2xl font-bold mb-4">Edit Deal</h2>
            {error && (
              <div className="mb-4 p-3 bg-red-100 text-red-700 rounded">
                {error}
              </div>
            )}
            <form onSubmit={handleEdit}>
              <div className="mb-4">
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Title *
                </label>
                <input
                  type="text"
                  name="title"
                  defaultValue={selectedDeal.title}
                  required
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                />
              </div>
              <div className="mb-4">
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Value *
                </label>
                <input
                  type="number"
                  name="value"
                  step="0.01"
                  min="0"
                  defaultValue={selectedDeal.value}
                  required
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                />
              </div>
              <div className="mb-4">
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Stage *
                </label>
                <select
                  name="stage"
                  defaultValue={selectedDeal.stage}
                  required
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                >
                  <option value={DealStage.LEAD}>Lead</option>
                  <option value={DealStage.QUALIFIED}>Qualified</option>
                  <option value={DealStage.PROPOSAL}>Proposal</option>
                  <option value={DealStage.NEGOTIATION}>Negotiation</option>
                  <option value={DealStage.CLOSED_WON}>Closed Won</option>
                  <option value={DealStage.CLOSED_LOST}>Closed Lost</option>
                </select>
              </div>
              <div className="mb-4">
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Expected Close Date
                </label>
                <input
                  type="date"
                  name="expectedCloseDate"
                  defaultValue={
                    selectedDeal.expectedCloseDate
                      ? new Date(selectedDeal.expectedCloseDate).toISOString().split('T')[0]
                      : ''
                  }
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                />
              </div>
              <div className="mb-4">
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Contact ID
                </label>
                <input
                  type="text"
                  name="contactId"
                  defaultValue={selectedDeal.contactId || ''}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                />
              </div>
              <div className="mb-4">
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Company ID
                </label>
                <input
                  type="text"
                  name="companyId"
                  defaultValue={selectedDeal.companyId || ''}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                />
              </div>
              <div className="flex justify-end gap-3">
                <button
                  type="button"
                  onClick={() => {
                    setIsEditModalOpen(false)
                    setSelectedDeal(null)
                    clearError()
                  }}
                  className="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-100 rounded-md hover:bg-gray-200"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={isLoading}
                  className="px-4 py-2 text-sm font-medium text-white bg-blue-600 rounded-md hover:bg-blue-700 disabled:opacity-50"
                >
                  {isLoading ? 'Updating...' : 'Update'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Delete Confirmation Modal */}
      {isDeleteModalOpen && selectedDeal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6 w-full max-w-md">
            <h2 className="text-2xl font-bold mb-4">Delete Deal</h2>
            {error && (
              <div className="mb-4 p-3 bg-red-100 text-red-700 rounded">
                {error}
              </div>
            )}
            <p className="mb-6 text-gray-700">
              Are you sure you want to delete{' '}
              <strong>{selectedDeal.title}</strong>? This action cannot be undone.
            </p>
            <div className="flex justify-end gap-3">
              <button
                type="button"
                onClick={() => {
                  setIsDeleteModalOpen(false)
                  setSelectedDeal(null)
                  clearError()
                }}
                className="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-100 rounded-md hover:bg-gray-200"
              >
                Cancel
              </button>
              <button
                onClick={handleDelete}
                disabled={isLoading}
                className="px-4 py-2 text-sm font-medium text-white bg-red-600 rounded-md hover:bg-red-700 disabled:opacity-50"
              >
                {isLoading ? 'Deleting...' : 'Delete'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
