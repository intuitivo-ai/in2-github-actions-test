#!/usr/bin/env bash
set -e

source variables.sh
IMAGE=in2-github-actions-test

function start_db() {
  NAME=$1
  docker run --rm \
    --name "${DATABASE_TYPE}_${NAME}" \
    -p 5432:5432 \
    ${DB_ENV_VARS} \
    -d "${DATABASE_TYPE}"
  sleep 10
}
function stop_db() {
  NAME=$1
  docker kill "${DATABASE_TYPE}_${NAME}"
}

function run_script() {
  SCRIPT=$@

  docker run --entrypoint "" \
    ${APP_ENV_VARS} \
    ${REGISTRY}/${REPOSITORY}:${GITHUB_SHA} scripts/migration_commands.sh $SCRIPT
}

function run_migrations() {
  run_script run
}
function rollback_migrations() {
  run_script rollback
}
