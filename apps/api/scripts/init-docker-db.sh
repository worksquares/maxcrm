#!/bin/bash
# Initialize PostgreSQL database using Docker for MAXCRM

set -e

echo "🐳 Starting PostgreSQL with Docker..."

# Configuration
CONTAINER_NAME="${CONTAINER_NAME:-maxcrm-postgres}"
DB_NAME="${DB_NAME:-maxcrm}"
DB_USER="${DB_USER:-maxcrm_user}"
DB_PASSWORD="${DB_PASSWORD:-maxcrm_password}"
POSTGRES_PORT="${POSTGRES_PORT:-5432}"

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

echo "✓ Docker is running"

# Stop and remove existing container if it exists
if [ "$(docker ps -a -q -f name=$CONTAINER_NAME)" ]; then
    echo "Stopping existing container..."
    docker stop $CONTAINER_NAME > /dev/null 2>&1 || true
    docker rm $CONTAINER_NAME > /dev/null 2>&1 || true
fi

# Start PostgreSQL container
echo "Starting PostgreSQL container..."
docker run --name $CONTAINER_NAME \
    -e POSTGRES_USER=$DB_USER \
    -e POSTGRES_PASSWORD=$DB_PASSWORD \
    -e POSTGRES_DB=$DB_NAME \
    -p $POSTGRES_PORT:5432 \
    -d postgres:15

echo "✓ PostgreSQL container started"

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to be ready..."
sleep 3

MAX_TRIES=30
TRIES=0
until docker exec $CONTAINER_NAME pg_isready -U $DB_USER > /dev/null 2>&1 || [ $TRIES -eq $MAX_TRIES ]; do
    echo "Waiting for PostgreSQL... ($TRIES/$MAX_TRIES)"
    sleep 1
    TRIES=$((TRIES+1))
done

if [ $TRIES -eq $MAX_TRIES ]; then
    echo "❌ PostgreSQL failed to start within 30 seconds"
    exit 1
fi

echo "✓ PostgreSQL is ready"

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "Creating .env file from .env.example..."
    cp .env.example .env
    sed -i "s|DATABASE_URL=.*|DATABASE_URL=postgresql://$DB_USER:$DB_PASSWORD@localhost:$POSTGRES_PORT/$DB_NAME|" .env
    echo "✓ .env file created"
fi

echo ""
echo "✅ Docker PostgreSQL setup complete!"
echo ""
echo "Container: $CONTAINER_NAME"
echo "Database: $DB_NAME"
echo "User: $DB_USER"
echo "Port: $POSTGRES_PORT"
echo "Connection: postgresql://$DB_USER:$DB_PASSWORD@localhost:$POSTGRES_PORT/$DB_NAME"
echo ""
echo "Useful Docker commands:"
echo "  Stop database:    docker stop $CONTAINER_NAME"
echo "  Start database:   docker start $CONTAINER_NAME"
echo "  View logs:        docker logs $CONTAINER_NAME"
echo "  Remove database:  docker rm -f $CONTAINER_NAME"
echo ""
echo "You can now run 'pnpm dev' to start the API server."
echo "The schema and seed data will be created automatically on first run."
