#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <local|docker> <db_container_name_or_empty> <dump_file_path>"
    exit 1
fi

MODE=$1
DB_CONTAINER_NAME=$2
DUMP_FILE=$3

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

drop_tables() {
    if [ "$MODE" == "docker" ]; then
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
    else
        psql -U $DB_USER -d $DB_NAME <<EOF
DO \$\$ 
DECLARE 
    r RECORD;
BEGIN 
    FOR r IN (SELECT tablename FROM pg_tables WHERE schemaname = 'public') LOOP
        EXECUTE 'DROP TABLE IF EXISTS ' || quote_ident(r.tablename) || ' CASCADE';
    END LOOP;
END \$\$;
EOF
    fi
}

restore_db() {
    if [ "$MODE" == "docker" ]; then
        docker exec -i $DB_CONTAINER_NAME psql -U $DB_USER -d $DB_NAME < $DUMP_FILE
    else
        psql -U $DB_USER -d $DB_NAME < $DUMP_FILE
    fi
}

drop_tables

restore_db

# Unset the password environment variable for security
unset PGPASSWORD

echo "Database restoration completed."
