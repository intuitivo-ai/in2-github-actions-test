#!/bin/sh -l
set -euxo pipefail

IMAGE_TAG="$1"

ORG="$GITHUB_REPOSITORY_OWNER"

REPOSITORY=$(echo "${GITHUB_REPOSITORY}" | sed "s|${ORG}/||g")
#IMAGE="${REPOSITORY}:${GITHUB_SHA}"
echo "::set-output name=COMMIT_ID::${GITHUB_SHA}"
echo "::set-output name=REPOSITORY::${REPOSITORY}"

docker images
IMAGE_ID=$(docker images | grep "${IMAGE_TAG}")
echo "::set-output name=IMAGE_ID::${IMAGE_ID}"
