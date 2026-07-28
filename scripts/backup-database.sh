#!/usr/bin/env bash
set -Eeuo pipefail
: "${DB_HOST:?}" "${DB_PORT:?}" "${DB_NAME:?}" "${DB_USER:?}" "${DB_PASSWORD:?}"
o="${1:-landsandboat-$(date +%Y%m%d-%H%M%S).sql.gz}"
MYSQL_PWD="$DB_PASSWORD" mariadb-dump -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" --single-transaction --routines --triggers "$DB_NAME" | gzip -9 > "$o"
echo "$o"
