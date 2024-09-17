#!/usr/bin/env bash
set -e
DIR=$(dirname $0)
source $DIR/variables.sh
if [[ -n "$LOCAL" ]]; then
  DOCKER_URL=${NAME}:latest
else
  DOCKER_URL=${REGISTRY}/${REPOSITORY}:${GITHUB_SHA}
fi

function get_docker_build_params() {
  _DOCKER_BUILD_ARGS=""
  _DOCKER_SECRET_BUILD_ARGS=""
  _DOCKER_BUILD_TARGET=""

  for x in $(echo $DOCKER_BUILD_ARGS | sed 's/,/ /g'); do
    _DOCKER_BUILD_ARGS="${_DOCKER_BUILD_ARGS} --build-arg $x"
  done
  for x in $(echo $DOCKER_SECRET_BUILD_ARGS | sed 's/,/ /g'); do
    _DOCKER_BUILD_ARGS="${_DOCKER_BUILD_ARGS} --build-arg $x"
  done

  if [ "$DOCKER_TARGET" != "" ]; then
    _DOCKER_BUILD_TARGET="--target $DOCKER_TARGET"
  fi
  echo "${_DOCKER_BUILD_ARGS} ${_DOCKER_BUILD_TARGET}"
}

function docker_build() {
  echo "Building Docker"
  _DOCKER_BUILD_PARAMS=$(get_docker_build_params)
  docker build \
    ${_DOCKER_BUILD_PARAMS} \
    -t $DEFAULT_DOCKER_TAG \
    .
}

function git_checkout() {
  _ORG=$1
  _REPO=$2
  _PATH=$3
  echo "Cloning repository ${_REPO}"
  git clone git@github.com:${_ORG}/${_REPO}.git ${_PATH}
}

function run_sql_commands() {
  SQL=$1
  docker exec ${DATABASE_TYPE}_${NAME} psql -U ${POSTGRES_USER} ${POSTGRES_DB} -c "${SQL}"
}
function create_db_roles() {
  run_sql_commands "CREATE ROLE writer;"
  run_sql_commands "GRANT USAGE ON SCHEMA public TO writer;"
  run_sql_commands "GRANT CREATE on SCHEMA public to writer;"
  run_sql_commands "GRANT ALL PRIVILEGES ON DATABASE ${POSTGRES_DB} TO writer;"
  run_sql_commands "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO writer;"
  run_sql_commands "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO writer;"

  run_sql_commands "CREATE USER ${API_USER} WITH ENCRYPTED PASSWORD '${POSTGRES_PASSWORD}';"
  run_sql_commands "GRANT writer TO ${API_USER};"
}
function start_db() {
  NAME=$1
  docker run --rm \
    --name "${DATABASE_TYPE}_${NAME}" \
    -p 5432:5432 \
    ${DB_ENV_VARS} \
    -d "${DATABASE_TYPE}"
  sleep 10
  create_db_roles
}
function stop_db() {
  NAME=$1
  docker kill "${DATABASE_TYPE}_${NAME}"
}

function run_script() {
  SCRIPT=$@

  docker run --entrypoint "" \
    ${APP_ENV_VARS} \
    ${DOCKER_URL} scripts/migration_commands.sh $SCRIPT
}

function run_migrations() {
  run_script run
}
function rollback_migrations() {
  run_script rollback
}

function s3_cp() {
  aws s3 cp "$1" "$2" --region "${AWS_REGION}"
}

function sts_assume_role() {
  echo "role-arn=$1"
  echo "role-session-name=$2"
  aws sts assume-role --role-arn "$1" --role-session-name "$2" --region "${AWS_REGION}" >sts.json
  export AWS_ACCESS_KEY_ID=$(jq .Credentials.AccessKeyId sts.json | sed 's/"//g')
  export AWS_SECRET_ACCESS_KEY=$(jq .Credentials.SecretAccessKey sts.json | sed 's/"//g')
  export AWS_SESSION_TOKEN=$(jq .Credentials.SessionToken sts.json | sed 's/"//g')
}

function sts_exit_role() {
  unset AWS_ACCESS_KEY_ID
  unset AWS_SECRET_ACCESS_KEY
  unset AWS_SESSION_TOKEN
}

function update_github_output() {
  OUTPUT="$1=$2"
  if [ "$DEBUG" == "true" ]; then
    echo "$OUTPUT"
  fi
  echo "$OUTPUT" >>"$GITHUB_OUTPUT"
}

function install_pip_requirements() {
  pip3 install -r requirements.txt
}