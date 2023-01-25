#!/usr/bin/env bash
set -e

DIR=$(dirname $0)
REPOSITORY=$1
source $DIR/functions.sh

start_db ${REPOSITORY}
run_migrations
