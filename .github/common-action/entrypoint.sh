#!/bin/sh -l
set -euxo pipefail

DIGEST="$1"

ORG="$GITHUB_REPOSITORY_OWNER"

REPOSITORY=$(echo "${GITHUB_REPOSITORY}" | sed "s|${ORG}/||g")
#IMAGE="${REPOSITORY}:${GITHUB_SHA}"
echo "::set-output name=COMMIT_ID::${GITHUB_SHA}"
echo "::set-output name=REPOSITORY::${REPOSITORY}"

docker images --digests
IMAGE_ID=$(docker images --digests | grep "${DIGEST}" | awk '{print $4}')
echo "::set-output name=IMAGE_ID::${IMAGE_ID}"
