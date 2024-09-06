#!/usr/bin/env bash
set -e

docker_clear_image() {
  if [ -z "${DOCKER_IMAGE}" ]; then
    IMAGE_ID=$(docker images -q $DEFAULT_DOCKER_TAG)
  else
    IMAGE_ID=$(docker images -q "${DOCKER_IMAGE}")
  fi
  docker rmi -f $IMAGE_ID
}

docker_pull_image() {
  if [ -z "${DOCKER_IMAGE}" ]; then
    COMMIT_ID="${GITHUB_SHA}"
    ORG="${GITHUB_REPOSITORY_OWNER}"
    REPOSITORY=$(echo "${GITHUB_REPOSITORY}" | sed "s|${ORG}/||g")

    docker pull "${REGISTRY}"/"${REPOSITORY}":"${GITHUB_SHA}"
    docker tag "${REGISTRY}"/"${REPOSITORY}":"${GITHUB_SHA}" "$DEFAULT_DOCKER_TAG"
  else
    docker pull "${DOCKER_IMAGE}"
  fi
}

docker_run_tests() {
  local test_type="$1"
  if [ -z "${DOCKER_IMAGE}" ]; then
    ORG="${GITHUB_REPOSITORY_OWNER}"
    REPOSITORY=$(echo "${GITHUB_REPOSITORY}" | sed "s|${ORG}/||g")
    docker run --rm --entrypoint "" -v "$PWD"/coverage/:/coverage/ "${REGISTRY}"/"${REPOSITORY}":"${GITHUB_SHA}" scripts/run_tests.sh "${test_type}"
  else
    docker run -w /tmp/${GITHUB_REPOSITORY} --rm --entrypoint "" -v $PWD:/tmp/${GITHUB_REPOSITORY} "${DOCKER_IMAGE}" scripts/run_tests.sh "${test_type}"
  fi
}
