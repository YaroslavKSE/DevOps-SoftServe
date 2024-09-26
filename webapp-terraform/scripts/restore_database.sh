#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <db_container_name> <dump_file_path>"
    exit 1
fi

DB_CONTAINER_NAME=$1
DUMP_FILE=$2

if [ -z "$DB_NAME" ] || [ -z "$DB_USER" ] || [ -z "$DB_PASSWORD" ]; then
    echo "Error: One or more required environment variables are not set."
    echo "Please set the following environment variables: DB_NAME, DB_USER, DB_PASSWORD"
    exit 1
fi

if [ ! -f "$DUMP_FILE" ]; then
    echo "Dump file $DUMP_FILE not found!"
    exit 1
fi

# Export the password so psql doesn't prompt for it
export PGPASSWORD=$DB_PASSWORD

# Drop existing tables to avoid conflicts
docker exec -i $DB_CONTAINER_NAME psql -U $DB_USER -d $DB_NAME <<EOF
DO \$\$ 
DECLARE 
    r RECORD;
BEGIN 
    FOR r IN (SELECT tablename FROM pg_tables WHERE schemaname = 'public') LOOP
        EXECUTE 'DROP TABLE IF EXISTS ' || quote_ident(r.tablename) || ' CASCADE';
    END LOOP;
END \$\$;
EOF

# Restore the database
if docker exec -i $DB_CONTAINER_NAME psql -U $DB_USER -d $DB_NAME < $DUMP_FILE; then
    echo "Database restoration completed successfully."
else
    echo "Database restoration failed."
    exit 1
fi

# Unset the password environment variable for security
unset PGPASSWORD
