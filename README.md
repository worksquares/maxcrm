# MAXCRM

A modern Customer Relationship Management (CRM) system built with a monorepo architecture.

## 🏗️ Project Structure

This is a **monorepo** using pnpm workspaces, with clear separation between API and UI projects:

```
maxcrm/
├── apps/
│   ├── web/              # Frontend React application
│   │   ├── src/
│   │   │   ├── components/
│   │   │   ├── lib/
│   │   │   ├── App.tsx
│   │   │   ├── main.tsx
│   │   │   └── index.css
│   │   ├── public/
│   │   ├── index.html
│   │   ├── vite.config.ts
│   │   ├── tailwind.config.js
│   │   └── package.json
│   │
│   └── api/              # Backend Express API
│       ├── src/
│       │   ├── controllers/
│       │   ├── routes/
│       │   ├── services/
│       │   ├── middleware/
│       │   ├── models/
│       │   ├── types/
│       │   └── index.ts
│       ├── .env.example
│       └── package.json
│
├── packages/
│   ├── shared/           # Shared TypeScript types & constants
│   │   ├── src/
│   │   │   ├── types/
│   │   │   ├── constants.ts
│   │   │   └── index.ts
│   │   └── package.json
│   │
│   └── config/           # Shared configuration files
│       └── package.json
│
├── .gitignore
├── package.json          # Root workspace configuration
├── pnpm-workspace.yaml   # PNPM workspace definition
└── README.md
```

## 🚀 Tech Stack

### Frontend (apps/web)
- **React 18** - UI library
- **TypeScript** - Type safety
- **Vite** - Build tool and dev server
- **Tailwind CSS** - Utility-first CSS framework
- **shadcn/ui** - Re-usable component library
- **React Router** - Client-side routing

### Backend (apps/api)
- **Node.js** - Runtime environment
- **Express** - Web framework
- **TypeScript** - Type safety
- **tsx** - TypeScript execution for development
- **Zod** - Schema validation

### Shared Packages
- **@maxcrm/shared** - Common types, interfaces, and constants
- **@maxcrm/config** - Shared configuration files

## 📦 Getting Started

### Prerequisites

- Node.js >= 18.0.0
- pnpm >= 8.0.0

### Installation

```bash
# Install pnpm globally if you haven't already
npm install -g pnpm

# Install all dependencies
pnpm install
```

### Development

```bash
# Run both API and Web in parallel
pnpm dev

# Run only the web app
pnpm dev:web

# Run only the API
pnpm dev:api
```

**Access the applications:**
- Frontend: http://localhost:3000
- Backend API: http://localhost:4000
- Health check: http://localhost:4000/health

### Building

```bash
# Build all apps
pnpm build

# Build specific app
pnpm build:web
pnpm build:api
```

### Type Checking & Linting

```bash
# Type check all projects
pnpm type-check

# Lint all projects
pnpm lint
```

## 🔧 Configuration

### Environment Variables

#### API (apps/api/.env)
Copy `.env.example` to `.env` and configure:

```env
NODE_ENV=development
PORT=4000
DATABASE_URL=postgresql://user:password@localhost:5432/maxcrm
JWT_SECRET=your-secret-key
CORS_ORIGIN=http://localhost:3000
```

## 📝 Scripts

### Root Level
- `pnpm dev` - Start all apps in development mode
- `pnpm build` - Build all apps
- `pnpm lint` - Lint all apps
- `pnpm type-check` - Type check all apps
- `pnpm clean` - Clean all node_modules and build artifacts

### App-Specific
- `pnpm dev:web` - Start web app only
- `pnpm dev:api` - Start API only
- `pnpm build:web` - Build web app only
- `pnpm build:api` - Build API only

## 🎯 Features (Planned)

- Contact Management
- Company/Account Management
- Deal Pipeline & Sales Tracking
- Activity Timeline
- User Management & Authentication
- Dashboard & Analytics
- Email Integration
- Task Management

## 🤝 Contributing

This is a private project. For development guidelines, see individual app READMEs:
- [Web App README](apps/web/README.md)
- [API README](apps/api/README.md)

## 📄 License

MIT

## 👤 Author

KOUSALYADS (KOUSALYA.SATHISH@outlook.com)
