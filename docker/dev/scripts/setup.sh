#!/usr/bin/env bash

cd `dirname $0`

# direnvコマンド存在確認
which direnv
set -e

# .envrcファイル作成
ENVRC=../../../.envrc
if [ ! -f $ENVRC ]; then
    echo create .envrc
    cp $ENVRC.example $ENVRC
fi

# direnv有効化
direnv allow

# .envファイル作成
ENV=../../../api-rust/.env
if [ ! -f $ENV ]; then
    echo create .env
    cp $ENV.example $ENV
fi

# docker-composeファイル作成
DOCKER_COMPOSE_FILE=../docker-compose.yml
if [ ! -f $DOCKER_COMPOSE_FILE ]; then
    echo create docker-compose.yml
    cp $DOCKER_COMPOSE_FILE.example $DOCKER_COMPOSE_FILE
fi

echo docker-compose build
docker-compose stop
docker-compose build

echo install libraries and build in container
docker-compose run --rm api-rust-cmd cargo build

echo initialize database
./init_db.sh

echo create tables and insert data
./create_tables.sh
