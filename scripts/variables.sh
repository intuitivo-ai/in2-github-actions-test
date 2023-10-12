#!/usr/bin/env bash

export $(echo ${ADDITIONAL_VARIABLES} | sed 's/,/ /g')

DATABASE_TYPE="postgres"
NAME="in2-conde-inference"

DB_ENV_VARS=""
DB_ENV_VARS="${DB_ENV_VARS} -e POSTGRES_DB=local_database"
DB_ENV_VARS="${DB_ENV_VARS} -e POSTGRES_USER=local_user"
DB_ENV_VARS="${DB_ENV_VARS} -e POSTGRES_PASSWORD=local_password"

APP_ENV_VARS=""
APP_ENV_VARS="${APP_ENV_VARS} -e DATABASE=local_database:5432"
