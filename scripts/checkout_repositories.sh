#!/usr/bin/env bash
set -e
DIR=$(dirname $0)
source $DIR/variables.sh
source $DIR/functions.sh

REPOS_DIR=.external
ORG=$1
REPOS=${2//,/ }

mkdir -pv ${REPOS_DIR}
for repo in $(echo ${REPOS}); do
  git_checkout "${ORG}" "${repo}" "${REPOS_DIR}/${repo}"
done
