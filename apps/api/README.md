# MAXCRM API

Backend API for MAXCRM built with Node.js, Express, and TypeScript.

## Tech Stack

- **Node.js** - Runtime environment
- **Express** - Web framework
- **TypeScript** - Type safety
- **tsx** - TypeScript execution for development
- **Zod** - Schema validation

## Getting Started

```bash
# Install dependencies (from root)
pnpm install

# Create environment file
cp .env.example .env

# Start development server
pnpm dev

# Or from root
pnpm dev:api
```

The API will be available at `http://localhost:4000`

## Development

### Project Structure

```
apps/api/
├── src/
│   ├── controllers/    # Request handlers
│   ├── routes/        # API routes
│   ├── services/      # Business logic
│   ├── middleware/    # Express middleware
│   ├── models/        # Data models
│   ├── types/         # TypeScript types
│   └── index.ts       # Entry point
├── .env.example       # Environment variables template
└── tsconfig.json      # TypeScript configuration
```

### API Endpoints

- `GET /health` - Health check
- `GET /api` - API information
- `GET /api/contacts` - Contacts (placeholder)
- `GET /api/companies` - Companies (placeholder)
- `GET /api/deals` - Deals (placeholder)

### Environment Variables

See `.env.example` for all available configuration options.

## Building

```bash
pnpm build
```

The compiled files will be in the `dist/` directory.

## Running in Production

```bash
pnpm build
pnpm start
```
