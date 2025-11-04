#!/bin/sh
set -e

echo "Waiting for PostgreSQL to become available..."

while ! nc -z db 5432; do
  echo "Waiting for database..."
  sleep 2
done

echo "PostgreSQL is available!"

echo "Creating database if it doesn't exist..."
/app/_build/prod/rel/backend/bin/backend eval "Backend.Release.create_database()" || echo "Database already exists or couldn't be created"

echo "Running migrations..."
/app/_build/prod/rel/backend/bin/backend eval "Backend.Release.migrate()"

echo "Starting application..."
exec "$@"
