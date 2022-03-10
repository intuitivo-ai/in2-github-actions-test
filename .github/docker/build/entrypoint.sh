#!/bin/sh -l
set -euxo pipefail

env
echo "Hello $1"
time=$(date)
echo "::set-output name=time::$time"

ORG="$1"

REPOSITORY=$(echo "${GITHUB_REPOSITORY}" | sed "s|${ORG}/||g")
IMAGE="${REPOSITORY}:${GITHUB_SHA}"
docker build . -t "${IMAGE}"
echo "::set-output name=COMMIT_ID::${GITHUB_SHA}"
echo "::set-output name=REPOSITORY::${REPOSITORY}"
