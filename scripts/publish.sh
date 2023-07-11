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
  BRANCH=$(echo "$GITHUB_REF_NAME" | sed "s|/|_|g")

  docker tag "$DEFAULT_DOCKER_TAG" "$REGISTRY/$REPOSITORY:$GITHUB_SHA"
  docker tag "$DEFAULT_DOCKER_TAG" "$REGISTRY/$REPOSITORY:$BRANCH_$GITHUB_SHA"
  docker images
  docker push "$REGISTRY/$REPOSITORY:$GITHUB_SHA"
  docker push "$REGISTRY/$REPOSITORY:$BRANCH_$GITHUB_SHA"
  ;;
"docker_s3")
  COMMIT_ID="$GITHUB_SHA"
  ORG="$GITHUB_REPOSITORY_OWNER"
  REPOSITORY=$(echo "$GITHUB_REPOSITORY" | sed "s|$ORG/||g")

  LOCAL_PATH=${LOCAL_PATH}
  LOCAL_FILENAME=${LOCAL_FILENAME}
  S3_PATH="${REPOSITORY}/${COMMIT_ID}/${LOCAL_FILENAME}"

  docker run --rm -d --name docker_s3 "$DEFAULT_DOCKER_TAG" sleep 60
  mkdir -pv tmp
  docker cp docker_s3:"${LOCAL_PATH}/${LOCAL_FILENAME}" ./tmp
  docker kill docker_s3

  for ACCOUNT_ID in ${ACCOUNT_IDS}; do
    LAMBDA_DEPLOYMENT_BUCKET="in2-lambda-deployments-${ACCOUNT_ID}-${AWS_REGION}"
    ASSUME_ROLE_ARN="arn:aws:iam::${ACCOUNT_ID}:role/Cross-Account-Access-github"

    sts_assume_role "${ASSUME_ROLE_ARN}" GH-runner
    s3_cp "./tmp/${LOCAL_FILENAME}" "s3://${LAMBDA_DEPLOYMENT_BUCKET}/${S3_PATH}"
    sts_exit_role
  done
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
