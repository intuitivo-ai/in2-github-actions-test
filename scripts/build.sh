#!/usr/bin/env bash
set -e
DIR=$(dirname $0)
source $DIR/variables.sh
source $DIR/functions.sh

x=$1

case $x in
"docker" | "docker_s3")
  docker_build
  ;;
"layer")
  $0 docker
  docker run --rm \
    -v $(pwd):/data \
    $DEFAULT_DOCKER_TAG cp /packages/${PACKAGE}-python${PYTHON_VERSION}.zip /data
  ;;
"npm")
  echo "Building NPM"
  git config --global user.email "devops@intuitivo.com"
  git config --global user.name "DevOps"
  npm version $VERSION --no-git-tag-version
  npm ci
  ;;
*)
  exit 1
  ;;
esac
