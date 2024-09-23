#!/usr/bin/env bash

DIR=$(dirname $0)
source $DIR/functions.sh
set +e

# ASSUME_ROLE_ARN="arn:aws:iam::706851696280:role/Cross-Account-Access-github"
ASSUME_ROLE_ARN="arn:aws:iam::038036402334:role/Cross-Account-Access-github"

# shellcheck disable=SC2317
is_approval_required() {
  local region="$1"
  local environment="$2"

  actor="$GITHUB_ACTOR"
  org="$GITHUB_REPOSITORY_OWNER"
  repository=$(echo "$GITHUB_REPOSITORY" | sed "s|$org/||g")

  sts_assume_role "${ASSUME_ROLE_ARN}" GH-runner-approval-"$repository"
  if [ $? -ne 0 ]; then
    echo "Failed to assume role."
    return 1
  fi
  echo "Invoking lambda function to get approval information."
  # aws --region "$region" lambda invoke --function-name arn:aws:lambda:us-east-1:706851696280:function:main-pre-approving-deploys --cli-binary-format raw-in-base64-out --payload "{ \"environment\": \"$environment\", \"repository\": \"$repository\" }" response.json
  aws --region "$region" lambda invoke --function-name arn:aws:lambda:us-east-1:038036402334:function:devops-sandbox-pre-approving-deploys --cli-binary-format raw-in-base64-out --payload "{ \"environment\": \"$environment\", \"repository\": \"$repository\", \"actor\": \"$actor\" }" response.json
  if [ $? -ne 0 ]; then
    echo "Failed to invoke lambda function to get approval information." >&2
    sts_exit_role
    return 1
  fi
  echo "Lambda response:"
  cat response.json
  echo
  update_github_output "approval_required" "$(jq '.approval_required' response.json)"
  update_github_output "reason" "$(jq '.reason' response.json)"

  sts_exit_role
}

# shellcheck disable=SC2317
request_deploy_approval() {
  local step_function_arn="$1"
  local input_json="$2"
  local region="$3"
  local repository="$4"
  timestamep=$(date +"%Y-%m-%d_%H-%M-%S")
  execution_name="${repository}_${timestamep}"

  sts_assume_role "${ASSUME_ROLE_ARN}" GH-runner-approval-"$repository"
  if [ $? -ne 0 ]; then
    echo "Failed to assume role." >&2
    return 1
  fi
  execution_arn=$(aws --region "$region" stepfunctions start-execution --state-machine-arn "$step_function_arn" --name "$execution_name" --input "$input_json" --query 'executionArn' --output text)

  if [ -z "$execution_arn" ]; then
    echo "Failed to start Step Function execution" >&2
    sts_exit_role
    return 1
  fi

  echo "Started Step Function execution: $execution_arn"

  while true; do
    # Get the execution status
    status=$(aws --region "$region" stepfunctions describe-execution --execution-arn "$execution_arn" --query 'status' --output text)
    case $status in
    RUNNING)
      echo "Waiting for deployment approval..."
      sleep 10
      ;;
    SUCCEEDED)
      output=$(aws --region "$region" stepfunctions describe-execution --execution-arn "$execution_arn" --query 'output' --output text)
      if [ "$output" == '{"Status": "Approved"}' ]; then
        echo "Deployment approved"
        update_github_output "approved" "true"
        sts_exit_role
        return 0
      elif [ "$output" == '{"Status": "Rejected"}' ]; then
        echo "Deployment denied"
        update_github_output "approved" "false"
        sts_exit_role
        return 0
      else
        echo "Unexpected response from Step Functions. The deployment was denied anyways."
        echo "Step functions output was: $output"
        update_github_output "approved" "false"
        sts_exit_role
        return 1
      fi
      ;;
    TIMED_OUT)
      echo "Timeout: Step Function execution did not complete within the expected time window. The deployment is denied."
      update_github_output "approved" "false"
      sts_exit_role
      return 1
      ;;
    *)
      echo "[Error]: Step Function execution finished with status: $status" >&2
      update_github_output "approved" "false"
      sts_exit_role
      return 1
      ;;
    esac
  done
}

action="$1"
shift # Remove action from arguments

case "$action" in
is_approval_required)
  region="$1"
  environment="$2"
  "$action" "$region" "$environment"
  exit $?
  ;;
request_deploy_approval)
  workflow_url="$1"
  repository=$(echo "$2" | cut -d"/" -f2)
  environment="$3"
  # sfn_arn="arn:aws:states:us-east-1:706851696280:stateMachine:main-accessnator-sfn-authorizer"
  sfn_arn="arn:aws:states:us-east-1:038036402334:stateMachine:devops-sandbox-accessnator-sfn-authorizer"
  region=$(echo "$sfn_arn" | cut -d':' -f4)
  sfn_input="{\"workflow_url\": \"$workflow_url\", \"repository\": \"$repository\", \"environment\": \"$environment\" }"
  "$action" "$sfn_arn" "$sfn_input" "$region" "$repository"
  exit $?
  ;;
*)
  echo "Unknown option: $1"
  exit 1
  ;;
esac
