import { useState } from 'react'

function App() {
  const [count, setCount] = useState(0)

  return (
    <div className="min-h-screen bg-background flex items-center justify-center">
      <div className="container mx-auto px-4 py-8">
        <div className="max-w-2xl mx-auto text-center space-y-8">
          <h1 className="text-4xl font-bold tracking-tight text-foreground">
            Welcome to MAXCRM
          </h1>
          <p className="text-lg text-muted-foreground">
            A modern CRM system built with React, TypeScript, Tailwind CSS, and shadcn/ui
          </p>

          <div className="flex flex-col items-center gap-4 p-8 border rounded-lg bg-card">
            <button
              onClick={() => setCount((count) => count + 1)}
              className="px-6 py-3 bg-primary text-primary-foreground rounded-md hover:bg-primary/90 transition-colors font-medium"
            >
              Count is {count}
            </button>
            <p className="text-sm text-muted-foreground">
              Edit <code className="px-2 py-1 bg-muted rounded text-xs">apps/web/src/App.tsx</code> and save to test HMR
            </p>
          </div>

          <div className="pt-4">
            <p className="text-sm text-muted-foreground">
              Start building your CRM features here!
            </p>
          </div>
        </div>
      </div>
    </div>
  )
}

export default App
