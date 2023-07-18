#!/usr/bin/env bash
set -e
DIR=$(dirname $0)
source $DIR/variables.sh
source $DIR/functions.sh
REPOSITORY=$1

cd "${DIR}"

rollback_migrations
