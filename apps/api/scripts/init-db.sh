#!/bin/bash
# Database initialization script for MAXCRM

set -e

echo "🚀 Initializing MAXCRM PostgreSQL database..."

# Configuration
DB_NAME="${DB_NAME:-maxcrm}"
DB_USER="${DB_USER:-maxcrm_user}"
DB_PASSWORD="${DB_PASSWORD:-maxcrm_password}"

# Check if PostgreSQL is running
if ! pg_isready > /dev/null 2>&1; then
    echo "❌ PostgreSQL is not running. Please start PostgreSQL first."
    exit 1
fi

echo "✓ PostgreSQL is running"

# Create database user if not exists
echo "Creating database user..."
psql -U postgres -tc "SELECT 1 FROM pg_user WHERE usename = '$DB_USER'" | grep -q 1 || \
    psql -U postgres -c "CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD';"

echo "✓ Database user created/exists"

# Create database if not exists
echo "Creating database..."
psql -U postgres -tc "SELECT 1 FROM pg_database WHERE datname = '$DB_NAME'" | grep -q 1 || \
    psql -U postgres -c "CREATE DATABASE $DB_NAME OWNER $DB_USER;"

echo "✓ Database created/exists"

# Grant privileges
echo "Granting privileges..."
psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;"

echo "✓ Privileges granted"

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "Creating .env file from .env.example..."
    cp .env.example .env
    sed -i "s/DATABASE_URL=.*/DATABASE_URL=postgresql:\/\/$DB_USER:$DB_PASSWORD@localhost:5432\/$DB_NAME/" .env
    echo "✓ .env file created"
fi

echo ""
echo "✅ Database initialization complete!"
echo ""
echo "Database: $DB_NAME"
echo "User: $DB_USER"
echo "Connection: postgresql://$DB_USER:$DB_PASSWORD@localhost:5432/$DB_NAME"
echo ""
echo "You can now run 'pnpm dev' to start the API server."
echo "The schema and seed data will be created automatically on first run."
