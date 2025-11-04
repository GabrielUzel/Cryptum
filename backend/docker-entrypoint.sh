set -e

echo "Waiting for PostgreSQL to become available..."

while ! pg_isready -h db -p 5432 -U $POSTGRES_USERNAME > /dev/null 2>&1; do
  echo "Waiting for database..."
  sleep 2
done

echo "PostgreSQL is available!"

echo "Creating database if it doesn't exist..."
/app/_build/prod/rel/your_app/bin/your_app eval "YourApp.Release.create_database()" || echo "Database already exists or couldn't be created"

echo "Running migrations..."
/app/_build/prod/rel/your_app/bin/your_app eval "YourApp.Release.migrate()"

echo "Starting application..."
exec "$@"
