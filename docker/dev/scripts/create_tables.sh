#!/usr/bin/env bash

cd `dirname $0`

TMP_SQL_FILE_CREATE=./sql/create_tables.sql
TMP_SQL_FILE_INSERT=./sql/insert_tables.sql
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

echo recreate tables
mkdir -p ${TMP_SQL_FILE_1%/*}
for db in $DB_NAMES; do
    echo "
    \c $db

    -- PCR検査実施人数サンプル
    drop table if exists pcr_count;
    create table pcr_count (
    id SERIAL PRIMARY KEY,
    date DATE NOT NULL,
    count INTEGER
    );

    " > $TMP_SQL_FILE_CREATE
    docker-compose run --rm pg -f "./scripts/sql/create_tables.sql"

    echo "
    \c $db

    --データインポート
    \copy pcr_count(date, count) from '/csv/pcr_count.csv' with csv header

    " > $TMP_SQL_FILE_INSERT
    docker-compose run --rm pg -f "./scripts/sql/insert_tables.sql"
done
