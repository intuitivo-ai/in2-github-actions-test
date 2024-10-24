#!/usr/bin/env bash

echo "::group::{variables.sh}"
export $(echo ${ADDITIONAL_VARIABLES} | sed 's/,/ /g')

DATABASE_TYPE="postgres"
#LOCAL=true
NAME="in2-github-actions-test"
API_USER=${NAME//-/_}
POSTGRES_DB=local_database
POSTGRES_PASSWORD=local_password
POSTGRES_USER=local_user

DB_ENV_VARS=""
DB_ENV_VARS="${DB_ENV_VARS} -e POSTGRES_DB=local_database"
DB_ENV_VARS="${DB_ENV_VARS} -e POSTGRES_USER=local_user"
DB_ENV_VARS="${DB_ENV_VARS} -e POSTGRES_PASSWORD=local_password"

APP_ENV_VARS=""
APP_ENV_VARS="${APP_ENV_VARS} -e DATABASE=local_database:5432"
APP_ENV_VARS="${APP_ENV_VARS} -e DATABASE_URL=ecto://local_user:local_password@172.17.0.2:5432/local_database"
echo "::endgroup::"
