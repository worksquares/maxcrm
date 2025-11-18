# MAXCRM Web Application

Frontend application for MAXCRM built with React, Vite, TypeScript, Tailwind CSS, and shadcn/ui.

## Tech Stack

- **React 18** - UI library
- **Vite** - Build tool and dev server
- **TypeScript** - Type safety
- **Tailwind CSS** - Utility-first CSS framework
- **shadcn/ui** - Re-usable component library
- **React Router** - Client-side routing

## Getting Started

```bash
# Install dependencies (from root)
pnpm install

# Start development server
pnpm dev

# Or from root
pnpm dev:web
```

The application will be available at `http://localhost:3000`

## Development

### Adding shadcn/ui Components

```bash
# From the web directory
npx shadcn-ui@latest add button
npx shadcn-ui@latest add card
# etc.
```

### Project Structure

```
apps/web/
├── public/          # Static assets
├── src/
│   ├── components/  # React components
│   ├── lib/        # Utilities and helpers
│   ├── App.tsx     # Main App component
│   ├── main.tsx    # Entry point
│   └── index.css   # Global styles
├── index.html      # HTML template
└── vite.config.ts  # Vite configuration
```

## Building

```bash
pnpm build
```

The built files will be in the `dist/` directory.
