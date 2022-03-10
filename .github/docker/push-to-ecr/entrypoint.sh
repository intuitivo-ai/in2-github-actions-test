#!/bin/sh -l
set -euxo pipefail

IMAGE_TAG="$1"

docker tag "${IMAGE_TAG}" "${REGISTRY}/${REPOSITORY}:${GITHUB_SHA}"
docker tag "${IMAGE_TAG}" "${REGISTRY}/${REPOSITORY}:${GITHUB_REF_NAME}"
docker tag "${IMAGE_TAG}" "${REGISTRY}/${REPOSITORY}:${GITHUB_REF_NAME}_${GITHUB_SHA}"

docker images
