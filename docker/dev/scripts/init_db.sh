#!/usr/bin/env bash

cd `dirname $0`

TMP_SQL_FILE=./sql/tmp.sql
DB_DEV=db
# DB_TEST=db_test
DB_NAMES="$DB_DEV"
# DB_NAMES="$DB_DEV $DB_TEST"

echo target databases are $DB_NAMES

echo start database server
docker-compose up -d db

echo wait for db up
while true; do
    docker-compose run --rm --entrypoint "pg_isready" pg -h db;
    if [ $? == 0 ]; then
        break;
    fi
    echo wait 1sec
    sleep 1
done

echo recreate databases and schemas
mkdir -p ${TMP_SQL_FILE%/*}
for db in $DB_NAMES; do
    echo "
    DROP DATABASE IF EXISTS $db;
    CREATE DATABASE $db;
    -- \c $db
    -- CREATE SCHEMA sample;
    " > $TMP_SQL_FILE
    docker-compose run --rm pg -f "./scripts/sql/tmp.sql"
done
