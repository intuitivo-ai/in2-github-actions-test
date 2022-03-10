#!/bin/bash -l
set -euxo pipefail

pwd
source /common.sh

IMAGE_TAG="$1"

docker tag "${IMAGE_TAG}" "${REGISTRY}/${REPOSITORY}:${GITHUB_SHA}"
docker tag "${IMAGE_TAG}" "${REGISTRY}/${REPOSITORY}:${GITHUB_REF_NAME}_${GITHUB_SHA}"
docker images

aws ecr get-login-password | docker login --username AWS --password-stdin "${REGISTRY}"

docker push "${REGISTRY}/${REPOSITORY}:${GITHUB_SHA}"
docker push "${REGISTRY}/${REPOSITORY}:${GITHUB_REF_NAME}_${GITHUB_SHA}"
