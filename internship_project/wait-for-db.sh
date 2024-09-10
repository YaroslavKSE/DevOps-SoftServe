#!/bin/sh
# wait-for-it.sh

set -e

host="$1"
shift
cmd="$@"

until PGPASSWORD=$SPRING_DATASOURCE_PASSWORD psql -h "$host" -U "$SPRING_DATASOURCE_USERNAME" -d "$SPRING_DATASOURCE_DB" -c '\q'; do
  >&2 echo "Postgres is unavailable - sleeping"
  sleep 1
done

>&2 echo "Postgres is up - executing command"
exec $cmd