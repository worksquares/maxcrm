# @maxcrm/shared

Shared TypeScript types, interfaces, and constants used across MAXCRM applications.

## Usage

This package is used internally by both the API and Web applications to ensure type consistency.

```typescript
import { Contact, Company, Deal, DealStage } from '@maxcrm/shared'
import { API_VERSION, DEFAULT_PAGE_SIZE } from '@maxcrm/shared'
```

## What's Included

- **Types**: Common data models (Contact, Company, Deal, User)
- **Enums**: Status enums (DealStage, UserRole)
- **API Types**: Response types for API communication
- **Constants**: Shared configuration values

## Development

This package uses TypeScript without compilation. Both API and Web apps import directly from the source.
