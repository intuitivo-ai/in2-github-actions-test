#!/usr/bin/env bash
set -e

DIR=$(dirname $0)
REPOSITORY=$1

cd "${DIR}"
source functions.sh

stop_db ${REPOSITORY}
