# MAXCRM Database Documentation

## PostgreSQL Setup

MAXCRM uses PostgreSQL as its primary database. This document explains how to set up and manage the database.

## Quick Start

### Option 1: Docker (Recommended for Development)

The easiest way to get started is using Docker:

```bash
# Run the Docker setup script
./scripts/init-docker-db.sh

# Or manually:
docker run --name maxcrm-postgres \
  -e POSTGRES_USER=maxcrm_user \
  -e POSTGRES_PASSWORD=maxcrm_password \
  -e POSTGRES_DB=maxcrm \
  -p 5432:5432 \
  -d postgres:15
```

### Option 2: Local PostgreSQL Installation

If you have PostgreSQL installed locally:

```bash
# Run the setup script
./scripts/init-db.sh

# Or manually:
createdb maxcrm
createuser -P maxcrm_user  # Enter password: maxcrm_password
psql -c "GRANT ALL PRIVILEGES ON DATABASE maxcrm TO maxcrm_user;"
```

### Option 3: Cloud PostgreSQL

For production or remote development, you can use any PostgreSQL hosting service:
- AWS RDS
- Heroku Postgres
- DigitalOcean Managed Databases
- Supabase
- Neon

Just update the `DATABASE_URL` in your `.env` file with the connection string provided by your hosting service.

## Environment Configuration

Create a `.env` file in the `apps/api` directory:

```bash
cp .env.example .env
```

Update the `DATABASE_URL` in your `.env` file:

```
DATABASE_URL=postgresql://maxcrm_user:maxcrm_password@localhost:5432/maxcrm
```

## Database Schema

The database schema is automatically created when you start the API server for the first time. The schema includes:

### Tables

#### users
- **id** (UUID, Primary Key)
- **email** (VARCHAR, Unique)
- **password_hash** (VARCHAR)
- **first_name** (VARCHAR)
- **last_name** (VARCHAR)
- **role** (VARCHAR) - 'admin', 'manager', 'sales_rep', 'user'
- **created_at** (TIMESTAMP)
- **updated_at** (TIMESTAMP)

#### companies
- **id** (UUID, Primary Key)
- **name** (VARCHAR)
- **website** (VARCHAR, nullable)
- **industry** (VARCHAR, nullable)
- **size** (VARCHAR, nullable)
- **created_at** (TIMESTAMP)
- **updated_at** (TIMESTAMP)

#### contacts
- **id** (UUID, Primary Key)
- **first_name** (VARCHAR)
- **last_name** (VARCHAR)
- **email** (VARCHAR)
- **phone** (VARCHAR, nullable)
- **company_id** (UUID, Foreign Key to companies)
- **created_at** (TIMESTAMP)
- **updated_at** (TIMESTAMP)

#### deals
- **id** (UUID, Primary Key)
- **title** (VARCHAR)
- **value** (DECIMAL)
- **stage** (VARCHAR) - 'lead', 'qualified', 'proposal', 'negotiation', 'closed_won', 'closed_lost'
- **contact_id** (UUID, Foreign Key to contacts, nullable)
- **company_id** (UUID, Foreign Key to companies, nullable)
- **expected_close_date** (TIMESTAMP, nullable)
- **created_at** (TIMESTAMP)
- **updated_at** (TIMESTAMP)

### Indexes

- **users**: email
- **companies**: name, industry
- **contacts**: email, company_id, (first_name, last_name)
- **deals**: stage, contact_id, company_id, expected_close_date

### Triggers

All tables have automatic `updated_at` timestamp triggers that update when a record is modified.

## Seed Data

The database is automatically seeded with sample data on first run:
- 3 users (admin, manager, sales rep)
- 5 companies
- 8 contacts
- 8 deals

The seed data is only inserted if the database is empty (no users exist).

## Database Management

### Viewing Data

```bash
# Connect to database
psql postgresql://maxcrm_user:maxcrm_password@localhost:5432/maxcrm

# Common queries
SELECT * FROM users;
SELECT * FROM contacts;
SELECT * FROM companies;
SELECT * FROM deals;
```

### Resetting the Database

To completely reset the database and start fresh:

```bash
# Using Docker
docker stop maxcrm-postgres
docker rm maxcrm-postgres
./scripts/init-docker-db.sh

# Using local PostgreSQL
dropdb maxcrm
createdb maxcrm
# Then restart the API server
```

### Backup and Restore

```bash
# Backup
pg_dump postgresql://maxcrm_user:maxcrm_password@localhost:5432/maxcrm > backup.sql

# Restore
psql postgresql://maxcrm_user:maxcrm_password@localhost:5432/maxcrm < backup.sql
```

## Connection Pooling

The API uses `pg.Pool` with the following configuration:
- **max**: 20 connections
- **idleTimeoutMillis**: 30000 (30 seconds)
- **connectionTimeoutMillis**: 2000 (2 seconds)

This ensures efficient connection management and prevents connection leaks.

## Security Best Practices

1. **Never commit `.env` file** - It contains sensitive database credentials
2. **Use strong passwords** in production
3. **Use SSL/TLS** for database connections in production
4. **Limit database user permissions** in production
5. **Regular backups** - Set up automated backups for production
6. **Monitor connections** - Watch for connection leaks

## Production Considerations

For production deployments:

1. **Use connection pooling** (already configured)
2. **Enable SSL**: Update `DATABASE_URL`:
   ```
   DATABASE_URL=postgresql://user:password@host:5432/dbname?sslmode=require
   ```
3. **Set up read replicas** for scaling reads
4. **Configure proper backup strategy**
5. **Set up monitoring** (e.g., pg_stat_statements)
6. **Use managed PostgreSQL** services for easier management

## Troubleshooting

### Connection Refused

```bash
# Check if PostgreSQL is running
pg_isready

# For Docker:
docker ps | grep maxcrm-postgres
docker logs maxcrm-postgres
```

### Permission Denied

```bash
# Grant all privileges
psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE maxcrm TO maxcrm_user;"
```

### Schema Not Created

The API automatically creates the schema on startup. If it fails:
1. Check the API server logs
2. Ensure the database user has CREATE privileges
3. Manually run the schema:
   ```bash
   psql postgresql://maxcrm_user:maxcrm_password@localhost:5432/maxcrm < src/db/schema.sql
   ```

### Migration Issues

If you need to modify the schema:
1. Stop the API server
2. Update `src/db/schema.sql`
3. Drop and recreate the database (dev only)
4. For production, use proper migration tools like `node-pg-migrate`

## Database Files

- `src/db/index.ts` - Connection pool and query helpers
- `src/db/schema.sql` - Database schema definition
- `src/db/seed.sql` - Sample data for development
- `src/models/*.ts` - Data access layer (models)
- `scripts/init-db.sh` - Local PostgreSQL setup script
- `scripts/init-docker-db.sh` - Docker PostgreSQL setup script

## Further Reading

- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [node-postgres (pg) Documentation](https://node-postgres.com/)
- [PostgreSQL Best Practices](https://wiki.postgresql.org/wiki/Don%27t_Do_This)
