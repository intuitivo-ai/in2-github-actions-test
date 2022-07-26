#!/usr/bin/env bash
set -e

x=$1

case $x in
  "docker")
    echo "Publishing Docker"
    COMMIT_ID="$GITHUB_SHA"
    ORG="$GITHUB_REPOSITORY_OWNER"
    REPOSITORY=$(echo "$GITHUB_REPOSITORY" | sed "s|$ORG/||g")

    docker tag "$DEFAULT_DOCKER_TAG" "$REGISTRY/$REPOSITORY:$GITHUB_SHA"
    docker tag "$DEFAULT_DOCKER_TAG" "$REGISTRY/$REPOSITORY:$GITHUB_REF_NAME_$GITHUB_SHA"
    docker images
    docker push "$REGISTRY/$REPOSITORY:$GITHUB_SHA"
    docker push "$REGISTRY/$REPOSITORY:$GITHUB_REF_NAME_$GITHUB_SHA"
    ;;
  "npm")
    echo "Publishing NPM"
    npm publish
    ;;
  *)
    exit 1
    ;;
esac
