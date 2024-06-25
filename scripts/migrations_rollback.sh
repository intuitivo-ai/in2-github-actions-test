#!/usr/bin/env bash
set -e
REPOSITORY=$1
DIR=$(dirname $0)
source $DIR/variables.sh
source $DIR/functions.sh

cd "${DIR}"

rollback_migrations
