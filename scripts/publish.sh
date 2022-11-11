#!/usr/bin/env bash
set -e
DIR=$(dirname $0)
source $DIR/variables.sh
source $DIR/functions.sh

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
"layer")
  FILE="${PACKAGE}-python${PYTHON_VERSION}.zip"
  LAYER_PATH="$ENVIRONMENT/$PACKAGE/$PYTHON_VERSION/$FILE"

  sts_assume_role $ASSUME_ROLE_ARN GH-runner
  s3_cp "${FILE}" "s3://${LAMBDA_DEPLOYMENT_BUCKET}/${LAYER_PATH}"

  aws lambda publish-layer-version \
    --layer-name "${PACKAGE}_${_PYTHON_VERSION}" \
    --description "${PACKAGE}" \
    --content "S3Bucket=${LAMBDA_DEPLOYMENT_BUCKET},S3Key=${LAYER_PATH}" \
    --compatible-runtimes "python${PYTHON_VERSION}" \
    --region "${AWS_REGION}"
  ;;
"npm")
  echo "Publishing NPM"
  npm publish
  ;;
*)
  exit 1
  ;;
esac
