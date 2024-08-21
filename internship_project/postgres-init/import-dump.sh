#!/bin/bash
set -e

# Function to check if the dump has already been imported
dump_imported() {
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -c "SELECT 1 FROM pg_tables WHERE tablename = 'databasechangelog'" | grep -q 1
}

# Check if the database exists
database_exists=$(psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --tuples-only -c "SELECT 1 FROM pg_database WHERE datname = '$POSTGRES_DB'")

if [ -z "$database_exists" ]; then
    echo "Creating database $POSTGRES_DB"
    createdb -U "$POSTGRES_USER" "$POSTGRES_DB"
fi

# Import the dump if it hasn't been imported yet
if ! dump_imported; then
    echo "Importing database dump"
    psql -v ON_ERROR_STOP=0 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" < /docker-entrypoint-initdb.d/database.sql
    echo "Dump imported successfully"
else
    echo "Dump has already been imported, skipping"
fi

echo "PostgreSQL initialization complete"