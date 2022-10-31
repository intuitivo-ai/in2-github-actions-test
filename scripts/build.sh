#!/usr/bin/env bash
set -e

x=$1

case $x in
"docker")
  echo "Building Docker"
  docker build . -t $DEFAULT_DOCKER_TAG
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
