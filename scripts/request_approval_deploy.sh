#!/usr/bin/env bash

DIR=$(dirname $0)
source $DIR/functions.sh
set +e

# ASSUME_ROLE_ARN="arn:aws:iam::706851696280:role/Cross-Account-Access-github"
ASSUME_ROLE_ARN="arn:aws:iam::038036402334:role/Cross-Account-Access-github"

request_deploy_approval() {
  local step_function_arn="$1"
  local input_json="$2"
  local region="$3"
  local repository="$4"
  timestamep=$(date +"%Y-%m-%d_%H-%M-%S")
  execution_name="${repository}_${timestamep}"
  execution_arn=$(aws --region "$region" stepfunctions start-execution --state-machine-arn "$step_function_arn" --name "$execution_name" --input "$input_json" --query 'executionArn' --output text)

  if [ -z "$execution_arn" ]; then
    echo "Failed to start Step Function execution"
    sts_exit_role
    exit 1
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
        sts_exit_role
        exit 0
      elif [ "$output" == '{"Status": "Rejected"}' ]; then
        echo "Deployment denied"
        sts_exit_role
        exit 1
      else
        echo "Unexpected response from Step Functions. The deployment was denied anyways."
        echo "Step functions output was: $output"
        sts_exit_role
        exit 1
      fi
      ;;
    TIMED_OUT)
      echo "Timeout: Step Function execution did not complete within the expected time window. The deployment is denied."
      sts_exit_role
      exit 1
      ;;
    *)
      echo "[Error]: Step Function execution finished with status: $status"
      sts_exit_role
      exit 1
      ;;
    esac
  done
}

workflow_url="$1"
repository=$(echo "$2" | cut -d"/" -f2)
environment="$3"

sts_assume_role "$ASSUME_ROLE_ARN" "GH-runner-approval"
# sfn_arn="arn:aws:states:us-east-1:706851696280:stateMachine:main-accessnator-sfn-authorizer"
sfn_arn="arn:aws:states:us-east-1:038036402334:stateMachine:devops-sandbox-accessnator-sfn-authorizer"
region=$(echo "$sfn_arn" | cut -d':' -f4)
sfn_input="{\"workflow_url\": \"$workflow_url\", \"repository\": \"$repository\", \"environment\": \"$environment\" }"

request_deploy_approval "$sfn_arn" "$sfn_input" "$region" "$repository"
