#!/usr/bin/env bash
set -e
DIR=$(dirname $0)
source $DIR/variables.sh
source $DIR/functions.sh

case $GITHUB_EVENT_NAME in
push)
  _BRANCH=${GITHUB_REF_NAME}
  ;;
pull_request)
  _BRANCH=${GITHUB_HEAD_REF}
  ;;
esac
BRANCH=${_BRANCH//\//_}
COMMIT_ID="${GH_SHA}"
ORG="${GITHUB_REPOSITORY_OWNER}"
REPOSITORY=$(echo "${GITHUB_REPOSITORY}" | sed "s|${ORG}/||g")

x=$1
case $x in
"docker")
  echo "Publishing Docker"

  docker tag "${DEFAULT_DOCKER_TAG}" "${REGISTRY}/${REPOSITORY}:${GH_SHA}"
  docker tag "${DEFAULT_DOCKER_TAG}" "${REGISTRY}/${REPOSITORY}:${BRANCH}_${GH_SHA}"
  docker images
  docker push "${REGISTRY}/${REPOSITORY}:${GH_SHA}"
  docker push "${REGISTRY}/${REPOSITORY}:${BRANCH}_${GH_SHA}"
  ;;
"docker_s3")
  $0 docker
  ASSUME_ROLE_ARN="arn:aws:iam::${ACCOUNT_ID}:role/Cross-Account-Access-github"
  LAMBDA_DEPLOYMENT_BUCKET="in2-lambda-deployments-${ACCOUNT_ID}-${AWS_REGION}"
  S3_PATH="${REPOSITORY}/${BRANCH}/${COMMIT_ID}"

  sts_assume_role "${ASSUME_ROLE_ARN}" GH-runner
  docker run --rm -d --name docker_s3 "$DEFAULT_DOCKER_TAG" sleep 60
  mkdir -pv tmp
  for LOCAL_PATH in ${LOCAL_PATHS}; do
    TARGET=$(echo "$LOCAL_PATH" | /usr/bin/cut -d '/' -f4 | /usr/bin/sed 's/_.*//')
    FILE="${TARGET}-${VERSION}-${LOCAL_FILENAME}"
    docker cp docker_s3:"${LOCAL_PATH}/${LOCAL_FILENAME}" ./tmp/"${FILE}"
    s3_cp "./tmp/${FILE}" "s3://${LAMBDA_DEPLOYMENT_BUCKET}/${S3_PATH}/${FILE}"
  done

  docker kill docker_s3
  sts_exit_role
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
