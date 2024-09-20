#!/usr/bin/env bash
set -e
DIR=$(dirname $0)
source $DIR/functions.sh

ASSUME_ROLE_ARN="arn:aws:iam::706851696280:role/Cross-Account-Access-github"

sts_assume_role "${ASSUME_ROLE_ARN}" GH-runner-approval
CALLER_IDENTITY=$(aws sts get-caller-identity)
if [ $? -ne 0 ]; then
  echo "Error getting the caller identity."
  sts_exit_role
  exit 1
fi

echo "The caller identity is:"
echo "Account: $(echo $CALLER_IDENTITY | jq -r '.Account')"
echo "UserId: $(echo $CALLER_IDENTITY | jq -r '.UserId')"
echo "Arn: $(echo $CALLER_IDENTITY | jq -r '.Arn')"
sts_exit_role
