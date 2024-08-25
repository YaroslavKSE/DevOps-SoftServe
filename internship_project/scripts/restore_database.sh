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

export PGPASSWORD=$DB_PASSWORD

docker exec -i $DB_CONTAINER_NAME psql -U $DB_USER -d $DB_NAME < $DUMP_FILE

unset PGPASSWORD

echo "Database restoration completed."
